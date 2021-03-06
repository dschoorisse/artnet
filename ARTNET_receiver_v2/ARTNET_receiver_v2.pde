
/*
ARTNET RECEIVER V2

This SCRIPT allows you to use arduino with ethernet shield or wifi shield and recieve artnet data. Up to you to use channels as you want.

It works with Arduino 023 software

If you have implemented ameliorations to this sketch, please, contribute by sending back modifications, ameliorations, derivative sketch. It will be a pleasure
to let them accessible to community



For VVVV patchers, please think to put a mainloop node in your patch: minimum frame rate is 40fps with bulbs. But do not go too much higher ( max 100 fps).

This sketch is part of white cat lighting board suite: /http://www.le-chat-noir-numerique.fr  
wich is sending data to many different types of devices, and includes a direct communication in serial also with arduino likes devices
you may find whitecat interresting because its theatre based logic ( cuelist and automations) AND live oriented ( masters, midi, etc)

(c)Christoph Guillermet
http://www.le-chat-noir-numerique.fr
karistouf@yahoo.fr
*/


#include <SPI.h>         // needed for Arduino versions later than 0018
#include <Ethernet.h>
#include <Udp.h>         // UDP library from: bjoern@cs.stanford.edu 12/30/2008
#define short_get_high_byte(x) ((HIGH_BYTE & x) >> 8)
#define short_get_low_byte(x)  (LOW_BYTE & x)
#define bytes_to_short(h,l) ( ((h << 8) & 0xff00) | (l & 0x00FF) );


//MAC and IP of the ethernet shield
//MAC adress of the ethershield is stamped down the shield
//to translate it from hexa decimal to decimal, use: http://www.frankdevelopper.com/outils/convertisseur.php
//HARDWARE
byte mac[] = {  144, 162, 218, 00, 16, 96  };//the mac adress of ethernet shield or uno shield board
byte ip[] = {   192,168,1,177 };// the IP adress of your device, that should be in same universe of the network you are using, here: 192.168.1.x

// the next two variables are set when a packet is received
byte remoteIp[4];        // holds received packet's originating IP
unsigned int remotePort; // holds received packet's originating port

//customisation: edit this if you want for example read and copy only 4 or 6 channels from channel 12 or 48 or whatever.
const int number_of_channels=512; //512 for 512 channels
const int channel_position=1; // 1 if you want to read from channel 1

// buffers
const int MAX_BUFFER_UDP=1024;//definition to do to make work UDP lib
char packetBuffer[MAX_BUFFER_UDP]; //buffer to store incoming data
byte buffer_dmx[number_of_channels+channel_position]; //buffer to store filetered DMX data

// art net parameters
unsigned int localPort = 6454;      // artnet UDP port is by default 6454
const int art_net_header_size=17;
const int max_packet_size=576;
char ArtNetHead[8]="Art-Net";
char OpHbyteReceive=0;
char OpLbyteReceive=0;
short is_artnet_version_1=0;
short is_artnet_version_2=0;
short seq_artnet=0;
short artnet_physical=0;
short incoming_universe=0;
boolean is_opcode_is_dmx=0;
boolean is_opcode_is_artpoll=0;
boolean match_artnet=1;
short Opcode=0;


void setup() {
  //déclaration des ports PWM 
  //ici une diode pour test
  pinMode(3, OUTPUT);  //check with leds + resistance in pwm, this will not work with pins 10 and 11, used by RJ45 shield
  pinMode(5, OUTPUT);  //check with leds + resistance in pwm, this will not work with pins 10 and 11, used by RJ45 shield
  pinMode(6, OUTPUT);  //check with leds + resistance in pwm, this will not work with pins 10 and 11, used by RJ45 shield 
  // démarrage ethernet et serveur UDP
  Ethernet.begin(mac,ip);
  Udp.begin(localPort);
}

void loop() {
  
  int packetSize = Udp.available();
  if( packetSize>art_net_header_size && packetSize<=max_packet_size)//check size to avoid unneeded checks
  {
    Udp.readPacket(packetBuffer,MAX_BUFFER_UDP, remoteIp, remotePort);  
    //read header
     match_artnet=1;//valeur de stockage
     for (int i=0;i<7;i++)
     {
      if(char(packetBuffer[i])!=ArtNetHead[i])
      {match_artnet=0;break;}//if not corresponding, this is not an artnet packet, so we stop reading
     } 
     if (match_artnet==1)//if its an artnet header
     { 
          /*artnet protocole revision, not really needed
          is_artnet_version_1=packetBuffer[10]; 
          is_artnet_version_2=packetBuffer[11];*/
      
          /*sequence of data, to avoid lost packets on routeurs
          seq_artnet=packetBuffer[12];*/
          
          /*physical port of  dmx N°
          //artnet_physical=packetBuffer[13];*/
      
     //operator code enables to know wich type of message Art-Net it is
     Opcode=bytes_to_short(packetBuffer[9],packetBuffer[8]);
     
     if(Opcode==0x5000)//if opcode is DMX type
      {
       is_opcode_is_dmx=1;is_opcode_is_artpoll=0;
       }   
       
     else if(Opcode==0x2000)//if opcode is artpoll 
     {
     is_opcode_is_artpoll=1;is_opcode_is_dmx=0;
     //( we should normally reply to it, giving ip adress of the device)
     } 
 
     if(  is_opcode_is_dmx=1)//if its DMX data we will read it now
     {
     //if you need to filter DMX universes, uncomment next line to have the universe rceived
     //incoming_universe= bytes_to_short(packetBuffer[15],packetBuffer[14])
     
     //getting data from a channel position, on a precise amount of channels, this to avoid to much operation if you need only 4 channels for example
     for(int i=channel_position-1;i< number_of_channels;i++)//channel position
      {
     buffer_dmx[i]= byte(packetBuffer[i+17]);
       }
      }
 
     }//end of sniffing 
    
  }

//stuff to do on PWM or whatever
 analogWrite(3,buffer_dmx[3]);  
 analogWrite(5,buffer_dmx[5]); 
 analogWrite(6,buffer_dmx[6]);   
}

