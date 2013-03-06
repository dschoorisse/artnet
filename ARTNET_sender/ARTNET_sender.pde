
/*
ARTNET SENDER

This SCRIPT allows you to use arduino with ethernet shield or wifi shield and send dmx artnet data. 
Up to you to use logics for channels as you want.

It works with Arduino 023 software

If you have implemented ameliorations to this sketch, please, contribute by sending back modifications, ameliorations, derivative sketch. 
It will be a pleasure to let them accessible to community

This sketch is part of white cat lighting board suite: /http://www.le-chat-noir-numerique.fr  
wich is sending data to many different types of devices, and includes a direct communication in serial also with arduino as devices
You may find whitecat interresting because its theatre based logic ( cuelist and automations) AND live oriented ( masters, midi, etc)

(c)Christoph Guillermet
http://www.le-chat-noir-numerique.fr
karistouf@yahoo.fr
*/

#include <SPI.h>         // needed for Arduino versions later than 0018
#include <Ethernet.h>
#include <Udp.h>         // UDP library from: bjoern@cs.stanford.edu 12/30/2008

//MAC and IP of the ethernet shield
//MAC adress of the ethershield is stamped down the shield
//to translate it from hexa decimal to decimal, use: http://www.frankdevelopper.com/outils/convertisseur.php

//TO EDIT:
// the next two variables are set when a packet is received
byte destination_Ip[]= {   255,255,255,255 };        // the ip to send data, 255,255,255,255 is broadcast sending
// art net parameters
unsigned int localPort = 6454;      // artnet UDP port is by default 6454
const int DMX_Universe=0;//universe is from 0 to 15, subnet is not used
const int number_of_channels=512; //512 for 512 channels, MAX=512

//HARDWARE
byte mac[] = {  144, 162, 218, 00, 16, 96  };//the mac adress of ethernet shield or uno shield board
byte ip[] = {   192,168,1,177 };// the IP adress of your device, that should be in same universe of the network you are using, here: 192.168.1.x

//ART-NET variables
char ArtNetHead[8]="Art-Net";
const int art_net_header_size=17;

short OpOutput= 0x5000 ;//output

byte buffer_dmx[number_of_channels]; //buffer used for DMX data

//Artnet PACKET
byte  ArtDmxBuffer[(art_net_header_size+number_of_channels)+8+1];


void setup() {

  //initialise artnet header
  construct_arnet_packet();
  // démarrage ethernet et serveur UDP
  Ethernet.begin(mac,ip);
  Udp.begin(localPort);
}

void loop() {
  
   check_arduino_inputs();
   construct_arnet_packet();
   Udp.sendPacket(   ArtDmxBuffer,(art_net_header_size+number_of_channels+1), destination_Ip, localPort);
   
   delay(50);
}

void check_arduino_inputs()
{
 //data from arduino aquisition

  int temp_val=0;
  for(int i=0;i<6;i++)//reads the 6 analogic inputs and set the data from 1023 steps to 255 steps (dmx)
  {
    temp_val=analogRead(i); 
    buffer_dmx[i]=byte(temp_val/4);
  }
}


void construct_arnet_packet()
{
     //preparation pour tests
    for (int i=0;i<7;i++)
    {
    ArtDmxBuffer[i]=ArtNetHead[i];
    }   

    //Operator code low byte first  
     ArtDmxBuffer[8]=OpOutput;
     ArtDmxBuffer[9]= OpOutput >> 8;
     //protocole
     ArtDmxBuffer[10]=0;
     ArtDmxBuffer[11]=14;
     //sequence
     ArtDmxBuffer[12]=0;
     //physical 
     ArtDmxBuffer[13] = 0;
     // universe 
     ArtDmxBuffer[14]= DMX_Universe;//or 0
     ArtDmxBuffer[15]= DMX_Universe>> 8;
     //data length
     ArtDmxBuffer[16] = number_of_channels>> 8;
     ArtDmxBuffer[17] = number_of_channels;
   
     for (int t= 0;t<number_of_channels;t++)
     {
     ArtDmxBuffer[t+art_net_header_size+1]=buffer_dmx[t];    
     }
     
}

