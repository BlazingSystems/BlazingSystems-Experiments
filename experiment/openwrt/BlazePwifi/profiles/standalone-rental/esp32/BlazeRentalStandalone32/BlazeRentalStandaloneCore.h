#pragma once
#include <Arduino.h>
#ifdef ESP8266
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266HTTPClient.h>
#include <LittleFS.h>
#include <bearssl/bearssl.h>
extern "C" {
#include <user_interface.h>
}
using BlazeWebServer = ESP8266WebServer;
#else
#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>
#include <LittleFS.h>
#include <mbedtls/sha256.h>
#include <esp_system.h>
using BlazeWebServer = WebServer;
#endif

#ifndef BLAZE_SLOT_COUNT
#ifdef ESP8266
#define BLAZE_SLOT_COUNT 2
#else
#define BLAZE_SLOT_COUNT 4
#endif
#endif

#ifndef BLAZE_MAX_DEVICES
#ifdef ESP8266
#define BLAZE_MAX_DEVICES 6
#else
#define BLAZE_MAX_DEVICES 18
#endif
#endif

struct BlazeDevice {
  String id, secret, label, allowed, hidden, preferred, timerMode, quick, adminSalt, adminHash, inventory;
  uint32_t lease=0,lastSeen=0,revision=1,adminRounds=4096,gesture=4000,grace=0;
  bool timerToggle=true,notifications=true,unrestricted=false;
};
struct BlazeSlot {
  int pin=-1; bool last=true; uint32_t lastEdge=0; String targetDevice,targetNonce,remoteTarget; uint32_t targetUntil=0; bool remoteInsert=false;
};

class BlazeRentalStandalone {
public:
  BlazeWebServer web{80};
  BlazeDevice devices[BLAZE_MAX_DEVICES];
  BlazeSlot slots[BLAZE_SLOT_COUNT];
  int deviceCount=0;
  String role="server",staSsid="",staPass="",apPass="",adminSalt="",adminHash="",session="";
  String remoteHost="",remoteKey="",baseId="blaze-multi";
  uint32_t sessionUntil=0,epochBase=0,epochMillis=0,lastRemotePoll=0;
  uint32_t secondsPerPulse=600,coinWindow=120;
  String enrollId="",enrollSecret="",enrollLabel="Rental phone"; uint32_t enrollUntil=0;

  void begin(){
    Serial.begin(115200); delay(30);
#ifdef ESP8266
    LittleFS.begin();
#else
    LittleFS.begin(true);
#endif
    loadConfig(); loadDevices();
    WiFi.mode(WIFI_AP_STA);
    String suffix=chipSuffix();
    String ap="BlazeRental-"+suffix;
    if(adminHash.length()) {
      if(apPass.length()<8) apPass="blaze-"+suffix+"-setup";
      WiFi.softAP(ap.c_str(),apPass.c_str());
    } else {
      WiFi.softAP(ap.c_str());
    }
    if(staSsid.length()) WiFi.begin(staSsid.c_str(),staPass.c_str());
    configurePins(); routes(); web.begin();
    Serial.println(); Serial.println("BlazePwifi Standalone Rental Server");
    Serial.println("AP: "+ap);
    Serial.println("Admin: http://192.168.4.1/");
    if(!adminHash.length()) Serial.println("FIRST BOOT: AP is open until an administrator password is created.");
  }

  void loop(){
    web.handleClient();
    syncNtpIfReady();
    scanCoins();
    if(role=="multicoin" && millis()-lastRemotePoll>1000){ lastRemotePoll=millis(); pollRemote(); }
    delay(2);
  }

private:
  static String esc(String s){s.replace("&","&amp;");s.replace("<","&lt;");s.replace(">","&gt;");s.replace("\"","&quot;");return s;}
  static String json(String s){s.replace("\\","\\\\");s.replace("\"","\\\"");s.replace("\r"," ");s.replace("\n"," ");return s;}
  static String clean(String s){s.replace("\t"," ");s.replace("\r"," ");s.replace("\n"," ");return s;}
  static String fld(const String& line,int idx){int start=0,n=0;for(int i=0;i<=(int)line.length();i++){if(i==(int)line.length()||line[i]=='\t'){if(n==idx)return line.substring(start,i);start=i+1;n++;}}return "";}
  static bool validHex(const String&s,int n){if((int)s.length()!=n)return false;for(size_t i=0;i<s.length();i++){char ch=s[i];if(!isxdigit((unsigned char)ch))return false;}return true;}
  static bool validPkgList(const String&s){if(s.length()>2048)return false;for(size_t i=0;i<s.length();i++){char ch=s[i];if(!(isalnum((unsigned char)ch)||ch=='.'||ch=='_'||ch=='-'||ch==','||ch=='*'))return false;}return true;}
  uint8_t rb(){
#ifdef ESP8266
    return (uint8_t)(os_random()&0xff);
#else
    return (uint8_t)(esp_random()&0xff);
#endif
  }
  String randomHex(int bytes){static const char*h="0123456789abcdef";String o;o.reserve(bytes*2);for(int i=0;i<bytes;i++){uint8_t b=rb();o+=h[b>>4];o+=h[b&15];}return o;}
  String chipSuffix(){
#ifdef ESP8266
    char b[9];snprintf(b,sizeof(b),"%06X",ESP.getChipId());return String(b);
#else
    uint64_t m=ESP.getEfuseMac();char b[9];snprintf(b,sizeof(b),"%06X",(uint32_t)(m&0xffffff));return String(b);
#endif
  }

  void shaRaw(const uint8_t*data,size_t len,uint8_t out[32]){
#ifdef ESP8266
    br_sha256_context c;br_sha256_init(&c);br_sha256_update(&c,data,len);br_sha256_out(&c,out);
#else
    mbedtls_sha256_context c;mbedtls_sha256_init(&c);mbedtls_sha256_starts_ret(&c,0);mbedtls_sha256_update_ret(&c,data,len);mbedtls_sha256_finish_ret(&c,out);mbedtls_sha256_free(&c);
#endif
  }
  String hex32(const uint8_t b[32]){static const char*h="0123456789abcdef";String o;o.reserve(64);for(int i=0;i<32;i++){o+=h[b[i]>>4];o+=h[b[i]&15];}return o;}
  String sha256(const String&s){uint8_t o[32];shaRaw((const uint8_t*)s.c_str(),s.length(),o);return hex32(o);}
  String msStr(uint32_t sec){char b[24];snprintf(b,sizeof(b),"%llu",(unsigned long long)sec*1000ULL);return String(b);}
  String hmac(const String&key,const String&msg){
    uint8_t k[64]={0}; if(key.length()>64){uint8_t kh[32];shaRaw((const uint8_t*)key.c_str(),key.length(),kh);memcpy(k,kh,32);}else memcpy(k,key.c_str(),key.length());
    uint8_t in[64],outp[64];for(int i=0;i<64;i++){in[i]=k[i]^0x36;outp[i]=k[i]^0x5c;}
    uint8_t inner[32];
#ifdef ESP8266
    br_sha256_context c;br_sha256_init(&c);br_sha256_update(&c,in,64);br_sha256_update(&c,msg.c_str(),msg.length());br_sha256_out(&c,inner);
    br_sha256_init(&c);br_sha256_update(&c,outp,64);br_sha256_update(&c,inner,32);uint8_t fin[32];br_sha256_out(&c,fin);
#else
    mbedtls_sha256_context c;mbedtls_sha256_init(&c);mbedtls_sha256_starts_ret(&c,0);mbedtls_sha256_update_ret(&c,in,64);mbedtls_sha256_update_ret(&c,(const unsigned char*)msg.c_str(),msg.length());mbedtls_sha256_finish_ret(&c,inner);
    mbedtls_sha256_starts_ret(&c,0);mbedtls_sha256_update_ret(&c,outp,64);mbedtls_sha256_update_ret(&c,inner,32);uint8_t fin[32];mbedtls_sha256_finish_ret(&c,fin);mbedtls_sha256_free(&c);
#endif
    return hex32(fin);
  }
  String iterHash(const String&pass,const String&salt,uint32_t rounds){String v=sha256(salt+"|"+pass+"|"+salt);for(uint32_t i=1;i<rounds;i++)v=sha256(v+"|"+pass+"|"+salt);return v;}

  uint32_t nowSec(){time_t t=time(nullptr);if(t>1700000000){epochBase=(uint32_t)t;epochMillis=millis();return (uint32_t)t;}if(epochBase>1700000000)return epochBase+(millis()-epochMillis)/1000;return 0;}
  void syncNtpIfReady(){static bool done=false;if(done||WiFi.status()!=WL_CONNECTED)return;configTime(0,0,"pool.ntp.org","time.google.com");time_t t=time(nullptr);if(t>1700000000){epochBase=(uint32_t)t;epochMillis=millis();done=true;}}
  void setBrowserTime(uint32_t t){if(t>1700000000){epochBase=t;epochMillis=millis();}}

  void loadConfig(){
    if(!LittleFS.exists("/config.txt"))return;File f=LittleFS.open("/config.txt","r");
    while(f&&f.available()){String l=f.readStringUntil('\n');l.trim();int p=l.indexOf('=');if(p<1)continue;String k=l.substring(0,p),v=l.substring(p+1);
      if(k=="role")role=v;else if(k=="sta_ssid")staSsid=v;else if(k=="sta_pass")staPass=v;else if(k=="ap_pass")apPass=v;else if(k=="admin_salt")adminSalt=v;else if(k=="admin_hash")adminHash=v;else if(k=="remote_host")remoteHost=v;else if(k=="remote_key")remoteKey=v;else if(k=="base_id")baseId=v;else if(k=="seconds_per_pulse")secondsPerPulse=v.toInt();else if(k=="coin_window")coinWindow=v.toInt();else if(k.startsWith("slot")){int n=k.substring(4).toInt();if(n>=1&&n<=BLAZE_SLOT_COUNT)slots[n-1].pin=v.toInt();}
    } if(f)f.close();
  }
  void saveConfig(){File f=LittleFS.open("/config.txt","w");if(!f)return;f.println("role="+role);f.println("sta_ssid="+clean(staSsid));f.println("sta_pass="+clean(staPass));f.println("ap_pass="+clean(apPass));f.println("admin_salt="+adminSalt);f.println("admin_hash="+adminHash);f.println("remote_host="+clean(remoteHost));f.println("remote_key="+clean(remoteKey));f.println("base_id="+clean(baseId));f.println("seconds_per_pulse="+String(secondsPerPulse));f.println("coin_window="+String(coinWindow));for(int i=0;i<BLAZE_SLOT_COUNT;i++)f.println("slot"+String(i+1)+"="+String(slots[i].pin));f.close();}
  void loadDevices(){deviceCount=0;if(!LittleFS.exists("/devices.tsv"))return;File f=LittleFS.open("/devices.tsv","r");while(f&&f.available()&&deviceCount<BLAZE_MAX_DEVICES){String l=f.readStringUntil('\n');l.trim();if(!l.length())continue;BlazeDevice&d=devices[deviceCount++];d.id=fld(l,0);d.secret=fld(l,1);d.lease=fld(l,2).toInt();d.label=fld(l,3);d.lastSeen=fld(l,4).toInt();d.revision=max(1UL,(uint32_t)fld(l,5).toInt());d.unrestricted=fld(l,6)=="unrestricted";d.allowed=fld(l,7);d.hidden=fld(l,8);d.preferred=fld(l,9);d.timerMode=fld(l,10);d.timerToggle=fld(l,11)!="0";d.quick=fld(l,12);d.notifications=fld(l,13)!="0";d.gesture=fld(l,14).toInt();d.grace=fld(l,15).toInt();d.adminSalt=fld(l,16);d.adminHash=fld(l,17);d.adminRounds=max(1UL,(uint32_t)fld(l,18).toInt());d.inventory=fld(l,19);}if(f)f.close();}
  void saveDevices(){File f=LittleFS.open("/devices.tsv","w");if(!f)return;for(int i=0;i<deviceCount;i++){BlazeDevice&d=devices[i];f.printf("%s\t%s\t%lu\t%s\t%lu\t%lu\t%s\t%s\t%s\t%s\t%s\t%d\t%s\t%d\t%lu\t%lu\t%s\t%s\t%lu\t%s\n",d.id.c_str(),d.secret.c_str(),(unsigned long)d.lease,clean(d.label).c_str(),(unsigned long)d.lastSeen,(unsigned long)d.revision,d.unrestricted?"unrestricted":"rental",clean(d.allowed).c_str(),clean(d.hidden).c_str(),clean(d.preferred).c_str(),clean(d.timerMode).c_str(),d.timerToggle?1:0,clean(d.quick).c_str(),d.notifications?1:0,(unsigned long)d.gesture,(unsigned long)d.grace,d.adminSalt.c_str(),d.adminHash.c_str(),(unsigned long)d.adminRounds,clean(d.inventory).c_str());}f.close();}
  int findDevice(const String&id){for(int i=0;i<deviceCount;i++)if(devices[i].id==id)return i;return -1;}
  void removeDevice(int n){if(n<0||n>=deviceCount)return;for(int i=n;i<deviceCount-1;i++)devices[i]=devices[i+1];deviceCount--;saveDevices();}
  void event(const String&s){File f=LittleFS.open("/events.log","a");if(f){f.println(String(nowSec())+"\t"+clean(s));f.close();}}

  bool sessionOk(){String t=web.header("X-Blaze-Session");return session.length()&&t==session&&(int32_t)(sessionUntil-millis())>0;}
  void jsonSend(const String&s){web.send(200,"application/json",s);}
  void fail(const String&e){jsonSend("{\"ok\":false,\"error\":\""+json(e)+"\"}");}

  void routes(){
    const char* headers[]={"X-Blaze-Session"}; web.collectHeaders(headers,1);
    web.on("/",HTTP_GET,[this](){web.send_P(200,"text/html",ADMIN_HTML);});
    web.on("/api/login",HTTP_POST,[this](){loginApi();});
    web.on("/api/setup",HTTP_POST,[this](){setupApi();});
    web.on("/api/admin",HTTP_POST,[this](){adminApi();});
    web.on("/cgi-bin/rental",HTTP_POST,[this](){rentalApi();});
    web.onNotFound([this](){web.send(404,"text/plain","BlazeRental standalone server");});
  }

  void setupApi(){if(adminHash.length()){fail("already configured");return;}String p=web.arg("password");if(p.length()<12){fail("password must be at least 12 characters");return;}adminSalt=randomHex(8);adminHash=iterHash(p,adminSalt,2048);staSsid=clean(web.arg("ssid"));staPass=clean(web.arg("wifi_password"));apPass=clean(web.arg("ap_password"));if(apPass.length()&&apPass.length()<8)apPass="";saveConfig();session=randomHex(24);sessionUntil=millis()+1800000UL;jsonSend("{\"ok\":true,\"session\":\""+session+"\"}");}
  void loginApi(){if(!adminHash.length()){fail("setup required");return;}String p=web.arg("password");if(iterHash(p,adminSalt,2048)!=adminHash){delay(700);fail("invalid credentials");return;}session=randomHex(24);sessionUntil=millis()+1800000UL;jsonSend("{\"ok\":true,\"session\":\""+session+"\"}");}
  void adminApi(){if(!sessionOk()){fail("unauthorized");return;}sessionUntil=millis()+1800000UL;String a=web.arg("action");
    if(a=="time"){setBrowserTime(web.arg("epoch").toInt());jsonSend("{\"ok\":true}");return;}
    if(a=="status"){String s="{\"ok\":true,\"role\":\""+role+"\",\"ip\":\""+WiFi.localIP().toString()+"\",\"ap_ip\":\""+WiFi.softAPIP().toString()+"\",\"devices\":"+String(deviceCount)+",\"slots\":"+String(BLAZE_SLOT_COUNT)+",\"time_sane\":"+(nowSec()>1700000000?"true":"false")+",\"heap\":"+String(ESP.getFreeHeap())+"}";jsonSend(s);return;}
    if(a=="list"){String s="{\"ok\":true,\"devices\":[";for(int i=0;i<deviceCount;i++){if(i)s+=",";BlazeDevice&d=devices[i];s+="{\"device_id\":\""+d.id+"\",\"label\":\""+json(d.label)+"\",\"lease_until\":"+String(d.lease)+",\"last_seen\":"+String(d.lastSeen)+",\"policy_revision\":"+String(d.revision)+",\"launcher_mode\":\""+String(d.unrestricted?"unrestricted":"rental")+"\",\"allowed_packages\":\""+json(d.allowed)+"\",\"hidden_packages\":\""+json(d.hidden)+"\",\"preferred_vendo\":\""+json(d.preferred)+"\",\"timer_mode\":\""+json(d.timerMode)+"\",\"timer_user_toggle\":"+String(d.timerToggle?1:0)+",\"quick_controls\":\""+json(d.quick)+"\",\"notifications_enabled\":"+String(d.notifications?1:0)+",\"admin_password_set\":"+(d.adminHash.length()?"true":"false")+",\"inventory\":\""+json(d.inventory)+"\"}";}s+="]}";jsonSend(s);return;}
    if(a=="enroll"){if(deviceCount>=BLAZE_MAX_DEVICES){fail("device capacity reached");return;}uint32_t n=nowSec();if(!n){fail("set server time first");return;}enrollId=randomHex(6);enrollSecret=randomHex(18);enrollLabel=clean(web.arg("label"));if(!enrollLabel.length())enrollLabel="Rental phone";enrollUntil=n+600;String tok=enrollId+"."+enrollSecret;jsonSend("{\"ok\":true,\"token\":\""+tok+"\",\"expires\":600}");return;}
    if(a=="add_time"||a=="set_time"||a=="expire"){int i=findDevice(web.arg("device_id"));if(i<0){fail("unknown device");return;}uint32_t n=nowSec();if(!n){fail("set server time first");return;}if(a=="expire")devices[i].lease=n;else{uint32_t sec=web.arg("seconds").toInt();if(sec>2592000UL){fail("duration too large");return;}devices[i].lease=(a=="add_time"?max(devices[i].lease,n):n)+sec;}saveDevices();event(a+" "+devices[i].id);jsonSend("{\"ok\":true,\"lease_until\":"+String(devices[i].lease)+"}");return;}
    if(a=="revoke"){int i=findDevice(web.arg("device_id"));if(i<0){fail("unknown device");return;}event("revoke "+devices[i].id);removeDevice(i);jsonSend("{\"ok\":true}");return;}
    if(a=="rename"){int i=findDevice(web.arg("device_id"));if(i<0){fail("unknown device");return;}devices[i].label=clean(web.arg("label")).substring(0,64);saveDevices();jsonSend("{\"ok\":true}");return;}
    if(a=="policy"){int i=findDevice(web.arg("device_id"));if(i<0){fail("unknown device");return;}String al=web.arg("allowed"),hi=web.arg("hidden");if(!validPkgList(al)||!validPkgList(hi)){fail("invalid package list");return;}BlazeDevice&d=devices[i];d.unrestricted=web.arg("mode")=="unrestricted";d.allowed=al.length()?al:"*";d.hidden=hi;d.preferred=clean(web.arg("preferred"));d.timerMode=web.arg("timer_mode");if(d.timerMode!="overlay"&&d.timerMode!="always"&&d.timerMode!="off")d.timerMode="overlay";d.timerToggle=web.arg("timer_toggle")!="0";d.quick=clean(web.arg("quick"));d.notifications=web.arg("notifications")!="0";d.grace=web.arg("grace").toInt();d.revision++;saveDevices();jsonSend("{\"ok\":true,\"policy_revision\":"+String(d.revision)+"}");return;}
    if(a=="device_admin"){int i=findDevice(web.arg("device_id"));if(i<0){fail("unknown device");return;}String p=web.arg("password");if(p.length()<8){fail("password too short");return;}BlazeDevice&d=devices[i];d.adminSalt=randomHex(12);d.adminRounds=4096;d.adminHash=iterHash(p,d.adminSalt,d.adminRounds);d.revision++;saveDevices();jsonSend("{\"ok\":true}");return;}
    if(a=="settings"){String newRole=web.arg("role");if(newRole=="server"||newRole=="multicoin")role=newRole;secondsPerPulse=max(1UL,(uint32_t)web.arg("seconds_per_pulse").toInt());coinWindow=max(5UL,(uint32_t)web.arg("coin_window").toInt());remoteHost=clean(web.arg("remote_host"));remoteKey=clean(web.arg("remote_key"));baseId=clean(web.arg("base_id"));staSsid=clean(web.arg("ssid"));staPass=clean(web.arg("wifi_password"));for(int i=0;i<BLAZE_SLOT_COUNT;i++){String k="slot"+String(i+1);if(web.hasArg(k))slots[i].pin=web.arg(k).toInt();}saveConfig();configurePins();jsonSend("{\"ok\":true,\"reboot_recommended\":true}");return;}
    if(a=="events"){String s="{\"ok\":true,\"events\":[";if(LittleFS.exists("/events.log")){File f=LittleFS.open("/events.log","r");String lines[30];int n=0;while(f&&f.available()){lines[n%30]=f.readStringUntil('\n');n++;}if(f)f.close();int count=min(n,30),start=max(0,n-count);for(int j=0;j<count;j++){if(j)s+=",";String l=lines[(start+j)%30];s+="\""+json(l)+"\"";}}s+="]}";jsonSend(s);return;}
    fail("unknown action");
  }

  void rentalApi(){String a=web.arg("action"),nonce=web.arg("nonce"),sig=web.arg("sig");uint32_t n=nowSec();if(!n){fail("server time not synchronized");return;}if(!nonce.length()||!sig.length()){fail("missing authentication");return;}
    if(a=="enroll"){String eid=web.arg("enroll_id");if(eid!=enrollId||n>enrollUntil||!enrollSecret.length()){fail("enrollment invalid or used");return;}String tok=enrollId+"."+enrollSecret;if(hmac(tok,"enroll|"+nonce+"|"+tok)!=sig){fail("authentication failed");return;}if(deviceCount>=BLAZE_MAX_DEVICES){fail("device capacity reached");return;}BlazeDevice&d=devices[deviceCount++];d.id=randomHex(12);d.secret=randomHex(24);d.label=enrollLabel;d.lease=n;d.lastSeen=n;d.allowed="*";d.hidden="";d.preferred="";d.timerMode="overlay";d.quick="volume_down,volume_up,floating_timer,network_status,battery_status,bluetooth_status,flashlight";d.revision=1;saveDevices();enrollId="";enrollSecret="";jsonSend("{\"ok\":true,\"device_id\":\""+d.id+"\",\"device_secret\":\""+d.secret+"\",\"server_time_ms\":"+msStr(n)+",\"lease_until_ms\":"+msStr(n)+"}");return;}
    String did=web.arg("device_id");int i=findDevice(did);if(i<0){fail("unknown device");return;}BlazeDevice&d=devices[i];
    if(a=="status"||a=="policy_get"){if(hmac(d.secret,a+"|"+nonce+"|"+d.secret)!=sig){fail("authentication failed");return;}String inv=clean(web.arg("inventory"));if(inv.length()>2048)inv=inv.substring(0,2048);d.inventory=inv;d.lastSeen=n;saveDevices();uint32_t report=max(d.lease,n);String mode=d.unrestricted?"unrestricted":"rental",salt=d.adminSalt,hash=d.adminHash;String legacy=did+"|"+nonce+"|"+msStr(n)+"|"+msStr(report)+"|"+d.allowed+"|"+salt+"|"+hash+"|"+String(d.adminRounds)+"|"+d.preferred+"|"+String(secondsPerPulse);String v2="v2|"+did+"|"+nonce+"|"+msStr(n)+"|"+msStr(report)+"|"+String(d.revision)+"|"+mode+"|"+d.allowed+"|"+d.hidden+"|"+salt+"|"+hash+"|"+String(d.adminRounds)+"|"+d.preferred+"|"+String(secondsPerPulse);String v3="v3|"+did+"|"+nonce+"|"+msStr(n)+"|"+msStr(report)+"|"+String(d.revision)+"|"+mode+"|"+d.allowed+"|"+d.hidden+"|"+salt+"|"+hash+"|"+String(d.adminRounds)+"|"+d.preferred+"|"+String(secondsPerPulse)+"|"+d.timerMode+"|"+String(d.timerToggle?1:0)+"|"+d.quick+"|"+String(d.notifications?1:0)+"|hold|"+String(d.gesture)+"|"+String(d.grace);String out="{\"ok\":true,\"device_id\":\""+did+"\",\"server_time_ms\":"+msStr(n)+",\"lease_until_ms\":"+msStr(report)+",\"policy_revision\":"+String(d.revision)+",\"launcher_mode\":\""+mode+"\",\"allowed_packages\":\""+json(d.allowed)+"\",\"hidden_packages\":\""+json(d.hidden)+"\",\"admin_salt\":\""+salt+"\",\"admin_hash\":\""+hash+"\",\"admin_rounds\":"+String(d.adminRounds)+",\"preferred_vendo\":\""+json(d.preferred)+"\",\"rental_seconds_per_pulse\":"+String(secondsPerPulse)+",\"timer_mode\":\""+d.timerMode+"\",\"timer_user_toggle\":"+String(d.timerToggle?1:0)+",\"quick_controls\":\""+json(d.quick)+"\",\"notifications_enabled\":"+String(d.notifications?1:0)+",\"admin_gesture_type\":\"hold\",\"admin_gesture_value\":"+String(d.gesture)+",\"offline_grace\":"+String(d.grace)+",\"policy_sig\":\""+hmac(d.secret,legacy)+"\",\"policy_sig_v2\":\""+hmac(d.secret,v2)+"\",\"policy_sig_v3\":\""+hmac(d.secret,v3)+"\"}";jsonSend(out);return;}
    if(a=="coin_start"){if(hmac(d.secret,"coin_start|"+nonce+"|"+d.secret)!=sig){fail("authentication failed");return;}int slot=0;if(d.preferred.startsWith("slot"))slot=d.preferred.substring(4).toInt()-1;if(slot<0||slot>=BLAZE_SLOT_COUNT)slot=0;slots[slot].targetDevice=d.id;slots[slot].targetNonce=randomHex(8);slots[slot].targetUntil=n+coinWindow;jsonSend("{\"ok\":true,\"vendo\":\"slot"+String(slot+1)+"\",\"target_nonce\":\""+slots[slot].targetNonce+"\",\"expires\":"+String(slots[slot].targetUntil)+"}");return;}
    fail("unknown rental action");
  }

  void configurePins(){for(int i=0;i<BLAZE_SLOT_COUNT;i++){if(slots[i].pin>=0){pinMode(slots[i].pin,INPUT_PULLUP);slots[i].last=digitalRead(slots[i].pin);}}}
  void scanCoins(){uint32_t n=nowSec();for(int i=0;i<BLAZE_SLOT_COUNT;i++){BlazeSlot&s=slots[i];if(s.pin<0)continue;bool v=digitalRead(s.pin);if(s.last&&!v&&millis()-s.lastEdge>60){s.lastEdge=millis();if(role=="server"&&n&&s.targetUntil>=n&&s.targetDevice.length()){int d=findDevice(s.targetDevice);if(d>=0){devices[d].lease=max(devices[d].lease,n)+secondsPerPulse;saveDevices();event("coin slot"+String(i+1)+" "+s.targetDevice);}}else if(role=="multicoin"&&s.remoteInsert&&s.remoteTarget.length())sendRemoteCoin(i);}s.last=v;}}
  String remoteSig(const String&a,const String&id,const String&nonce,const String&pulses,const String&target){return sha256(remoteKey+"|"+a+"|"+id+"|"+nonce+"|"+pulses+"|"+target+"|"+remoteKey);}
  String extractJson(const String&s,const String&key){String q="\""+key+"\"";int p=s.indexOf(q);if(p<0)return"";p=s.indexOf(':',p);if(p<0)return"";p++;while(p<(int)s.length()&&(s[p]==' '||s[p]=='\"'))p++;int e=p;while(e<(int)s.length()&&s[e]!='\"'&&s[e]!=','&&s[e]!='}')e++;return s.substring(p,e);}
  bool remotePost(const String&body,String&resp){if(WiFi.status()!=WL_CONNECTED||!remoteHost.length()||!remoteKey.length())return false;WiFiClient c;HTTPClient h;String url=remoteHost;if(!url.startsWith("http://"))url="http://"+url;if(url.indexOf(':',7)<0)url+=":4455";url+="/cgi-bin/vendo";if(!h.begin(c,url))return false;h.addHeader("Content-Type","application/x-www-form-urlencoded");int code=h.POST(body);resp=code>0?h.getString():"";h.end();return code==200;}
  void pollRemote(){for(int i=0;i<BLAZE_SLOT_COUNT;i++){String id=baseId+"-"+String(i+1),nonce=randomHex(8),sig=remoteSig("poll",id,nonce,"0",""),resp;String body="action=poll&id="+id+"&nonce="+nonce+"&pulses=0&target=&sig="+sig;if(remotePost(body,resp)){slots[i].remoteInsert=extractJson(resp,"insert")=="1";slots[i].remoteTarget=extractJson(resp,"target_nonce");}else slots[i].remoteInsert=false;}}
  void sendRemoteCoin(int i){String id=baseId+"-"+String(i+1),nonce=randomHex(8),target=slots[i].remoteTarget,sig=remoteSig("coin",id,nonce,"1",target),resp;String body="action=coin&id="+id+"&nonce="+nonce+"&pulses=1&target="+target+"&sig="+sig;remotePost(body,resp);}

  static const char ADMIN_HTML[] PROGMEM;
};

const char BlazeRentalStandalone::ADMIN_HTML[] PROGMEM = R"HTML(
<!doctype html><html><head><meta name=viewport content="width=device-width,initial-scale=1"><title>BlazeRental ESP</title>
<style>body{font:14px system-ui;background:#07111d;color:#eef;margin:0}.w{max-width:900px;margin:auto;padding:16px}.c{background:#0d1b2b;border:1px solid #284057;border-radius:12px;padding:14px;margin:10px 0}input,select,button{font:inherit;padding:9px;border-radius:8px;border:1px solid #35536d;background:#081522;color:#fff;margin:3px}button{cursor:pointer}.p{background:#1ba5e8}.r{display:flex;gap:6px;flex-wrap:wrap}.m{color:#9ab}.d{border-top:1px solid #20394e;padding:9px 0}.mono{font-family:monospace;word-break:break-all}</style></head><body><div class=w><h2>BlazePwifi <span class=m>ESP Standalone Rental Server</span></h2>
<div id=setup class=c style=display:none><h3>First boot setup</h3><input id=np type=password placeholder="Admin password 12+"><input id=ssid placeholder="Optional Wi-Fi SSID"><input id=wp type=password placeholder="Wi-Fi password"><button class=p onclick=setupNow()>Create administrator</button></div>
<div id=login class=c><input id=pw type=password placeholder="Administrator password"><button class=p onclick=loginNow()>Sign in</button><span id=msg class=m></span></div>
<div id=app style=display:none>
<div class=c><div class=r><button onclick=refresh()>Dashboard</button><button onclick=enroll()>New enrollment</button><button onclick=events()>Events</button></div><div id=status class=m></div><div id=token></div></div>
<div class=c><h3>Rental devices</h3><div id=devices></div></div>
<div class=c><h3>Server / MultiCoin role</h3><div class=r><select id=role><option value=server>Standalone Rental Server</option><option value=multicoin>MultiCoin Controller</option></select><input id=remote placeholder="Remote BlazePwifi host"><input id=key placeholder="Vendo key"><input id=base placeholder="Controller base ID"><input id=spp type=number value=600 placeholder="Seconds/pulse"></div><div class=r id=pins></div><button onclick=saveSettings()>Save role/settings</button></div>
</div></div><script>
let S=sessionStorage.s||'';const q=x=>document.querySelector(x),f=o=>{let p=new URLSearchParams;Object.entries(o).forEach(([k,v])=>p.append(k,v));return p};
async function post(u,o,auth=true){let h={'Content-Type':'application/x-www-form-urlencoded'};if(auth)h['X-Blaze-Session']=S;let r=await fetch(u,{method:'POST',headers:h,body:f(o)});return r.json()}
async function loginNow(){let j=await post('/api/login',{password:q('#pw').value},false);if(j.ok){S=j.session;sessionStorage.s=S;show()}else{q('#msg').textContent=j.error;if(j.error==='setup required'){q('#setup').style.display='block'}}}
async function setupNow(){let j=await post('/api/setup',{password:q('#np').value,ssid:q('#ssid').value,wifi_password:q('#wp').value},false);if(j.ok){S=j.session;sessionStorage.s=S;show()}else alert(j.error)}
async function show(){q('#login').style.display='none';q('#setup').style.display='none';q('#app').style.display='block';await post('/api/admin',{action:'time',epoch:Math.floor(Date.now()/1000)});refresh()}
async function refresh(){let s=await post('/api/admin',{action:'status'});if(!s.ok){q('#login').style.display='block';q('#app').style.display='none';return}q('#status').textContent='role '+s.role+' · '+s.devices+' phones · '+s.slots+' coin slots · heap '+s.heap+' · time '+(s.time_sane?'OK':'NOT SET');q('#role').value=s.role;let j=await post('/api/admin',{action:'list'});q('#devices').innerHTML=(j.devices||[]).map(d=>'<div class=d><b>'+d.label+'</b> <span class=mono>'+d.device_id+'</span><br>lease '+new Date(d.lease_until*1000).toLocaleString()+' · '+d.launcher_mode+' · rev '+d.policy_revision+'<div class=r><button onclick="add(\''+d.device_id+'\',600)">+10m</button><button onclick="add(\''+d.device_id+'\',3600)">+1h</button><button onclick="setTime(\''+d.device_id+'\')">Set</button><button onclick="policy(\''+d.device_id+'\',\''+encodeURIComponent(d.allowed_packages)+'\',\''+encodeURIComponent(d.hidden_packages)+'\')">Policy</button><button onclick="devpass(\''+d.device_id+'\')">Device admin</button><button onclick="expire(\''+d.device_id+'\')">Expire</button><button onclick="revoke(\''+d.device_id+'\')">Revoke</button></div></div>').join('')||'<span class=m>No devices</span>';q('#pins').innerHTML='';for(let i=1;i<=s.slots;i++)q('#pins').innerHTML+='<input id=slot'+i+' type=number placeholder="Slot '+i+' GPIO">'}
async function enroll(){let label=prompt('Device label','Rental phone');if(!label)return;let j=await post('/api/admin',{action:'enroll',label});if(j.ok)q('#token').innerHTML='<div class=c><b>Server:</b> http://'+location.host+'<br><b>Token:</b> <span class=mono>'+j.token+'</span><br>Valid 10 minutes.</div>';else alert(j.error)}
async function add(id,s){let j=await post('/api/admin',{action:'add_time',device_id:id,seconds:s});if(!j.ok)alert(j.error);refresh()}
async function setTime(id){let m=prompt('Remaining minutes','60');if(m==null)return;let j=await post('/api/admin',{action:'set_time',device_id:id,seconds:Math.max(0,Math.round(Number(m)*60))});if(!j.ok)alert(j.error);refresh()}
async function expire(id){await post('/api/admin',{action:'expire',device_id:id});refresh()}
async function revoke(id){if(confirm('Revoke device?')){await post('/api/admin',{action:'revoke',device_id:id});refresh()}}
async function policy(id,a,h){a=prompt('Allowed package IDs (* for all)',decodeURIComponent(a));if(a==null)return;h=prompt('Hidden package IDs',decodeURIComponent(h));if(h==null)return;let j=await post('/api/admin',{action:'policy',device_id:id,mode:'rental',allowed:a,hidden:h,timer_mode:'overlay',timer_toggle:1,quick:'volume_down,volume_up,floating_timer,network_status,battery_status,bluetooth_status,flashlight',notifications:1,grace:0});if(!j.ok)alert(j.error);refresh()}
async function devpass(id){let p=prompt('Device admin password 8+');if(!p)return;let j=await post('/api/admin',{action:'device_admin',device_id:id,password:p});if(!j.ok)alert(j.error);refresh()}
async function events(){let j=await post('/api/admin',{action:'events'});alert((j.events||[]).join('\n'))}
async function saveSettings(){let o={action:'settings',role:q('#role').value,remote_host:q('#remote').value,remote_key:q('#key').value,base_id:q('#base').value||'blaze-multi',seconds_per_pulse:q('#spp').value||600,coin_window:120};document.querySelectorAll('[id^=slot]').forEach(x=>o[x.id]=x.value);let j=await post('/api/admin',o);alert(j.ok?'Saved. Reboot recommended.':j.error)}
if(S)show();</script></body></html>
)HTML";
