#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266HTTPClient.h>
#include <EEPROM.h>
#include <bearssl/bearssl_hash.h>

struct Config {
  uint32_t magic;
  char ssid[33], pass[65], server[64], key[65], id[33];
  uint8_t coinPin, insertLedPin, relayPin, coinActiveLow;
};

Config cfg;
ESP8266WebServer web(80);
const uint32_t MAGIC = 0x42505733;

bool insertMode = false, setupAp = false;
uint32_t lastPoll = 0, lastWifiTry = 0;
uint16_t coinSeq = 0;
String targetNonce = "";
volatile bool acceptCoins = false;
volatile uint16_t pulseCount = 0;
volatile uint32_t lastPulseUs = 0;

IRAM_ATTR void onCoinPulse() {
  const uint32_t now = micros();
  if (acceptCoins && (uint32_t)(now - lastPulseUs) > 30000UL) {
    if (pulseCount < 1000) pulseCount++;
    lastPulseUs = now;
  }
}

String hexDigest(const String &s) {
  br_sha256_context c; uint8_t out[32]; char b[65];
  br_sha256_init(&c); br_sha256_update(&c, s.c_str(), s.length()); br_sha256_out(&c, out);
  for (int i = 0; i < 32; i++) sprintf(b + i * 2, "%02x", out[i]);
  b[64] = 0; return String(b);
}

String nonce() {
  char b[17];
  sprintf(b, "%08lx%08lx", (unsigned long)ESP.random(), (unsigned long)micros());
  return String(b);
}

String esc(const String &s) {
  String o;
  for (unsigned i = 0; i < s.length(); i++) {
    char c = s[i];
    if (isalnum(c) || c == '-' || c == '_' || c == '.') o += c;
    else { char b[4]; sprintf(b, "%%%02X", (unsigned char)c); o += b; }
  }
  return o;
}

void defaults() {
  memset(&cfg, 0, sizeof(cfg)); cfg.magic = MAGIC;
  strcpy(cfg.server, "10.0.0.1"); strcpy(cfg.id, "vendo-01");
  cfg.coinPin = 4; cfg.insertLedPin = 14; cfg.relayPin = 5; cfg.coinActiveLow = 1;
}

void loadCfg() {
  EEPROM.begin(sizeof(Config)); EEPROM.get(0, cfg);
  if (cfg.magic != MAGIC) defaults();
}

void saveCfg() { EEPROM.put(0, cfg); EEPROM.commit(); }

bool validPin(int p) { return p >= 0 && p <= 16 && !(p >= 6 && p <= 11); }
bool validCoinPin(int p) { return validPin(p) && p != 16; }

String body(const String &a, const String &p = "0", const String &t = "", const String &q = "0") {
  String n = nonce();
  String base = String(cfg.key) + "|" + a + "|" + cfg.id + "|" + n + "|" + p + "|" + t + "|" + q + "|" + cfg.key;
  return "action=" + a + "&id=" + esc(cfg.id) + "&nonce=" + n + "&pulses=" + p + "&target=" + esc(t) + "&seq=" + q + "&sig=" + hexDigest(base);
}

String post(const String &a, const String &p = "0", const String &t = "", const String &q = "0") {
  if (WiFi.status() != WL_CONNECTED || !strlen(cfg.key)) return "";
  WiFiClient c; HTTPClient h;
  String u = "http://" + String(cfg.server) + ":4455/cgi-bin/vendo";
  if (!h.begin(c, u)) return "";
  h.setTimeout(1800); h.addHeader("Content-Type", "application/x-www-form-urlencoded");
  int code = h.POST(body(a, p, t, q)); String r = code > 0 ? h.getString() : ""; h.end(); return r;
}

bool flag(const String &r, const char *k) {
  String q = String((char)34) + k + (char)34;
  return r.indexOf(q + ":1") >= 0 || r.indexOf(q + ":true") >= 0;
}

String field(const String &r, const char *k) {
  String n = String((char)34) + k + (char)34 + ":";
  int a = r.indexOf(n); if (a < 0) return "";
  a += n.length();
  if (a >= (int)r.length() || r.charAt(a) != 34) return "";
  a++;
  int b = r.indexOf((char)34, a);
  return b < 0 ? "" : r.substring(a, b);
}

void outputs() {
  digitalWrite(cfg.insertLedPin, insertMode ? HIGH : LOW);
  digitalWrite(cfg.relayPin, insertMode ? HIGH : LOW);
}

void startSetupAp() {
  if (setupAp) return;
  setupAp = true;
  String ap = "BlazePwifi-Vendo-" + String(ESP.getChipId(), HEX);
  String pw = "blaze" + String(ESP.getChipId(), HEX);
  WiFi.mode(WIFI_AP_STA); WiFi.softAP(ap.c_str(), pw.c_str());
}

void setupWeb() {
  web.on("/", []() {
    String h = "<meta name=viewport content='width=device-width'><h2>BlazePwifi Vendo</h2><p>Setup AP password: blaze&lt;chipid&gt;</p><form method=POST action=/save>SSID <input name=s value='" + String(cfg.ssid) + "'><br>Password <input name=p type=password><br>Server <input name=server value='" + String(cfg.server) + "'><br>Vendo key <input name=k type=password><br>ID <input name=id value='" + String(cfg.id) + "'><br>Coin GPIO <input name=coin value='" + String(cfg.coinPin) + "'><br>LED GPIO <input name=led value='" + String(cfg.insertLedPin) + "'><br>Relay GPIO <input name=relay value='" + String(cfg.relayPin) + "'><br><button>Save & reboot</button></form><p>STA: " + WiFi.localIP().toString() + "</p>";
    web.send(200, "text/html", h);
  });
  web.on("/save", HTTP_POST, []() {
    int coin = web.arg("coin").toInt(), led = web.arg("led").toInt(), relay = web.arg("relay").toInt();
    if (!validCoinPin(coin) || !validPin(led) || !validPin(relay)) {
      web.send(400, "text/plain", "Invalid GPIO. Avoid flash pins 6-11; GPIO16 cannot be used for coin interrupts."); return;
    }
    strlcpy(cfg.ssid, web.arg("s").c_str(), sizeof(cfg.ssid));
    if (web.arg("p").length()) strlcpy(cfg.pass, web.arg("p").c_str(), sizeof(cfg.pass));
    strlcpy(cfg.server, web.arg("server").c_str(), sizeof(cfg.server));
    if (web.arg("k").length()) strlcpy(cfg.key, web.arg("k").c_str(), sizeof(cfg.key));
    strlcpy(cfg.id, web.arg("id").c_str(), sizeof(cfg.id));
    cfg.coinPin = coin; cfg.insertLedPin = led; cfg.relayPin = relay;
    saveCfg(); web.send(200, "text/plain", "Saved. Rebooting..."); delay(400); ESP.restart();
  });
  web.begin();
}

void tryWifi() {
  if (!strlen(cfg.ssid)) return;
  WiFi.begin(cfg.ssid, cfg.pass); lastWifiTry = millis();
}

void clearPulseBuffer() {
  noInterrupts(); pulseCount = 0; lastPulseUs = micros(); interrupts();
}

void setup() {
  Serial.begin(115200); loadCfg();
  if (!validCoinPin(cfg.coinPin) || !validPin(cfg.insertLedPin) || !validPin(cfg.relayPin)) defaults();
  pinMode(cfg.coinPin, INPUT_PULLUP); pinMode(cfg.insertLedPin, OUTPUT); pinMode(cfg.relayPin, OUTPUT); outputs();
  attachInterrupt(digitalPinToInterrupt(cfg.coinPin), onCoinPulse, cfg.coinActiveLow ? FALLING : RISING);
  WiFi.mode(WIFI_STA); tryWifi();
  uint32_t t = millis(); while (WiFi.status() != WL_CONNECTED && millis() - t < 12000) { delay(200); yield(); }
  if (WiFi.status() != WL_CONNECTED || !strlen(cfg.key)) startSetupAp();
  setupWeb(); if (WiFi.status() == WL_CONNECTED) post("register");
}

void loop() {
  web.handleClient();
  if (WiFi.status() != WL_CONNECTED && strlen(cfg.ssid) && millis() - lastWifiTry > 10000) tryWifi();

  if (WiFi.status() == WL_CONNECTED && millis() - lastPoll > 1500) {
    String r = post("poll"); bool next = flag(r, "insert"); String tn = field(r, "target_nonce");
    if (tn != targetNonce) {
      acceptCoins = false; clearPulseBuffer(); targetNonce = tn; coinSeq = 0;
    }
    insertMode = next && targetNonce.length(); acceptCoins = insertMode; outputs(); lastPoll = millis();
    if (setupAp && millis() > 60000) { WiFi.softAPdisconnect(true); setupAp = false; }
  }

  uint16_t ready = 0; uint32_t lastUs;
  noInterrupts(); ready = pulseCount; lastUs = lastPulseUs; interrupts();
  if (insertMode && ready && (uint32_t)(micros() - lastUs) > 350000UL) {
    uint16_t nextSeq = coinSeq + 1;
    String r = post("coin", String(ready), targetNonce, String(nextSeq));
    if (flag(r, "ok")) {
      noInterrupts(); pulseCount = pulseCount >= ready ? pulseCount - ready : 0; interrupts();
      coinSeq = nextSeq;
    } else delay(250);
  }
  delay(2);
}
