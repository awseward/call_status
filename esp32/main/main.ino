#include "ArduinoJson.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "HTTPClient.h"
#include "PubSubClient.h"
#include "WiFi.h"

const int LED_WIFI_CONNECTED = 16;
const int LED_P1 = 17;
const int LED_P2 = 18;

const char* ssid     = "[REDACTED]";
const char* password = "[REDACTED]";

const char* mqttHost;
int    mqttPort;
const char* mqttTopic;
const char* mqttClientId;

const char* headerKeys[] = {"location"};

boolean wifiConnected = false;
boolean isOnCallP1 = false;
boolean isOnCallP2 = false;

TaskHandle_t T_loopMqtt;
TaskHandle_t T_loopPeopleLEDs;
TaskHandle_t T_loopWifiLED;
TaskHandle_t T_loopCheckWifiStatus;

WiFiClient espClient;
PubSubClient pubsubClient(espClient);

StaticJsonDocument<500> apiUp() {
  String clientUpUrl = "https://call-status.herokuapp.com/api/client/" + WiFi.macAddress() + "/up";

  HTTPClient http;
  http.begin(clientUpUrl);
  Serial.println("POST " + clientUpUrl);
  int httpCode = http.POST("");

  if (200 <= httpCode && httpCode < 300) {
    String responseBody = http.getString();
    Serial.print(httpCode); Serial.println(" " + responseBody);

    StaticJsonDocument<500> doc;
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
  StaticJsonDocument<500> doc;
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

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived ["); Serial.print(topic); Serial.println("] ");

  String json = "";
  for (int i=0;i<length;i++) {
    json += (char)payload[i];
  }

  handleResponse(json);
}

void loopMqtt(void* parameter) {
  logTaskFnStart("loopMqtt");
  while(true) {
    // TODO: add the reconnect bit
    pubsubClient.loop();
    delay(1000);
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

void loopCheckWifiStatus(void* parameter) {
  logTaskFnStart("loopCheckWifiStatus");
  while(true) {
    wifiConnected = WiFi.status() == WL_CONNECTED;
    delay(10000);
  }
}

void loopWifiLED(void* parameter) {
  logTaskFnStart("loopWifiLED");
  int pin = LED_WIFI_CONNECTED;

  while(true) {
    boolean ledIsOn = digitalRead(pin) == HIGH;
    boolean shouldBeOn = wifiConnected;
    if (ledIsOn == shouldBeOn) { continue; }

    int writeVal = shouldBeOn ? HIGH : LOW;
    //// Commenting this out since it just makes a ton of noise if there's
    //// nothing actually connected to the pin
    // logDigitalWrite(pin, writeVal);
    digitalWrite(pin, writeVal);
    delay(1000);
  }
}

void setup() {
  // Set up  LED pins
  pinMode(LED_WIFI_CONNECTED, OUTPUT);
  pinMode(LED_P1, OUTPUT);
  pinMode(LED_P2, OUTPUT);

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
  apiGet(upResponseJson["app_url"].as<String>());

  mqttHost = upResponseJson["mqtt"]["host"].as<const char*>();
  mqttPort = upResponseJson["mqtt"]["port"].as<int>();
  mqttTopic = upResponseJson["mqtt"]["topic"].as<const char*>();
  mqttClientId = upResponseJson["mqtt"]["client_id"].as<const char*>();

  Serial.print("MQTT host:     "); Serial.println(mqttHost);
  Serial.print("MQTT port:     "); Serial.println(mqttPort);
  Serial.print("MQTT clientId: "); Serial.println(mqttClientId);

  pubsubClient.setServer(mqttHost, mqttPort);
  pubsubClient.setCallback(mqttCallback);

  Serial.println("Connecting to MQTT...");
  pubsubClient.connect(mqttClientId);
  Serial.println("Connected to MQTT");

  Serial.print("Subscribing on MQTT topic "); Serial.println(mqttTopic);
  pubsubClient.subscribe(mqttTopic);

  // Start task which reacts to state by setting LEDs
  xTaskCreatePinnedToCore(loopPeopleLEDs, "T_loopPeopleLEDs", 10000, NULL, 2, &T_loopPeopleLEDs, 1);
  xTaskCreatePinnedToCore(loopWifiLED, "T_loopWifiLED", 10000, NULL, 1, &T_loopWifiLED, 1);

  // Start task which subscribes to MQTT
  xTaskCreatePinnedToCore(loopMqtt, "T_loopMqtt", 10000, NULL, 2, &T_loopMqtt, 0);

  // Set up task that periodically checks wifi status
  xTaskCreatePinnedToCore(
    loopCheckWifiStatus,
    "T_loopCheckWifiStatus",
    10000,
    NULL,
    1,
    &T_loopCheckWifiStatus,
    0
  );
}

void loop() { }
