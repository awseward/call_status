#include <PubSubClient.h>
#include <WebServer.h>
#include <WiFi.h>

const char* mqttServer   = "broker.mqttdashboard.com";
const int mqttPort       = 1883;
const char* mqttTopic    = "call-status/foo/123456";
const char* mqttClientId = "clientId-esp32-o8z7gvkuashd";

const char* ssid       = "[REDACTED]";
const char* password   = "[REDACTED]";

WiFiClient espClient;
PubSubClient client(espClient); // lib required for mqtt

const int LED_BUILTIN = 02;
void setup()
{
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("connected");
  client.setServer(mqttServer, mqttPort); //connecting to mqtt server
  client.setCallback(callback);
  connectmqtt();
}

void callback(char* topic, byte* payload, unsigned int length) {   //callback includes topic and payload ( from which (topic) the payload is comming)
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++)
  {
    Serial.print((char)payload[i]);
  }
  if ((char)payload[0] == 'O' && (char)payload[1] == 'N') //on
  {
    digitalWrite(LED_BUILTIN, HIGH);
  }
  else if ((char)payload[0] == 'O' && (char)payload[1] == 'F' && (char)payload[2] == 'F') //off
  {
    digitalWrite(LED_BUILTIN, LOW);
  }
  Serial.println();
}

void reconnect() {
  while (!client.connected()) {
    Serial.println("Attempting MQTT connection...");
    if (client.connect(mqttClientId)) {
      Serial.println("connected");
      Serial.print("subscribing on "); Serial.println(mqttTopic);
      client.subscribe(mqttTopic);

    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void loop()
{
  // put your main code here, to run repeatedly:
  if (!client.connected())
  {
    reconnect();
  }

  client.loop();
}


void connectmqtt()
{
  client.connect(mqttClientId);  // ESP will connect to mqtt broker with clientID
  {
    Serial.println("connected to MQTT");
    Serial.print("subscribing on "); Serial.println(mqttTopic);
    client.subscribe(mqttTopic);

    if (!client.connected())
    {
      reconnect();
    }
  }
}
