#include "WiFi.h"
#include "HTTPClient.h"
#include "ArduinoJson.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

const int LED_BUILTIN = 2;
const int LED_WIFI_CONNECTED = 16;
const int LED_P1 = 17;
const int LED_P2 = LED_BUILTIN;

const char* ssid     = "[REDACTED]";
const char* password = "[REDACTED]";

String pbUrl;

const char * headerKeys[] = {"location"};

boolean isOnCallP1 = false;
boolean isOnCallP2 = false;

TaskHandle_t Task1;
TaskHandle_t Task2;
TaskHandle_t Task3;

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

void flash(int pin) {
  for (int i = 0; i < 25; i++) {
    digitalWrite(pin, HIGH);
    delay(75);
    digitalWrite(pin, LOW);
    delay(25);
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

    if (!str.compare("D")) {
      isOnCallP1 = v["is_on_call"];
    } else if (!str.compare("N")) {
      isOnCallP2 = v["is_on_call"];
    }
  }
}

void apiGet(String url) {
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

void loopApi(void* parameter) {
  logTaskFnStart("loopApi");
  while(true) {
    apiGet(pbUrl);
  }
}

void logTaskFnStart(String fnName) {
  Serial.print("Task function `"); Serial.print(fnName); Serial.print("` running on core: "); Serial.println(xPortGetCoreID());
}

void logDigitalWrite(int pin, int value) {
  Serial.print("Setting pin "); Serial.print(pin); Serial.print(" to: "); Serial.println(value);
}

void reconcileLED(int pin, boolean shouldBeOn) {
  boolean ledIsOn = digitalRead(pin) == HIGH;
  if (ledIsOn == shouldBeOn) { return; }

  int writeVal = shouldBeOn ? HIGH : LOW;
  logDigitalWrite(pin, writeVal);
  flash(pin);
  digitalWrite(pin, writeVal);
}

void loopPeopleLEDs(void* parameter) {
  logTaskFnStart("loopPeopleLEDs");

  while(true) {
    reconcileLED(LED_P1, isOnCallP1);
    reconcileLED(LED_P2, isOnCallP2);

    delay(200);
  }
}

void loopWifiLED(void* parameter) {
  logTaskFnStart("loopWifiLED");
  int pin = LED_WIFI_CONNECTED;

  while(true) {
    boolean ledIsOn = digitalRead(pin) == HIGH;
    boolean shouldBeOn = WiFi.status() == WL_CONNECTED;
    if (ledIsOn == shouldBeOn) { continue; }

    int writeVal = shouldBeOn ? HIGH : LOW;
    //// Commenting this out since it just makes a ton of noise if there's
    //// nothing actually connected to the pin
    // logDigitalWrite(pin, writeVal);
    digitalWrite(pin, writeVal);
    delay(200);
  }
}

void setup() {
  // Set up  LED pins
  pinMode(LED_WIFI_CONNECTED, OUTPUT);
  pinMode(LED_P1, OUTPUT);
  pinMode(LED_P2, OUTPUT);

  // Set up serial console
  Serial.begin(115200);

  // Start task which reacts to state by setting LEDs
  xTaskCreatePinnedToCore(loopPeopleLEDs, "Task2", 10000, NULL, 2, &Task2, 1);
  xTaskCreatePinnedToCore(loopWifiLED, "Task3", 10000, NULL, 1, &Task3, 1);

  // Join the wifi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to the WiFi network");

  // Register for callback hooks
  auto upResponseJson = apiUp();
  apiGet(upResponseJson["app_url"].as<String>());
  pbUrl = upResponseJson["pb_url"].as<String>();

  // Start task which polls API requests
  xTaskCreatePinnedToCore(loopApi, "Task1", 10000, NULL, 1, &Task1, 0);
}

void loop() { }
