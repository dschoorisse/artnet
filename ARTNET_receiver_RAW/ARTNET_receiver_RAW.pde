#include <SPI.h>         // needed for Arduino versions later than 0018
#include <Ethernet.h>
#include <Udp.h>         // UDP library from: bjoern@cs.stanford.edu 12/30/2008

////////////CE SCRIPT PERMET DE RECUPERER LE DMX DANS UNE TRAME ART-NET
////////////ET DE L'APPLIQUER AUX SORTIES ARDUINO
////////////PERMET DONC DE TRAVAILLER EN RJ45 OU EN WIFI

// ADRESSES MAC ET IP du shield ethernet
//l'adresse MAC de la carte réseau est collée dans un sticker au dos de la carte
//pour la traduire en décimale, utiliser: http://www.frankdevelopper.com/outils/convertisseur.php
byte mac[] = { 144, 162, 218, 00, 16, 96 };
byte ip[] = { 192,168,1,177 };
unsigned int localPort = 6454;      // port UDP générique art-net=6454
byte remoteIp[4];        // holds received packet's originating IP
unsigned int remotePort; // holds received packet's originating port
char packetBuffer[1024]; //buffer to hold incoming packet,
const int nombre_de_circuits=48;
int taille_chaine_artnet=8+17+nombre_de_circuits+1;
//8: UDP protocole //17: header + donnees artnet // 1: caractere de fin de chaine
byte buffer_dmx[nombre_de_circuits];



void setup() {
  pinMode(6, OUTPUT);  //PIn de test
  pinMode(5, OUTPUT);  //PIn de test
  pinMode(3, OUTPUT);  //PIn de test
  Ethernet.begin(mac,ip);
  Udp.begin(localPort);
}

void loop() {

  int packetSize = Udp.available(); // note that this includes the UDP header
  if(packetSize>48)
  {
    Udp.readPacket(packetBuffer,1024, remoteIp, remotePort);
    for(int i=0;i<nombre_de_circuits;i++)
    {
    buffer_dmx[i]=(byte) packetBuffer[i+17];
    }
  //report des valeurs sur les PWM 
  analogWrite(6,buffer_dmx[6]);  
   analogWrite(5,buffer_dmx[5]);  
    analogWrite(3,buffer_dmx[3]);   
  }

}

