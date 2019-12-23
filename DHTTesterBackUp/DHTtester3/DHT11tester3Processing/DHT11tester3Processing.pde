// Tetsuaki Baba
// Processing のサンプルコード
// str_format: データ名をカンマ区切りで書いておく
// port: 該当するシリアルポートへのパスを明記（Windowsの場合はCOMX（Xは数字））になります．

//使い方
//Sキーで出力開始、Eキーで出力終了


/*
システム
setup -> 決められたportを検出し、実行する。






*/

import processing.serial.*;
float [] farray = {0,0};//記録用配列
float [] farrayTo = {0,0};
ArrayList<Float>fumidity = new ArrayList<Float>();//表示用配列
ArrayList<Float>voltage = new ArrayList<Float>();
int counter = 0;
int portCheckList = 0;//listのどこを見ているか
int portCheckCount = 0;//5カウントで別のポートへの接続を試みる。
PrintWriter output;
Serial myPort = null;
boolean flg_start = false;//csvファイルへの書き込み条件
int time=0;//スタートからの時間
int sycle=60;//検出サイクル(フレーム)
String str_format = "x,y";
String port = "/dev/cu.usbmodem143101";//ここは各自変える//change port
String filename;
String inBuffer;
String mode = "setup";//"setup","search","demo","test","play"

//new paramaters
int margin = 20;//上下左右の表外の余白
int marginBar = 5;//メモリのサイズ
int marginTextPos = 4;//テキストポジションの修正度合い

void setup() {
  //最小サイズは(50,100);です。それ以上で変更してください。
  size(600, 400);
  try{
    myPort = new Serial(this, port, 9600); //ポート検出に必要
    mode = "play";println("playmode");
  }catch(java.lang.RuntimeException e){
    //println("errer001:Port not found. you change the port from this list.");
    println("エラー001:ポートがありません。以下からポートを選んで変更してください。");
    printArray(Serial.list());
    println("現在のport : "+port);
    println("現在のmyPort : "+myPort);
    //portCheck();
    mode = "test";
  }
  //output = createWriter( filename + ".csv"); //keypressedのところで定義しているので多分いらない
  //myPort =null;//test用＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
  println("setup end");
}
//毎フレーム呼び出される処理
void draw() {
  time += 1;
  if(time > sycle){time = 0;counter+=1;portCheckCount+=1;
    drawBackground();//背景の描写
  
    if(mode == "demo"){//DEMOmodeデモモード
      demoMode();
    }else if(mode == "test"){//ポートをゲットした時のモード
      testMode();
    }else if(mode == "play"){
      playMode();
    }
  }
}



void demoMode(){
  fill(0);textSize(30);stroke(5);
  fill(255,0,0);text("DEMOmode!!!",margin*3,margin*3);
  fumidity.add(float(counter)*0.1+30);
  voltage.add(float(counter)*0.001+1.2);
  print("test fumidity : "+fumidity.get(counter-1));
  println("test  voltage : "+voltage.get(counter-1));
  drawLine();
}
void testMode(){
  println("port,myport,portCheckCount,portCheckList :"+ port +"  "+myPort+"  "+portCheckCount+"  "+portCheckList);
  port = null;
  if(port == null){port = Serial.list()[portCheckList];}
  if(myPort == null){myPort = new Serial(this, port,9600);}
  print("aa");
  while( myPort.available() > 0 ) {delay(100);//もしポートが使われていれば実行
  println("a");
    inBuffer = myPort.readString();
    if ( inBuffer != null ) {output.print(inBuffer);
      if(flg_start){print("saving   ");}else{print("idle   ");}
      //データ
      farray = float(split(inBuffer,","));
      println("Hum : " + farray[0] + "  V : " + farray[1]);
      fumidity.add(farray[0]);
      voltage.add(farray[1]);
      drawLine();
    }else{
      println("inBuffer == null");
    }
  }
  
  if(farray[0] == 0){//シリアルデータをゲットできない時
    if(5< portCheckCount && (portCheckList < Serial.list().length)){//カウントが5行ったら新しいポートを試す
      println("シリアルが確認できません。別のポートに接続を試みます。");
      println("ポートは : " + Serial.list()[portCheckList+1]);
      portCheckList+=1;
      portCheck();
      portCheckCount=0;
    }else if(5<portCheckCount){
      println("ポート接続ができませんでした。");
      println("Arduinoのケーブルを接続してください。");
      portCheckCount = -10000;
    }
  }

  
}
void playMode(){
  while( myPort.available() > 0 ) {delay(100);//もしポートが使われていれば実行
    inBuffer = myPort.readString();
    if ( inBuffer != null ) {output.print(inBuffer);
      if(flg_start){print("saving   ");}else{print("idle   ");}
      farray = float(split(inBuffer,","));
      println("Hum : " + farray[0] + "  V : " + farray[1]);
      fumidity.add(farray[0]);
      voltage.add(farray[1]);
      drawLine();
    }else{
      println("inBuffer == null");
    }
  }
}



















//keyが押された時の処理
void keyPressed() {
  if ( key  == 's' ) {//測定スタート
    if(!flg_start){
      filename = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) ;
      output = createWriter( filename + ".csv");
      output.println("Humidity,analogA3toV");
      println("save start!!");
      flg_start = true;
    }
  }
  if ( key == 'e' ) {//計測終了
    // end of recording
    if(flg_start){  
      println("save end");
      output.flush(); 
      output.close();
      flg_start = false;
    }
  }
}
//湿度電圧のデータをプロットする座標計算
int clineL(float i) {//plot humidity on graph
  int a = 0;
   a = int(height - margin -(height -margin*2 )*i/100);
  return(a);
}
int clineR(float i) {//plot Voltage on graph
  int a = 0;
   a = int(height - margin -(height -margin*2 )*i/2.5);
   return(a);
}

void drawBackground(){
  //全体の表の表示
  background(255);stroke(0);
  line(margin,margin,margin,(height-margin));
  line(margin,(height-margin),(width-margin),(height-margin));
  line((width-margin),margin,(width-margin),(height-margin));
  //細かい部分の表示
  fill(0);textSize(8);stroke(0);
  fill(0,0,255);text("(%)",margin-marginBar,margin-marginTextPos);
  fill(0);
  //humidityのメモリ表示
  for(int i = 0;i < 6;i++){int hum = i*20;
    line(margin-marginBar,clineL(hum),margin+marginBar,clineL(hum));text(""+hum,0,clineL(hum)+marginTextPos);
  }
  //voltageのメモリ表示
  fill(255,0,0);text("(V)",width-margin-marginBar,margin-marginTextPos);
  fill(0);
  for(int i = 0;i < 6;i++){float vol = i*0.5;
      line(width-margin-marginBar,clineR(vol),width-margin+marginBar,clineR(vol));text(""+vol,width-margin+marginTextPos,clineR(vol)+marginTextPos);
  }
  //灰色の薄い線を引く
  stroke(245);
  for(int i=1;i<6;i++){int line = i*20;
    line(margin+marginBar,clineL(line),width-margin-marginBar,clineL(line));
  }
  showRecording();
}


//描写をスクロールするには？
//今の状況ではスクロールせず、描写しっぱなし。
void drawLine(){
  //旧drawLines farrayTo=farrayはCSV記録用に必要
  //stroke(0,0,255);line(count,clineL(farrayTo[0]),count+2,clineL(farray[0]));
  //stroke(255,0,0);line(count,clineR(farrayTo[1]),count+2,clineR(farray[1]));
  farrayTo = farray;
  //どれぐらいスクロールするか規定する。サイズによって変更する。
  int scroll=0;
 if(fumidity.size()*2>(width-margin*2)){
   scroll = fumidity.size()*2 - (width-margin*2);
 }
  for(int i = 1;i<fumidity.size();i++){
    if(fumidity.size()*2<(width-margin*2)){
      stroke(0,0,255);
      line(i*2+margin,clineL(fumidity.get(i-1)),i*2+margin+2,clineL(fumidity.get(i)));
      stroke(255,0,0);
      line(i*2+margin,clineR(voltage.get(i-1)),i*2+margin+2,clineR(voltage.get(i)));
    }else{
      if(i*2+margin-scroll>margin){//グラフの端を表示しない
        stroke(0,0,255);
        line(i*2+margin-scroll,clineL(fumidity.get(i-1)),i*2+margin+2-scroll,clineL(fumidity.get(i)));
        stroke(255,0,0);
        line(i*2+margin-scroll,clineR(voltage.get(i-1)),i*2+margin+2-scroll,clineR(voltage.get(i)));
      }
    }
  }
}


void portCheck(){
  if(portCheckList < Serial.list().length-1){//portCheckListが多すぎたらクラッシュする
    for(int i = portCheckList;i<Serial.list().length-1;i++){
      port = Serial.list()[i];
      try{
        myPort = new Serial(this,port,9600);
        println("接続しました。ポートは : " + port);
        break;
      }catch(RuntimeException f){
        println(i + "接続に失敗しました。"+Serial.list()[i]);
        portCheckList+=1;
        myPort = null;
        portCheck();
        break;
      }
    }
  }else{
    println("portCheckList is over : " + portCheckList);
    myPort = null;
  }
}


void showRecording(){
  /*
  if(flg_start){println("Recording now");}
  else{println("idle mode");}
  */
  
}
