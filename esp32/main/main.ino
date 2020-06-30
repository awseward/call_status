#include "ArduinoJson.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "HTTPClient.h"
#include "PubSubClient.h"
#include "WiFi.h"

const int LED_BUILTIN = 2;
const int LED_WIFI_CONNECTED = 16;
const int LED_P1 = 17;
const int LED_P2 = 18;

const char* ssid     = "[REDACTED]";
const char* password = "[REDACTED]";

const char* mqttHost;
int mqttPort;
const char* mqttClientId;
const char* mqttTopic;

boolean wifiConnected = false;
boolean isOnCallP1 = false;
boolean isOnCallP2 = false;

TaskHandle_t T_loopMqtt;
TaskHandle_t T_loopInidicatorPeople;
TaskHandle_t T_loopIndicatorWifi;
TaskHandle_t T_loopWifi;

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

void startupFlash() {
  std::array<int,4> allLEDs = {
    LED_BUILTIN,
    LED_WIFI_CONNECTED,
    LED_P1,
    LED_P2
  };

  for (int j = 0; j < allLEDs.size(); j++) {
    int pin = allLEDs[j];
    digitalWrite(pin, HIGH);
    delay(500);
  }

  delay(500);

  for (int j = 0; j < allLEDs.size(); j++) {
    int pin = allLEDs[j];
    digitalWrite(pin, LOW);
  }

  delay(250);

  for (int j = 0; j < allLEDs.size(); j++) {
    int pin = allLEDs[j];
    digitalWrite(pin, HIGH);
  }

  delay(250);

  for (int j = 0; j < allLEDs.size(); j++) {
    int pin = allLEDs[j];
    digitalWrite(pin, LOW);
  }
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

void connectMqtt() {
  Serial.println("Connecting to MQTT...");
  pubsubClient.connect(mqttClientId);
  while (!pubsubClient.connected()) {
    delay(500);
    Serial.println("Connecting to MQTT...");
    pubsubClient.connect(mqttClientId);
  }
  Serial.println("Connected to MQTT");

  Serial.print("Subscribing on MQTT topic "); Serial.println(mqttTopic);
  pubsubClient.subscribe(mqttTopic, 1);
}

void loopMqtt(void* parameter) {
  logTaskFnStart("loopMqtt");
  while(true) {
    if (!pubsubClient.connected()) {
      Serial.println("Reconnecting to MQTT");
      connectMqtt();
    }
    pubsubClient.loop();
    vTaskDelay(10);
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

void loopIndicatePeopleStatuses(void* parameter) {
  logTaskFnStart("loopIndicatePeopleStatuses");

  while(true) {
    reconcileLED(LED_P1, isOnCallP1);
    reconcileLED(LED_P2, isOnCallP2);

    delay(200);
  }
}

void captureWifiStatus() {
  wifiConnected = WiFi.status() == WL_CONNECTED;
}

void indicateWifiStatus() {
  int pin = LED_WIFI_CONNECTED;
  boolean ledIsOn = digitalRead(pin) == HIGH;
  boolean shouldBeOn = wifiConnected;
  if (ledIsOn == shouldBeOn) { return; }

  int writeVal = shouldBeOn ? HIGH : LOW;
  logDigitalWrite(pin, writeVal);
  digitalWrite(pin, writeVal);
}

void loopCheckWifiStatus(void* parameter) {
  logTaskFnStart("loopCheckWifiStatus");
  while(true) {
    captureWifiStatus();
    delay(10000);
  }
}

void loopInidcatorWifi(void* parameter) {
  logTaskFnStart("loopInidcatorWifi");

  while(true) {
    indicateWifiStatus();
    delay(1000);
  }
}

void setup() {
  // Set up  LED pins
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(LED_WIFI_CONNECTED, OUTPUT);
  pinMode(LED_P1, OUTPUT);
  pinMode(LED_P2, OUTPUT);

  // Do a quick pseudo-diagnostic "flash all LEDs" kind of thing
  startupFlash();

  // Set up serial console
  Serial.begin(115200);

  // Join the wifi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to the WiFi network");
  captureWifiStatus();
  indicateWifiStatus();

  // Register for callback hooks
  auto upJson = apiUp();
  mqttHost = upJson["mqtt"]["host"].as<const char*>();
  mqttPort = upJson["mqtt"]["port"].as<int>();
  mqttTopic = upJson["mqtt"]["topic"].as<const char*>();
  mqttClientId = upJson["mqtt"]["client_id"].as<const char*>();

  Serial.print("MQTT host:     "); Serial.println(mqttHost);
  Serial.print("MQTT port:     "); Serial.println(mqttPort);
  Serial.print("MQTT clientId: "); Serial.println(mqttClientId);

  pubsubClient.setServer(mqttHost, mqttPort);
  pubsubClient.setCallback(mqttCallback);
  connectMqtt();

  // Start task which manages wifi status indication
  xTaskCreatePinnedToCore(loopInidcatorWifi, "T_loopIndicatorWifi", 10000, NULL, 1, &T_loopIndicatorWifi, 1);

  // Start task which manages people statuses indication
  xTaskCreatePinnedToCore(loopIndicatePeopleStatuses, "T_loopInidicatorPeople", 10000, NULL, 2, &T_loopInidicatorPeople, 1);

  // Start task which subscribes to MQTT
  xTaskCreatePinnedToCore(loopMqtt, "T_loopMqtt", 10000, NULL, 2, &T_loopMqtt, 0);

  // Set up task that periodically checks wifi status
  xTaskCreatePinnedToCore(loopCheckWifiStatus, "T_loopWifi", 10000, NULL, 1, &T_loopWifi, 0);
}

void loop() { }
