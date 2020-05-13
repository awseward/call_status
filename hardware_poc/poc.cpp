#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

HTTPClient http;

const int LED_BUILTIN = 2;

const char* ssid     = "[REDACTED]";
const char* password = "[REDACTED]";

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

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    http.begin("https://call-status.herokuapp.com/api/status");
    int httpCode = http.GET();

    if (200 <= httpCode && httpCode < 300) {
      String payload = http.getString();
      Serial.println(httpCode);
      Serial.println(payload);

      StaticJsonDocument<300> doc;
      auto error = deserializeJson(doc, payload);

      if (error) {
        Serial.print(F("deserializeJson() failed with code ")); Serial.println(error.c_str());
        delay(5000);
        return;
      }

      JsonArray array = doc.as<JsonArray>();
      for(JsonVariant v : array) {
        JsonObject object = v.as<JsonObject>();
        const char* name = object["name"];
        std::string str(name);

        if (!str.compare("D")) {
            boolean isOnCall = v["is_on_call"];

            Serial.print("name:     "); Serial.println(name);
            Serial.print("isOnCall: "); Serial.println(isOnCall);

            if (isOnCall) {
              digitalWrite(LED_BUILTIN, HIGH);
            }
            else {
              digitalWrite(LED_BUILTIN, LOW);
            }
        }
      }
    }
    else {
      Serial.println("HTTP error:" + httpCode);
    }

    http.end();
  }

  delay(1000);
}
