#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>
#include <Preferences.h>
#include <LittleFS.h>
#include <mbedtls/sha256.h>
#include <esp_system.h>

struct Config {
  String ssid, pass, server, key, id, apPass;
  int coinPin=27, insertLedPin=2, relayPin=26;
  bool coinActiveLow=true, relayActiveHigh=true, ledActiveHigh=true;
  uint16_t coinDebounceMs=40, pulseGroupMs=400;
};

struct PendingRecord {
  uint32_t magic;
  uint8_t pulses;
  char nonce[17];
  char target[33];
  uint32_t checksum;
};

static const uint32_t PENDING_MAGIC=0x42504332;
Config cfg;
Preferences prefs;
WebServer web(80);
bool insertMode=false, lastCoin=false, pendingReady=false, fsReady=false;
uint32_t lastPoll=0, lastEdge=0, lastSend=0, configuredApSince=0;
uint8_t pendingPulses=0;
String activeTarget, pendingTarget, pendingNonce;

String hexDigest(const String &s){
  unsigned char out[32]; char buf[65];
  mbedtls_sha256_context c;
  mbedtls_sha256_init(&c);
  mbedtls_sha256_starts(&c,0);
  mbedtls_sha256_update(&c,(const unsigned char*)s.c_str(),s.length());
  mbedtls_sha256_finish(&c,out);
  mbedtls_sha256_free(&c);
  for(int i=0;i<32;i++) sprintf(buf+i*2,"%02x",out[i]);
  buf[64]=0; return String(buf);
}

String freshNonce(){
  char b[17];
  snprintf(b,sizeof(b),"%08lx%08lx",(unsigned long)esp_random(),(unsigned long)esp_random());
  return String(b);
}

String esc(const String &s){
  String o;
  for(size_t i=0;i<s.length();i++){
    char c=s[i];
    if(isalnum((unsigned char)c)||c=='-'||c=='_'||c=='.') o+=c;
    else { char b[4]; snprintf(b,sizeof(b),"%%%02X",(unsigned char)c); o+=b; }
  }
  return o;
}

uint32_t pendingChecksum(const PendingRecord &r){
  const uint8_t *p=(const uint8_t*)&r; uint32_t h=2166136261UL;
  for(size_t i=0;i<offsetof(PendingRecord,checksum);i++){ h^=p[i]; h*=16777619UL; }
  return h;
}

bool readPendingFile(const char *path, PendingRecord &r){
  if(!fsReady || !LittleFS.exists(path)) return false;
  File f=LittleFS.open(path,"r"); if(!f) return false;
  size_t n=f.readBytes((char*)&r,sizeof(r)); f.close();
  return n==sizeof(r) && r.magic==PENDING_MAGIC && r.pulses>0 && r.pulses<=20 &&
         r.checksum==pendingChecksum(r) && strlen(r.nonce)>=8 && strlen(r.target)>=8;
}

bool savePending(){
  if(!fsReady || pendingPulses==0 || pendingNonce.isEmpty() || pendingTarget.isEmpty()) return false;
  PendingRecord r{}; r.magic=PENDING_MAGIC; r.pulses=pendingPulses;
  strlcpy(r.nonce,pendingNonce.c_str(),sizeof(r.nonce));
  strlcpy(r.target,pendingTarget.c_str(),sizeof(r.target));
  r.checksum=pendingChecksum(r);
  File f=LittleFS.open("/pending.new","w"); if(!f) return false;
  size_t n=f.write((const uint8_t*)&r,sizeof(r)); f.flush(); f.close();
  if(n!=sizeof(r)){ LittleFS.remove("/pending.new"); return false; }
  LittleFS.remove("/pending.bak");
  if(LittleFS.exists("/pending.dat")) LittleFS.rename("/pending.dat","/pending.bak");
  if(!LittleFS.rename("/pending.new","/pending.dat")){
    if(LittleFS.exists("/pending.bak")) LittleFS.rename("/pending.bak","/pending.dat");
    return false;
  }
  LittleFS.remove("/pending.bak");
  return true;
}

void loadPending(){
  PendingRecord r{}; const char *chosen=nullptr;
  if(readPendingFile("/pending.dat",r)) chosen="/pending.dat";
  else if(readPendingFile("/pending.new",r)) chosen="/pending.new";
  else if(readPendingFile("/pending.bak",r)) chosen="/pending.bak";
  if(!chosen) return;
  pendingPulses=r.pulses; pendingNonce=String(r.nonce); pendingTarget=String(r.target);
  pendingReady=true; lastSend=0;
  if(strcmp(chosen,"/pending.dat")!=0){ LittleFS.remove("/pending.dat"); LittleFS.rename(chosen,"/pending.dat"); }
  Serial.println("Recovered unacknowledged coin event from flash.");
}

void clearPending(){
  pendingPulses=0; pendingReady=false; pendingNonce=""; pendingTarget=""; lastSend=0;
  if(fsReady){ LittleFS.remove("/pending.dat"); LittleFS.remove("/pending.new"); LittleFS.remove("/pending.bak"); }
}

void loadConfig(){
  prefs.begin("blazevendo",false);
  cfg.ssid=prefs.getString("ssid","");
  cfg.pass=prefs.getString("pass","");
  cfg.server=prefs.getString("server","10.0.0.1");
  cfg.key=prefs.getString("key","");
  cfg.id=prefs.getString("id","vendo-01");
  cfg.apPass=prefs.getString("appass","");
  cfg.coinPin=prefs.getInt("coinpin",27);
  cfg.insertLedPin=prefs.getInt("ledpin",2);
  cfg.relayPin=prefs.getInt("relaypin",26);
  cfg.coinActiveLow=prefs.getBool("coinlow",true);
  cfg.relayActiveHigh=prefs.getBool("relayhi",true);
  cfg.ledActiveHigh=prefs.getBool("ledhi",true);
  cfg.coinDebounceMs=(uint16_t)prefs.getUInt("debounce",40);
  cfg.pulseGroupMs=(uint16_t)prefs.getUInt("groupms",400);
  if(cfg.apPass.length()<8){
    char b[17]; snprintf(b,sizeof(b),"%08lX%08lX",(unsigned long)esp_random(),(unsigned long)esp_random());
    cfg.apPass=String(b); prefs.putString("appass",cfg.apPass);
  }
}

void saveConfig(){
  prefs.putString("ssid",cfg.ssid); prefs.putString("pass",cfg.pass);
  prefs.putString("server",cfg.server); prefs.putString("key",cfg.key); prefs.putString("id",cfg.id);
  prefs.putInt("coinpin",cfg.coinPin); prefs.putInt("ledpin",cfg.insertLedPin); prefs.putInt("relaypin",cfg.relayPin);
  prefs.putBool("coinlow",cfg.coinActiveLow); prefs.putBool("relayhi",cfg.relayActiveHigh); prefs.putBool("ledhi",cfg.ledActiveHigh);
  prefs.putUInt("debounce",cfg.coinDebounceMs); prefs.putUInt("groupms",cfg.pulseGroupMs);
}

String jsonString(const String &r,const String &k){
  String n="\""+k+"\":\""; int p=r.indexOf(n); if(p<0) return "";
  p+=n.length(); int e=r.indexOf('"',p); if(e<0) return ""; return r.substring(p,e);
}
bool jsonTrue(const String &r,const String &k){ return r.indexOf("\""+k+"\":1")>=0 || r.indexOf("\""+k+"\":true")>=0; }

String signedBody(const String &action,const String &pulses,const String &target,const String &forcedNonce=""){
  String n=forcedNonce.length()?forcedNonce:freshNonce();
  String base=cfg.key+"|"+action+"|"+cfg.id+"|"+n+"|"+pulses+"|"+target+"|"+cfg.key;
  return "action="+action+"&id="+esc(cfg.id)+"&nonce="+n+"&pulses="+pulses+"&target="+esc(target)+"&sig="+hexDigest(base);
}

String post(const String &action,const String &pulses="0",const String &target="",const String &forcedNonce=""){
  if(WiFi.status()!=WL_CONNECTED) return "";
  WiFiClient client; HTTPClient h;
  String url="http://"+cfg.server+":4455/cgi-bin/vendo";
  if(!h.begin(client,url)) return "";
  h.setTimeout(3500); h.addHeader("Content-Type","application/x-www-form-urlencoded");
  int code=h.POST(signedBody(action,pulses,target,forcedNonce));
  String r=code>0?h.getString():""; h.end(); return r;
}

void writeLogical(int pin,bool on,bool activeHigh){ digitalWrite(pin,(on==activeHigh)?HIGH:LOW); }
void applyOutputs(){
  bool accepting=insertMode && fsReady && !pendingReady;
  writeLogical(cfg.insertLedPin,accepting,cfg.ledActiveHigh);
  writeLogical(cfg.relayPin,accepting,cfg.relayActiveHigh);
}

void setupPortal(){
  String suffix=String((uint32_t)(ESP.getEfuseMac() & 0xffffffffULL),HEX);
  String ap="BlazePwifi-Vendo32-"+suffix;
  WiFi.mode(WIFI_AP_STA); WiFi.softAP(ap.c_str(),cfg.apPass.c_str());
  Serial.println("BlazePwifi ESP32 setup AP: "+ap);
  Serial.println("Setup code: "+cfg.apPass);
  web.on("/",[](){
    String h="<meta name=viewport content='width=device-width'><h2>BlazePwifi ESP32 Vendo</h2><form method=POST action=/save>"
      "SSID <input name=s value='"+cfg.ssid+"'><br>WiFi credential <input name=p type=password><br>"
      "Server <input name=server value='"+cfg.server+"'><br>Controller key <input name=k type=password><br>"
      "ID <input name=id value='"+cfg.id+"'><br>Coin GPIO <input name=coin value='"+String(cfg.coinPin)+"'><br>"
      "LED GPIO <input name=led value='"+String(cfg.insertLedPin)+"'><br>Relay GPIO <input name=relay value='"+String(cfg.relayPin)+"'><br>"
      "Debounce ms <input name=db value='"+String(cfg.coinDebounceMs)+"'><br>Pulse group ms <input name=pg value='"+String(cfg.pulseGroupMs)+"'><br>"
      "Coin active low <input name=cl value='"+String(cfg.coinActiveLow?1:0)+"'><br>"
      "Relay active high <input name=rh value='"+String(cfg.relayActiveHigh?1:0)+"'><br>"
      "LED active high <input name=lh value='"+String(cfg.ledActiveHigh?1:0)+"'><br><button>Save & reboot</button></form>";
    web.send(200,"text/html",h);
  });
  web.on("/save",HTTP_POST,[](){
    cfg.ssid=web.arg("s"); if(web.arg("p").length()) cfg.pass=web.arg("p");
    cfg.server=web.arg("server"); if(web.arg("k").length()) cfg.key=web.arg("k"); cfg.id=web.arg("id");
    cfg.coinPin=web.arg("coin").toInt(); cfg.insertLedPin=web.arg("led").toInt(); cfg.relayPin=web.arg("relay").toInt();
    cfg.coinDebounceMs=max(1,web.arg("db").toInt()); cfg.pulseGroupMs=max(10,web.arg("pg").toInt());
    cfg.coinActiveLow=web.arg("cl")!="0"; cfg.relayActiveHigh=web.arg("rh")!="0"; cfg.ledActiveHigh=web.arg("lh")!="0";
    saveConfig(); web.send(200,"text/plain","Saved. Rebooting..."); delay(500); ESP.restart();
  });
  web.begin(); configuredApSince=millis();
}

void connectSta(){
  if(cfg.ssid.isEmpty()) return;
  WiFi.begin(cfg.ssid.c_str(),cfg.pass.c_str());
  uint32_t t=millis();
  while(WiFi.status()!=WL_CONNECTED && millis()-t<12000){ delay(250); }
  if(WiFi.status()==WL_CONNECTED) post("register");
}

void setup(){
  Serial.begin(115200); loadConfig();
  fsReady=LittleFS.begin(true); if(fsReady) loadPending();
  else Serial.println("CRITICAL: LittleFS unavailable; relay remains disabled.");
  pinMode(cfg.coinPin,INPUT_PULLUP); pinMode(cfg.insertLedPin,OUTPUT); pinMode(cfg.relayPin,OUTPUT);
  writeLogical(cfg.insertLedPin,false,cfg.ledActiveHigh); writeLogical(cfg.relayPin,false,cfg.relayActiveHigh);
  setupPortal(); connectSta();
}

void loop(){
  web.handleClient();
  if(WiFi.status()!=WL_CONNECTED && !cfg.ssid.isEmpty() && millis()-lastPoll>10000){
    WiFi.disconnect(); WiFi.begin(cfg.ssid.c_str(),cfg.pass.c_str()); lastPoll=millis();
  }
  if(WiFi.status()==WL_CONNECTED && millis()-lastPoll>1500){
    String r=post("poll"); insertMode=jsonTrue(r,"insert"); activeTarget=jsonString(r,"target_nonce");
    applyOutputs(); lastPoll=millis();
  }

  bool raw=digitalRead(cfg.coinPin);
  bool active=cfg.coinActiveLow?!raw:raw;
  if(insertMode && fsReady && activeTarget.length() && !pendingReady && active && !lastCoin && millis()-lastEdge>cfg.coinDebounceMs){
    if(pendingPulses==0){ pendingNonce=freshNonce(); pendingTarget=activeTarget; }
    if(pendingTarget==activeTarget && pendingPulses<20){
      pendingPulses++; lastEdge=millis();
      if(!savePending()){ fsReady=false; pendingReady=true; Serial.println("CRITICAL: pending journal write failed; relay disabled."); }
    }
  }
  lastCoin=active;
  if(pendingPulses && !pendingReady && millis()-lastEdge>cfg.pulseGroupMs){ pendingReady=true; lastSend=0; applyOutputs(); }
  if(pendingPulses && pendingReady && WiFi.status()==WL_CONNECTED && (lastSend==0 || millis()-lastSend>900)){
    String r=post("coin",String(pendingPulses),pendingTarget,pendingNonce); lastSend=millis();
    if(r.indexOf("\"ok\":true")>=0 ||
       r.indexOf("coin window expired")>=0 || r.indexOf("coin target mismatch")>=0 ||
       r.indexOf("no active coin window")>=0 || r.indexOf("another vendo selected")>=0){
      clearPending(); applyOutputs();
    }
  }
  if(!cfg.ssid.isEmpty() && WiFi.status()==WL_CONNECTED && millis()-configuredApSince>600000UL) WiFi.softAPdisconnect(true);
  delay(2);
}
