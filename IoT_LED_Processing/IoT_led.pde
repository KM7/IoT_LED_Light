import hypermedia.net.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

 UDP udp;  // define the UDP object

int boardSizeX=20;
int boardSizeY=20;
boolean[][] currentBoard=new boolean[boardSizeX][boardSizeY];
int squareSize=40;// the square size

Kinect kinect;

// Depth image
PImage depthImg;

// Which pixels do we care about?
int minDepth =  60;
int maxDepth = 860;

// What is the kinect's angle
float angle;



void setup(){
  frameRate(20);
  size(800,400);
  initialize_board();
 udp = new UDP( this, 8888 );  // create a new datagram connection on port 6000
 udp.log( false );     // <-- printout the connection activity
 udp.listen( true );           // and wait for incoming message
 // thread("sendMessage");
   kinect = new Kinect(this);
  kinect.initDepth();
  angle = kinect.getTilt();

  // Blank image
  depthImg = new PImage(kinect.width, kinect.height);
}

void draw(){
  background(0);
  drawBoard(0,0);
  drawColour(0,0);
  mouseAction(0,0);
  sendMessageINbyte();
    kinectPart();
 // sendMessage();
}

void drawBoard(int x,int y){
for ( int f=0;f<=boardSizeX;f=f+1){
for ( int t=0;t<=boardSizeY;t=t+1){
fill(219);
rect((x+t*squareSize/2),(y+f*squareSize/2),squareSize/2,squareSize/2);
fill(0);
}
}
}

void initialize_board(){
 for ( int f=0;f<boardSizeX;f=f+1){
for ( int t=0;t<boardSizeY;t=t+1){
currentBoard[f][t]=false;
}
}
}

void drawColour(int x,int y){
  for ( int f=0;f<boardSizeX;f=f+1){
for ( int t=0;t<boardSizeY;t=t+1){
  if (currentBoard[t][f]){
fill(244,22,22);
rect((x+t*squareSize/2),(y+f*squareSize/2),squareSize/2,squareSize/2);
fill(0);
  }
}
}
}

void mouseAction(int x,int y){
  for ( int f=0;f<boardSizeX;f=f+1){
for ( int t=0;t<boardSizeY;t=t+1){
if ((mousePressed)&&(mouseX>(x+t*squareSize/2))&&(mouseX<(x+(t+1)*squareSize/2))&&(mouseY>(y+f*squareSize/2))&&(mouseY<(y+(f+1)*squareSize/2))){
currentBoard[t][f]=true;}
  }
}
}


void sendMessageINbyte(){
  //for now make the boolean array size to be fix
int[] lightArray=new int[400];
  for ( int f=0;f<boardSizeX;f=f+1){
for ( int t=0;t<boardSizeY;t=t+1){
  if (currentBoard[t][f]){
      lightArray[t+boardSizeX*f]=1;
  }else{
          lightArray[t+boardSizeX*f]=0;
  }
  }
}

println(lightArray[399]);
String[] tempBinaryString=new String[50];

String tempString="";
for (int i=0;i<50;i++){
 tempBinaryString[i]="";
}
for (int i=0;i<400;i++){
 //println(i/8);
 tempBinaryString[i/8]=tempBinaryString[i/8]+lightArray[i];
}

println(tempBinaryString[0]);

byte[] byteArray=new byte[50];
for (int i=0;i<50;i++){
  byteArray[i]=byte(unbinary(tempBinaryString[i]));
}

String totalString="";
for(int i=0;i<50;i++){
  if(i!=49){
  totalString=totalString+int(unbinary(tempBinaryString[i]))+",";
  }else{
    totalString=totalString+int(unbinary(tempBinaryString[i]));
  }

}

 String ip       = "192.168.1.177";  // the remote IP address
 int port        = 8888;    // the destination port

 udp.send(byteArray, ip, port );   // the message to send
 //myPort.write(tempbyteArray);
//now send the information to arduino
}


 void receive( byte[] data ) {

 }   // <-- default handler
 void receive( byte[] data, String ip, int port ) {  // <-- extended handler

 for(int i=0; i < data.length; i++)
 print(char(data[i]));
 println();
 }
 
 void kinectPart(){
   int[] rawDepth = kinect.getRawDepth();
  for (int i=0; i < rawDepth.length; i++) {
    if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
      depthImg.pixels[i] = color(255);
    } else {
      depthImg.pixels[i] = color(0);
    }
  }

  // Draw the thresholded image
  depthImg.updatePixels();
  PImage tempImg = depthImg.get(80, 0, 480, 480); 
    image(tempImg, 400, 0,400,400);

  tempImg.resize(20,20);
  
  for (int i=0;i<tempImg.width;i++){
      for (int j=0;j<tempImg.height;j++){
        if (colorCompare(tempImg.get(i,j),color(255),20)){
         currentBoard[i][j]=true;
        }else{
          currentBoard[i][j]=false;
        }
      }
  }

  fill(0);
  text("TILT: " + angle, 10, 20);
  text("THRESHOLD: [" + minDepth + ", " + maxDepth + "]", 10, 36);
 }
 
boolean colorCompare(color a,color b,int threashold){
  //parse the rgb data out
  float diffRed=abs(red(a)-red(b));
  float diffGreen=abs(green(a)-green(b));
  float diffBlue=abs(blue(a)-blue(b));
  //caculate the change percentage
  float pctDiffRed   = (float)diffRed   / 255;
  float pctDiffGreen = (float)diffGreen / 255;
  float pctDiffBlue  = (float)diffBlue  / 255;
  //use caculate the difference percentage
  float percentage=(pctDiffRed + pctDiffGreen + pctDiffBlue) / 3 * 100;
  println("color difference percentage "+percentage);
  //read rgb information for the color comparison
  if (percentage<threashold)
      {
        //println("same colour");
        return true;
  } else{
         //println("different colour");
        return false; 
  }
}
 
