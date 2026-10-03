#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266HTTPClient.h>
#include <EEPROM.h>
#include <bearssl/bearssl_hash.h>

struct Config {
  uint32_t magic;
  char ssid[33];
  char pass[65];
  char server[64];
  char key[65];
  char id[33];
  uint8_t coinPin;
  uint8_t insertLedPin;
  uint8_t relayPin;
  uint8_t coinActiveLow;
};
Config cfg;
ESP8266WebServer web(80);
const uint32_t MAGIC=0x42505731;
bool insertMode=false, lastCoin=false;
uint32_t lastPoll=0, lastEdge=0;
uint8_t pulseCount=0;

String hexDigest(const String &s){
  br_sha256_context c; uint8_t out[32]; char buf[65];
  br_sha256_init(&c); br_sha256_update(&c,s.c_str(),s.length()); br_sha256_out(&c,out);
  for(int i=0;i<32;i++) sprintf(buf+i*2,"%02x",out[i]); buf[64]=0; return String(buf);
}
String nonce(){ char b[17]; uint32_t a=ESP.random(),c=micros(); sprintf(b,"%08lx%08lx",(unsigned long)a,(unsigned long)c); return String(b); }
String esc(const String &s){ String o; for(unsigned i=0;i<s.length();i++){char c=s[i]; if(isalnum(c)||c=='-'||c=='_'||c=='.')o+=c; else {char b[4];sprintf(b,"%%%02X",(unsigned char)c);o+=b;}} return o; }
void loadCfg(){ EEPROM.begin(sizeof(Config)); EEPROM.get(0,cfg); if(cfg.magic!=MAGIC){ memset(&cfg,0,sizeof(cfg)); cfg.magic=MAGIC; strcpy(cfg.server,"10.0.0.1"); strcpy(cfg.id,"vendo-01"); cfg.coinPin=4; cfg.insertLedPin=14; cfg.relayPin=5; cfg.coinActiveLow=1; }}
void saveCfg(){ EEPROM.put(0,cfg); EEPROM.commit(); }
String signedBody(const String& action,const String& pulses){ String n=nonce(); String base=String(cfg.key)+"|"+action+"|"+cfg.id+"|"+n+"|"+pulses+"|"+cfg.key; return "action="+action+"&id="+esc(cfg.id)+"&nonce="+n+"&pulses="+pulses+"&sig="+hexDigest(base); }
String post(const String& action,const String& pulses="0"){
  if(WiFi.status()!=WL_CONNECTED) return ""; WiFiClient client; HTTPClient h;
  String url="http://"+String(cfg.server)+":4455/cgi-bin/vendo"; if(!h.begin(client,url)) return "";
  h.addHeader("Content-Type","application/x-www-form-urlencoded"); int code=h.POST(signedBody(action,pulses)); String r=code>0?h.getString():""; h.end(); return r;
}
bool jsonTrue(const String&r,const String&k){ return r.indexOf("\""+k+"\":1")>=0 || r.indexOf("\""+k+"\":true")>=0; }
void applyOutputs(){ digitalWrite(cfg.insertLedPin,insertMode?HIGH:LOW); digitalWrite(cfg.relayPin,insertMode?HIGH:LOW); }
void setupPortal(){
  String ap="BlazePwifi-Vendo-"+String(ESP.getChipId(),HEX); WiFi.mode(WIFI_AP_STA); WiFi.softAP(ap.c_str());
  web.on("/",[](){ String h="<meta name=viewport content='width=device-width'><h2>BlazePwifi Vendo</h2><form method=POST action=/save>SSID <input name=s value='"+String(cfg.ssid)+"'><br>Password <input name=p type=password><br>Server <input name=server value='"+String(cfg.server)+"'><br>Vendo key <input name=k type=password><br>ID <input name=id value='"+String(cfg.id)+"'><br>Coin GPIO <input name=coin value='"+String(cfg.coinPin)+"'><br>LED GPIO <input name=led value='"+String(cfg.insertLedPin)+"'><br>Relay GPIO <input name=relay value='"+String(cfg.relayPin)+"'><br><button>Save & reboot</button></form><p>STA: "+WiFi.localIP().toString()+"</p>"; web.send(200,"text/html",h); });
  web.on("/save",HTTP_POST,[](){ strlcpy(cfg.ssid,web.arg("s").c_str(),sizeof(cfg.ssid)); if(web.arg("p").length())strlcpy(cfg.pass,web.arg("p").c_str(),sizeof(cfg.pass)); strlcpy(cfg.server,web.arg("server").c_str(),sizeof(cfg.server)); if(web.arg("k").length())strlcpy(cfg.key,web.arg("k").c_str(),sizeof(cfg.key)); strlcpy(cfg.id,web.arg("id").c_str(),sizeof(cfg.id)); cfg.coinPin=web.arg("coin").toInt(); cfg.insertLedPin=web.arg("led").toInt(); cfg.relayPin=web.arg("relay").toInt(); saveCfg(); web.send(200,"text/plain","Saved. Rebooting..."); delay(500); ESP.restart(); }); web.begin();
}
void connectSta(){ if(!strlen(cfg.ssid))return; WiFi.begin(cfg.ssid,cfg.pass); uint32_t t=millis(); while(WiFi.status()!=WL_CONNECTED && millis()-t<12000){delay(250);yield();} if(WiFi.status()==WL_CONNECTED) post("register"); }
void setup(){ Serial.begin(115200); loadCfg(); pinMode(cfg.coinPin,INPUT_PULLUP); pinMode(cfg.insertLedPin,OUTPUT); pinMode(cfg.relayPin,OUTPUT); digitalWrite(cfg.insertLedPin,LOW); digitalWrite(cfg.relayPin,LOW); setupPortal(); connectSta(); }
void loop(){
  web.handleClient();
  if(WiFi.status()!=WL_CONNECTED && strlen(cfg.ssid) && millis()-lastPoll>10000){ WiFi.disconnect(); WiFi.begin(cfg.ssid,cfg.pass); lastPoll=millis(); }
  if(WiFi.status()==WL_CONNECTED && millis()-lastPoll>1500){ String r=post("poll"); insertMode=jsonTrue(r,"insert"); applyOutputs(); lastPoll=millis(); }
  bool raw=digitalRead(cfg.coinPin); bool active=cfg.coinActiveLow?!raw:raw;
  if(insertMode && active && !lastCoin && millis()-lastEdge>35){ pulseCount++; lastEdge=millis(); }
  lastCoin=active;
  if(pulseCount && millis()-lastEdge>350){ String r=post("coin",String(pulseCount)); if(r.indexOf("\"ok\":true")>=0) pulseCount=0; else { delay(500); } }
  delay(2);
}
