#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

const int LED_BUILTIN = 2;

const char* ssid     = "[REDACTED]";
const char* password = "[REDACTED]";

const String appUrl = "https://call-status.herokuapp.com";
String pollUrl;

const char * headerKeys[] = {"location"};

boolean isOnCall = false;

void setup() {
  // Set up onboard LED writing
  pinMode(LED_BUILTIN, OUTPUT);

  // Set up serial console
  Serial.begin(115200);

  // Join the wifi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting to WiFi..");
  }
  Serial.println("Connected to the WiFi network");

  // This seems a little hacky, but it works
  pollUrl = appUrl + "/api/people";
  loop();

  // Register for callback hooks
  String registerUrl = appUrl + "/api/register/" + WiFi.macAddress();
  Serial.println("register url: " + registerUrl);
  HTTPClient http;
  http.begin(registerUrl);
  int httpCode = http.POST("");
  pollUrl = http.getString();
  Serial.println("poll url: " + pollUrl);
  http.end();
}

void flash() {
  for (int i = 0; i < 10; i++) {
    digitalWrite(LED_BUILTIN, HIGH);
    delay(50);
    digitalWrite(LED_BUILTIN, LOW);
    delay(20);
  }
}

void handleResponse(String payload) {
  Serial.println(payload);

  StaticJsonDocument<300> doc;
  auto error = deserializeJson(doc, payload);

  if (error) {
    Serial.print(F("deserializeJson() failed with code "));
    Serial.println(error.c_str());
    return;
  }

  JsonArray array = doc.as<JsonArray>();
  for(JsonVariant v : array) {
    JsonObject object = v.as<JsonObject>();
    const char* name = object["name"];
    std::string str(name);

    if (!str.compare("N")) {
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
    http.setTimeout(60000);
    Serial.println(pollUrl);
    http.begin(pollUrl);
    http.collectHeaders(headerKeys, 1);
    int httpCode = http.GET();

    if (300 <= httpCode && httpCode < 400) {
      http.end();

      String redirectUrl = appUrl + http.header("location");
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
}
