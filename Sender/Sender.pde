/*
  besked sender, med RSA kryptering.
  
  Dette program er lavet til at forbinde ti len server.
  Modtage input fra brugeren, kryptere det med RSA-kryptering.
  Sende den kryptered besked til serveren.
  
  Udviklet af Kristoffer Nielsen.
*/


// Importere nødvendige biblioteker.
// Importere BigInteger bibliotek.
import java.math.BigInteger;

// Importre processing.net biblioteket.
import processing.net.*;

// Importre ControlP5 biblioteket.
import controlP5.*;

// Definere variabler for client.
Client c;
String input;

// Definere variabler for RSA krypteringen.
boolean gotKeys = false;
BigInteger[] keys = new BigInteger[2];
BigInteger one = new BigInteger("1");

// Definere controlP5 biblioteket, og tekstfelded.
ControlP5 P5;
controlP5.Textfield Send;

// Void setup køre engang når programmet startes.
void setup() {
  // Starter controlP5
  P5 = new ControlP5(this);
  
  // Diverse funktioner for selve vinduet.
  size(500, 500);
  background(30);
  
  // Køre start funktionen.
  startFunktion();
  
  // Starter clienten og forbinder til serveren.
  c = new Client(this, "192.168.87.178", 12345);
} // setup slut.

// void draw looper så længe programmet køre.
void draw() {
  // Hvis clienten ikke har modtaget den offentlige nøgle.
  if (!gotKeys) {
    // Lytter for input fra serveren.
    if (c.available() > 0) {
      // Læser input fra serveren.
      input = c.readString();
      String[] in = input.split(",");
      
      // Hvis serveren modtager den offentlige nøgle.
      if (in[0].equals("Connected")) {
        // Gemmer den offentlige nøgle i et array.
        keys[0] = new BigInteger(in[1]);
        keys[1] = new BigInteger(in[2]);
        
        // Udskriver i consolen at den har modtaget nøglen.
        println("N = " + keys[0] + " E = " + keys[1]);
        gotKeys = true;
      }
    }
  }
} // draw slut

// Startfunktionen definere controlP5 widgets.
void startFunktion() {
  // Sætter fonten for skriften på skærmen.
  PFont font = createFont("arial", 35);
  
  // Definere hvordan tekstfeldet skal se ud.
  Send = P5.addTextfield("Send")
    .setPosition(width/2-100, height/2-25)
    .setColorBackground(color(50))
    .setFont(font)
    .setSize(200, 50)
    .setFocus(true)
    .setColor(color(255))
    .setLabel("")
    ;
} // startFunktion slut

// Kaldes hver gang der bliver skrevet noget i tekstfelded.
public void Send(String in) {
  // Kalder krypterings algoritme, som der efter sender krypteret besked.
  krypterSend(in);
} // Send slut

// Krypterings funktion, som der efter sender krypteret besked.
void krypterSend(String text) {
  // Laver array til tekst bloksne.
  String[] blocks = new String[0];
  String blockChain = "";
  
  // For loop der deler input stringen op i tekst bloks af bogstaver.
  for (int i = 0; i < text.length(); i++) {
    if (int(text.charAt(i)) < 10) {
      blockChain = blockChain + "00" + str(int(text.charAt(i))) + ",";
    } else if (int(text.charAt(i)) > 10 && int(text.charAt(i)) < 100) {
      blockChain = blockChain + "0" + str(int(text.charAt(i))) + ",";
    } else blockChain = blockChain + str(int(text.charAt(i))) + ",";
  } // for loop slut

  // Gemmer bloks ne i arrayet.
  String[] blocksString = blockChain.split(","); //<>//

  // Hvis antallet af bogstaver er ulige.
  if (blocksString.length % 2 == 1) {
    
    // Udvider arrayet af bloks.
    blocks = expand(blocks, blocksString.length/2+1);
    int j = 0;
    
    // For loop der laver bloks af to bogstaver.
    for (int i = 0; i < blocks.length-1; i++) {
     blocks[i] = blocksString[j];
     j++;
     blocks[i] = blocks[i] + blocksString[j];
     j++;
    } // for loop slut.
    
    // Gemmer den sidste plads i den sidste blok som 000
    blocks[blocks.length-1] = blocksString[blocksString.length-1] + "000";
  } else { // Hvis der er et lige antal bogstaver.
  
    // Udvider arrayet af bloks.
    blocks = expand(blocks, blocksString.length/2);
    int j = 0;
    
    // For loop der laver bloks af to bogstaver.
    for (int i = 0; i < blocks.length; i++) {
     blocks[i] = blocksString[j];
     j++;
     blocks[i] = blocks[i] + blocksString[j];
     j++;
    } // for loop slut.
  }

  // For loop der kryptere de enkelte blocks.
  for (int i = 0; i < blocks.length; i++) {
    
    // Definere variabler til kryptering.
    BigInteger block = new BigInteger(blocks[i]);
    BigInteger temp = block;
    BigInteger j;
    
    // For loop der opløfter bloken i krypterings eksponenten.
    for (j = new BigInteger("0"); j.compareTo(keys[1].subtract(one)) < 0; j = j.add(one)) {
      block = block.multiply(temp);
    } // for loop slut
    
    // Modulo den opløftede blok mod N.
    block = block.mod(keys[0]);
    
    // Gemmer den krypterede blok.
    blocks[i] = block.toString();
  }
  
  // Definere en string som skal sendes til serveren.
  String toSend = "";

  // For loop der går alle bloksne igennem og tilføjer dem til stringen.
  for (int i = 0; i < blocks.length; i++) {
    toSend = toSend + blocks[i] + ",";
  }
  
  // Sender den krypterede data til serveren.
  c.write(toSend);
}
