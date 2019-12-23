//参考ウRL：https://ameblo.jp/empsgs/entry-12085718684.html
//センサーの前提ライブラリhttps://github.com/adafruit/Adafruit_Sensor
//センサーのライブラリhttps://github.com/adafruit/DHT-sensor-library
#include "DHT.h"
#define DHTPIN 4
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(9600);
  Serial.println("DHT11 test!");
  dht.begin();
}

void loop() {
  delay(2000);
  float h = dht.readHumidity();
  float t = dht.readTemperature();

  Serial.print("Humidity: ");
  Serial.print(h);
  Serial.print(" %\t");
  Serial.print("Temperature: ");
  Serial.print(t);
  Serial.print(" ° ");
  analogtestA0();
  analogtestA3();
}

//A0の可変抵抗の値を0~1023で取得し表示
void analogtestA0(){
  int val;
  val=analogRead(A0);
  Serial.print(" analogA0: ");
  Serial.print(val);
}
//A3で取得した電圧0~5Vを0~1023で表示
//ボルトに変換
void analogtestA3(){
  int val;
  val=analogRead(A3);
  Serial.print(" analogA3: ");
  Serial.print(val);
  float valV;
  valV = (float)val*5/1024;
  Serial.print(" analogA3toV: ");
  Serial.println(valV);
}

