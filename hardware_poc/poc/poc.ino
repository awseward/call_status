#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

HTTPClient http;

const int LED_BUILTIN = 2;

const char* ssid     = "[REDACTED]";
const char* password = "[REDACTED]";

const String urlBase = "https://call-status.herokuapp.com";

const char * headerKeys[] = {"location"};

boolean isOnCall = false;

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(115200);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting to WiFi..");
  }

  Serial.println("Connected to the WiFi network");
}

void flash() {
  for (int i = 0; i < 20; i++) {
    digitalWrite(LED_BUILTIN, HIGH);
    delay(50);
    digitalWrite(LED_BUILTIN, LOW);
    delay(50);
  }
  delay(100);
}

void handleResponse(String payload) {
  Serial.println(payload);

  StaticJsonDocument<300> doc;
  auto error = deserializeJson(doc, payload);

  if (error) {
    Serial.print(F("deserializeJson() failed with code "));
    Serial.println(error.c_str());
    delay(5000);
    return;
  }

  JsonArray array = doc.as<JsonArray>();
  for(JsonVariant v : array) {
    JsonObject object = v.as<JsonObject>();
    const char* name = object["name"];
    std::string str(name);

    if (!str.compare("D")) {
      boolean latestIsOnCall = v["is_on_call"];

      Serial.print("name:     "); Serial.println(name);
      Serial.print("isOnCall: "); Serial.println(latestIsOnCall);

      if (isOnCall != latestIsOnCall) {
        flash();
      }

      isOnCall = latestIsOnCall;

      if (isOnCall) {
        digitalWrite(LED_BUILTIN, HIGH);
      }
      else {
        digitalWrite(LED_BUILTIN, LOW);
      }
    }
  }
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    Serial.println(urlBase + "/api/status");
    http.begin(urlBase + "/api/status");
    http.collectHeaders(headerKeys, 1);
    int httpCode = http.GET();

    if (300 <= httpCode && httpCode < 400) {
      http.end();

      String redirectUrl = urlBase + http.header("location");
      Serial.println(redirectUrl);
      http.begin(redirectUrl);

      int httpCode = http.GET();

      if (200 <= httpCode && httpCode < 300) {
        String payload = http.getString();
        Serial.println(httpCode);
        handleResponse(payload);
      }
      else {
        Serial.print("HTTP error: "); Serial.print(httpCode);
      }
    }
    else if (200 <= httpCode && httpCode < 300) {
      String payload = http.getString();
      Serial.println(httpCode);
      handleResponse(payload);
    }
    else {
      Serial.print("HTTP error: "); Serial.println(httpCode);
    }

    http.end();
  }

  delay(1000);
}
