#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

const int LED_BUILTIN = 2;

const char* ssid     = "[REDACTED]";
const char* password = "[REDACTED]";

String pbUrl;

const char * headerKeys[] = {"location"};

boolean isOnCall = false;

StaticJsonDocument<300> apiUp() {
  String clientUpUrl = "https://call-status.herokuapp.com/api/client/" + WiFi.macAddress() + "/up";

  HTTPClient http;
  http.begin(clientUpUrl);
  Serial.println("POST " + clientUpUrl);
  int httpCode = http.POST("");

  if (200 <= httpCode && httpCode < 300) {
    String responseBody = http.getString();
    Serial.print(httpCode); Serial.println(" " + responseBody);

    StaticJsonDocument<300> doc;
    auto error = deserializeJson(doc, responseBody);
    if (error) {
      Serial.print(F("deserializeJson() failed with code ")); Serial.println(error.c_str());
      throw "FIXME";
    } else {
      return doc;
    }
  }

  throw "FIXME";
}

void setup() {
  // Set up onboard LED writing
  pinMode(LED_BUILTIN, OUTPUT);

  // Set up serial console
  Serial.begin(115200);

  // Join the wifi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to the WiFi network");

  // Register for callback hooks
  auto upResponseJson = apiUp();
  doTheThing(upResponseJson["app_url"].as<String>());
  pbUrl = upResponseJson["pb_url"].as<String>();
}

void flash() {
  for (int i = 0; i < 10; i++) {
    digitalWrite(LED_BUILTIN, HIGH);
    delay(50);
    digitalWrite(LED_BUILTIN, LOW);
    delay(20);
  }
}

void handleResponse(String responseBody) {
  StaticJsonDocument<300> doc;
  auto error = deserializeJson(doc, responseBody);

  if (error) {
    Serial.print(F("deserializeJson() failed with code ")); Serial.println(error.c_str());
    return;
  }

  JsonArray array = doc.as<JsonArray>();
  for(JsonVariant v : array) {
    JsonObject object = v.as<JsonObject>();
    const char* name = object["name"];
    std::string str(name);

    if (!str.compare("N")) {
      boolean latestIsOnCall = v["is_on_call"];

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

void doTheThing(String url) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.setTimeout(60000);
    Serial.println("GET " + url);
    http.begin(url);
    http.collectHeaders(headerKeys, 1);
    int httpCode = http.GET();

    if (200 <= httpCode && httpCode < 300) {
      String responseBody = http.getString();
      Serial.print(httpCode); Serial.println(" " + responseBody);
      handleResponse(responseBody);
    }
    else {
      Serial.print("HTTP error: "); Serial.println(httpCode);
    }

    http.end();
  }
}

void loop() {
  doTheThing(pbUrl);
}
