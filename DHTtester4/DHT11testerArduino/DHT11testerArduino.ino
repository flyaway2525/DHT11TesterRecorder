
//reference：https://ameblo.jp/empsgs/entry-12085718684.html
//Sensor's prerequisite library : https://github.com/adafruit/Adafruit_Sensor
//Sensor library : https://github.com/adafruit/DHT-sensor-library

#include "DHT.h"
#define DHTPIN 4
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(9600);
  Serial.println("DHT11 start!!");
  Serial.println("Humidity,analogA3toV");
  delay(1000);
  dht.begin();
}

void loop() {
  delay(1000);
  float h = dht.readHumidity();

  Serial.print(h);
  Serial.print(",");
  analogtestA3();
}

//show port A3 voltage(0~5V to 0~1023)
//signal(0~1023) to voltage(0~5V)
void analogtestA3(){
  int val;
  val=analogRead(A3);
  float valV;
  valV = (float)val*5/1024;
  Serial.println(valV);
}
