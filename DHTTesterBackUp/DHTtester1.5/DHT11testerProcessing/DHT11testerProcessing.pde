// port: 該当するシリアルポートへのパスを明記（Windowsの場合はCOMX（Xは数字））になります．

//使い方
//Sキーで出力開始、Fキーで出力終了
//Eキーでイベントのラインを生成

float maxHumidity = 100;
float maxVoltage = 2.5;
String port = "/dev/cu.usbmodem143101";//ここは各自変える//change port

import processing.serial.*;
float [] farray = {0,0};//記録用配列
ArrayList<Float>fumidity = new ArrayList<Float>();//表示用配列
ArrayList<Float>voltage = new ArrayList<Float>();
int counter = 0;
int portCheckList = 0;//listのどこを見ているか
int portCheckCount = 0;//5カウントで別のポートへの接続を試みる。
PrintWriter output;
Serial myPort = null;
boolean flg_start = false;//csvファイルへの書き込み条件
boolean eventbool = false;
int time=0;//スタートからの時間
int sycle=120;//検出サイクル(フレーム)
String str_format = "x,y";
String filename;
String inBuffer = "nullだよ";
String mode = "setup";//"setup","search","demo","test","play"

ArrayList<String> text = new ArrayList<String>();
ArrayList<Integer> num = new ArrayList<Integer>();

//new paramaters
int topmargin = 80;//上下左右の表外の余白
int margin = 20;//上下左右の表外の余白
int marginBar = 5;//メモリのサイズ
int marginTextPos = 4;//テキストポジションの修正度合い

void setup() {
  size(600,400);
  surface.setResizable( true );
  //最小サイズは(50,100);です。それ以上で変更してください。
  try{
    myPort = new Serial(this, port, 9600); //ポート検出に必要
    mode = "play";println("playmode");
  }catch(java.lang.RuntimeException e){
    //println("errer001:Port not found. you change the port from this list.");
    println("エラー001:ポートがありません。以下からポートを選んで変更してください。");
    portCheck();
  }
  //output = createWriter( filename + ".csv"); //keypressedのところで定義しているので多分いらない
  //myPort =null;//test用＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
  printArray(Serial.list());
  print("現在のport : "+port);println("現在のmyPort : "+myPort);
  println("setup end");
  mode = "sample";
}
//毎フレーム呼び出される処理
void draw() {
  drawBackground();//背景の描写
  time += 1;touchBar();sizePad();
  if(time > sycle){time = 0;counter+=1;portCheckCount+=1;
    if(mode == "demo"){//DEMOmodeデモモード
      fill(0);textSize(30);stroke(5);
      fill(255,0,0);text("DEMOmode!!!",margin*3,topmargin*3);
      demoMode();
    }else if(mode == "test"){//ポートをゲットした時のモード
      //testMode();
    }else if(mode == "play"){
      //playMode();
    }else if(mode == "sample"){
      sampleMode();
    }
  }
  drawLine();
}

void sampleMode(){
  //データ
  farray = float(split(inBuffer,","));
  if ( inBuffer != null && flg_start) {
    output.print(inBuffer);
    if(eventbool){eventbool = false;
      output.println(inBuffer.trim() + ",event");
    }
  }
  if(farray[0] > 0){
    println("");
    if(flg_start){print("saving   ");}else{print("idle   ");}
    print("Hum : " + farray[0] + "  V : " + farray[1]);
    //print("現在のport : "+port);println("現在のmyPort : "+myPort);
    fumidity.add(farray[0]);
    voltage.add(farray[1]);
  }else{
    demoMode();
  }
}
 void serialEvent(Serial p){
   if(p.available() > 0){
    //取得したらinBufferに記録する。
    String st = p.readStringUntil('\n');
    if(st != null){
      inBuffer = st;
    }
  }
}
void sizePad(){
  for(int i = 3;i<margin;i+=3){
    if(i%3==0){stroke(60);}
    else{stroke(0);}
    line(width-1,height-margin+i,width-margin+i,height-1);
  }
}
//マウスが押された時の反応
void touchBar(){
  fill(255);
  stroke(0);
  line(margin*1.5,margin*2,margin*16,margin*2);for(int i = 0;i < 3;i+=1){line(margin*18 - i*12,margin*2,margin*18 - i*16,margin*2);}//under port bar
  fill(0);textSize(int(margin*0.7));stroke(0);
  if(margin*2 < mouseX && mouseX <margin*17&&margin<mouseY&&mouseY<margin*2){
    noStroke();fill(240);rect(margin*2,margin,margin*14,margin);
    fill(0);textSize(int(margin*0.7));stroke(0);
    fill(255,0,0);text("switch Another port : ",margin*2+3,margin*2-3);
  }else{
    fill(0);textSize(int(margin*0.7));stroke(0);
    fill(255,0,0);text("Port : "+ port,margin*2+3,margin*2-3);
  }
  if(mousePressed == true){
    if(margin*2 < mouseX && mouseX <margin*17&&margin<mouseY&&mouseY<margin*2){
    }
  }
}
void mouseReleased(){
  if(margin*2 < mouseX && mouseX <margin*17&&margin<mouseY&&mouseY<margin*2){
    portCheckList = 0;
    
    if(myPort != null){myPort.clear();}
    portCheck();
  }
}

//keyが押された時の処理
void keyPressed() {
  if ( key  == 's' ) {//測定スタート
    if(!flg_start){
      filename = nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) ;
      output = createWriter( filename + ".csv");
      output.println("Humidity,Voltage");
      println("");
      print("save start!!");
      num.add(fumidity.size());text.add("start");
      flg_start = true;
    }
  }
  if ( key == 'f' ) {//計測終了
    // end of recording
    if(flg_start){
      println("");
      print("save finished");
      output.flush(); 
      output.close();
      num.add(fumidity.size());text.add("fin");
      flg_start = false;
    }
  }
}
void keyReleased(){
  if ( key == 'e' ) {//テスト
    println("");
    print("event!!");
    eventbool = true;
    num.add(fumidity.size());text.add("event");
  }
}



//湿度電圧のデータをプロットする座標計算
int clineL(float i) {//plot humidity on graph
  int a = 0;
   a = int(height - margin -(height -margin-topmargin )*i/maxHumidity);
  return(a);
}
int clineR(float i) {//plot Voltage on graph
  int a = 0;
   a = int(height - margin -(height -margin-topmargin )*i/maxVoltage);
   return(a);
}


  //全体の表の表示(背景)
void drawBackground(){
  background(255);stroke(0);
  line(margin,topmargin,margin,(height-margin));
  line(margin,(height-margin),(width-margin),(height-margin));
  line((width-margin),topmargin,(width-margin),(height-margin));
  //細かい部分の表示
  fill(0);textSize(8);stroke(0);
  fill(0,0,255);text("(%)",margin-marginBar,topmargin-marginTextPos);
  fill(0);
  //humidityのメモリ表示
  for(int i = 0;i < 6;i++){int hum = i*20;
    line(margin-marginBar,clineL(hum),margin+marginBar,clineL(hum));text(""+hum,0,clineL(hum)+marginTextPos);
  }
  //voltageのメモリ表示
  fill(255,0,0);text("(V)",width-margin-marginBar,topmargin-marginTextPos);
  fill(0);
  for(int i = 0;i < 6;i++){float vol = i*0.5;
      line(width-margin-marginBar,clineR(vol),width-margin+marginBar,clineR(vol));text(""+vol,width-margin+marginTextPos,clineR(vol)+marginTextPos);
  }
  //灰色の薄い線を引く
  stroke(245);
  for(int i=1;i<6;i++){int line = i*20;
    line(margin+marginBar,clineL(line),width-margin-marginBar,clineL(line));
  }
}


//描写をスクロールするには？
//今の状況ではスクロールせず、描写しっぱなし。
void drawLine(){
    int scroll=0;//スクロール度合いの定義
     if(fumidity.size()*2>(width-margin*2)){scroll = fumidity.size()*2 - (width-margin*2);}
    showRecording(scroll);
    for(int i = 1;i<fumidity.size();i++){
      if(fumidity.size()*2<(width-margin*2)){//グラフが収まる時
        stroke(0,0,255);
        line(i*2+margin,clineL(fumidity.get(i-1)),i*2+margin+2,clineL(fumidity.get(i)));
        stroke(255,0,0);
        line(i*2+margin,clineR(voltage.get(i-1)),i*2+margin+2,clineR(voltage.get(i)));
      }else{
        if(i*2+margin-scroll>margin){//グラフが突き抜ける時
          stroke(0,0,255);
          line(i*2+margin-scroll,clineL(fumidity.get(i-1)),i*2+margin+2-scroll,clineL(fumidity.get(i)));
          stroke(255,0,0);
          line(i*2+margin-scroll,clineR(voltage.get(i-1)),i*2+margin+2-scroll,clineR(voltage.get(i)));
        }
    }
  }
}


void portCheck(){
  for(int i = portCheckList;i<Serial.list().length;i++){
    port = Serial.list()[i];
    try{
      myPort = new Serial(this,port,9600);
      println("接続しました。ポートは : " + port);
      break;
    }catch(RuntimeException f){
      println(i + "番ポートへの接続に失敗しました。"+Serial.list()[i]);
      portCheckList+=1;
      portCheck();
      break;
    }
  }
}
void showRecording(int scroll){//イベント整理のためのバーを表示する
  stroke(255,0,255);
  if(fumidity.size()*2<(width-margin*2)){//グラフが収まる時
    for(int i = 0;i < text.size();i++){
      if(text.get(i) == "start"){
        stroke(200);fill(200);line(num.get(i)*2+margin,clineL(-1),num.get(i)*2+margin,clineL(100)-margin);
        stroke(200);fill(0);textSize(int(margin*0.5));text(text.get(i),num.get(i)*2+margin,clineL(100)-margin);
      }else if(text.get(i) == "fin"){
        stroke(200);fill(200);line(num.get(i)*2+margin,clineL(-1),num.get(i)*2+margin,clineL(100));
        stroke(200);fill(0);textSize(int(margin*0.5));text(text.get(i),num.get(i)*2+margin,clineL(100));
      }else if(text.get(i) == "event"){
        stroke(200);fill(200);line(num.get(i)*2+margin,clineL(-1),num.get(i)*2+margin,clineL(100)-margin/2);
        stroke(200);fill(0);textSize(int(margin*0.5));text(text.get(i),num.get(i)*2+margin,clineL(100)-margin/2);
      }
    }
  }else{//グラフがはみ出すとき
    for(int i = 0;i < text.size();i++){
      if(num.get(i)*2+margin-scroll>margin){
        if(text.get(i) == "start"){
          stroke(200);fill(200);line(num.get(i)*2+margin-scroll,clineL(-1),num.get(i)*2+margin-scroll,clineL(100)-margin);
          stroke(200);fill(0);textSize(int(margin*0.5));text(text.get(i),num.get(i)*2+margin-scroll,clineL(100)-margin);
        }else if(text.get(i) == "fin"){
          stroke(200);fill(200);line(num.get(i)*2+margin-scroll,clineL(-1),num.get(i)*2+margin-scroll,clineL(100));
          stroke(200);fill(0);textSize(int(margin*0.5));text(text.get(i),num.get(i)*2+margin-scroll,clineL(100));
        }else if(text.get(i) == "event"){
          stroke(200);fill(200);line(num.get(i)*2+margin-scroll,clineL(-1),num.get(i)*2+margin-scroll,clineL(100)-margin/2);
          stroke(200);fill(0);textSize(int(margin*0.5));text(text.get(i),num.get(i)*2+margin-scroll,clineL(100)-margin/2);
        }
      }  
    }
  }
}



void demoMode(){
  fumidity.add(float(counter)*0 + 1);
  voltage.add(float(counter)*0 + 0.1);
  print("testmode Hum : "+fumidity.get(counter-1));
  println("   V : "+voltage.get(counter-1));
  mode = "sample";
}
