/*
  UDPSendReceive.pde:
 This sketch receives UDP message strings, prints them to the serial port
 and sends an "acknowledge" string back to the sender

 A Processing sketch is included at the end of file that can be used to send
 and received messages for testing with a computer.

 created 21 Aug 2010
 by Michael Margolis

 This code is in the public domain.
 */

#include "FastLED.h"
#include <SPI.h>         // needed for Arduino versions later than 0018
#include <Ethernet.h>
#include <EthernetUdp.h>         // UDP library from: bjoern@cs.stanford.edu 12/30/2008

#define NUM_LEDS 400
#define DATA_PIN 7
#define UDP_TX_PACKET_MAX_SIZE 800
// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = {
  0xDE, 0xAD, 0xBE, 0xEF, 0xEF, 0xED
};
IPAddress ip(192, 168, 1, 177);
CRGB leds[NUM_LEDS];
byte myLights[NUM_LEDS];

unsigned int localPort = 8888;      // local port to listen on

// buffers for receiving and sending data
char packetBuffer[UDP_TX_PACKET_MAX_SIZE]; //buffer to hold incoming packet,
char  ReplyBuffer[] = "acknowledged";       // a string to send back

// An EthernetUDP instance to let us send and receive packets over UDP
EthernetUDP Udp;

void setup() {
  // start the Ethernet and UDP:
  Ethernet.begin(mac, ip);
  Udp.begin(localPort);

  Serial.begin(250000);
  FastLED.addLeds<WS2812B, DATA_PIN, RGB>(leds, NUM_LEDS);
}

void loop() {
  // if there's data available, read a packet
  //Serial.println("anything");
  int packetSize = Udp.parsePacket();
  if (packetSize)
  {
    IPAddress remote = Udp.remoteIP();
    // read the packet into packetBufffer
    Udp.read(packetBuffer, UDP_TX_PACKET_MAX_SIZE);
   // byte haha[40];
   //    haha.readBytes(packetBuffer, 40);
   //String haha= packetBuffer;
    for (int j=0;j<50;j++){
          for (int i=0;i<8;i++){
    myLights[7-i+8*j]=bitRead(packetBuffer[j],i);
          }
}
//   Serial.print(bitRead(packetBuffer[0],7));
//   Serial.print(bitRead(packetBuffer[0],6));
//   Serial.print(bitRead(packetBuffer[0],5));
//   Serial.print(bitRead(packetBuffer[0],4));
//   Serial.print(bitRead(packetBuffer[0],3));
//   Serial.print(bitRead(packetBuffer[0],2));
//   Serial.print(bitRead(packetBuffer[0],1));
//   Serial.print(bitRead(packetBuffer[0],0));
//   Serial.println(packetBuffer[0]);
//   
    

for (int i=0;i<400;i++){
 // Serial.println(char(myLights[0]));
 
  if (myLights[i]==1){
    leds[i]=CRGB(0,10,0);
  } else{
    leds[i]=CRGB(0,0,0);
  }
}
    // send a reply, to the IP address and port that sent us the packet we received
   // Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
    //Udp.write(ReplyBuffer);
    //Udp.endPacket();
  }
  FastLED.show();
  delay(15);
}

