#include "WiFi.h"
#include "HTTPClient.h"
#include "ArduinoJson.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

const int LED_BUILTIN = 2;

const char* ssid     = "[REDACTED]";
const char* password = "[REDACTED]";

String pbUrl;

const char * headerKeys[] = {"location"};

boolean isOnCall = false;

TaskHandle_t Task1;
TaskHandle_t Task2;

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

    if (!str.compare("N")) {
      isOnCall = v["is_on_call"];
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
  Serial.print("loopApi() function running on core: "); Serial.println(xPortGetCoreID());
  while(true) {
    apiGet(pbUrl);
  }
}

void loopLEDs(void* parameter) {
  Serial.print("loopLEDs() function running on core: "); Serial.println(xPortGetCoreID());
  while(true) {
    boolean ledIsOn = digitalRead(LED_BUILTIN) == HIGH;

    if (ledIsOn == isOnCall) { continue; }

    int writeVal;
    if (isOnCall) {
      writeVal = HIGH;
    } else {
      writeVal = LOW;
    }

    flash(LED_BUILTIN);
    digitalWrite(LED_BUILTIN, writeVal);
    delay(100);
  }
}

void setup() {
  // Set up onboard LED writing
  pinMode(LED_BUILTIN, OUTPUT);

  // Set up serial console
  Serial.begin(115200);

  Serial.print("setup() function running on core: "); Serial.println(xPortGetCoreID());

  // Start task which reacts to state by setting LEDs
  xTaskCreatePinnedToCore(loopLEDs, "Task2", 10000, NULL, 1, &Task2, 1);

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
