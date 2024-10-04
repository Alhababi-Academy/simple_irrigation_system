// Include necessary libraries
#include <DHT.h>
#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// Firebase project API Key and database URL
#define API_KEY "AIzaSyCpiuMquE1lVZhysN6iFOb8eNLKGLENBNw"
#define DATABASE_URL "simple-irrigation-system-default-rtdb.firebaseio.com/"

// Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;     // FirebaseAuth object is needed
FirebaseConfig config; // FirebaseConfig object

// WiFi credentials
const char* ssid = "ZAYN";
const char* password = "ZRKapril17!!!";

// Pin definitions
const int dht_pin = D1;        // Pin for DHT11 sensor
const int moisture_pin = A0;   // Pin for soil moisture sensor
const int relay_pin = D3;      // Pin for water pump relay
bool signupOK = true;

int temp;
int hum;
int soil_moisture;
bool pumpOn = false;
bool extensionTurnedOff = false;  // Similar to previous example

// Create DHT object
DHT dht(dht_pin, DHT11);

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);

  // Wait for WiFi connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected");

  // Assign the API key and Firebase URL
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  // Sign up and initialize Firebase
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Firebase sign-up successful");
    signupOK = true;
  } else {
    Serial.printf("Firebase sign-up error: %s\n", config.signer.signupError.message.c_str());
  }

  // Initialize Firebase
  config.token_status_callback = tokenStatusCallback;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Initialize DHT sensor
  dht.begin();

  // Set relay pin as output
  pinMode(relay_pin, OUTPUT);
}

void loop() {
  // Read temperature and humidity from the DHT11 sensor
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  // Read soil moisture level from the soil moisture sensor
  soil_moisture = analogRead(moisture_pin);

  // Print sensor values to the serial monitor
  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.println("°C");
  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.println("%");
  Serial.print("Soil Moisture: ");
  Serial.println(soil_moisture);

  // Control water pump based on soil moisture
  if (soil_moisture > 900) {  // Soil is dry, turn off pump
    digitalWrite(relay_pin, HIGH);  // Deactivate the pump
    pumpOn = false;
    Serial.println("Water pump OFF (Soil is dry)");
  } else if (soil_moisture <= 900) {  // Soil is wet, turn on pump
    digitalWrite(relay_pin, LOW);  // Activate the pump
    pumpOn = true;
    Serial.println("Water pump ON (Soil is wet)");
  }

  // Upload temperature, humidity, and soil moisture to Firebase
  if (Firebase.ready()) {
    if (Firebase.RTDB.setFloat(&fbdo, "plant/temperature", temperature)) {
      Serial.println("Temperature sent to Firebase.");
    } else {
      Serial.println("Temperature upload failed.");
    }

    if (Firebase.RTDB.setFloat(&fbdo, "plant/humidity", humidity)) {
      Serial.println("Humidity sent to Firebase.");
    } else {
      Serial.println("Humidity upload failed.");
    }

    if (Firebase.RTDB.setInt(&fbdo, "plant/soil_moisture", soil_moisture)) {
      Serial.println("Soil moisture sent to Firebase.");
    } else {
      Serial.println("Soil moisture upload failed.");
    }

    // Check the extension status from Firebase and update relay state
    if (Firebase.RTDB.getString(&fbdo, "/plant/extension")) {
      String extensionStatus = fbdo.stringData();
      if (extensionStatus == "OFF") {
        Serial.println("Turning off the pump per Firebase.");
        digitalWrite(relay_pin, HIGH);  // Turn off the pump
        extensionTurnedOff = true;
      } else if (extensionStatus == "ON") {
        Serial.println("Turning on the pump per Firebase.");
        if (!extensionTurnedOff) {
          digitalWrite(relay_pin, LOW);  // Turn on the pump
        }
      }
    } else {
      Serial.print("Error reading extension status from Firebase: ");
      Serial.println(fbdo.errorReason());
    }
  }

  delay(2000);  // Delay to avoid rapid switching
}
