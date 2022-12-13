/*
  Besked modtager som anvender RSA-kryptering.
  
  Programmet er lavet til at udregne de offentlige og private nøgler.
  Sende dem til en client.
  Modtage og dekryptere beskeder.
  
  Udviklet af Kristoffer Nielsen
*/

// Importere biblioteker der skal bruges.
// Importere BigInteger bibliotek
import java.math.BigInteger;

// Importere processing.net
import processing.net.*;

// Definere server side variabler.
Server s;
Client c;
Client client;
String input;

// Definere variabler der skal bruges til RSA delen.
String[] keys;
BigInteger p, q, N, euler, e, d;
BigInteger one = new BigInteger("1");
BigInteger tiK = new BigInteger("10000");

// Void setup køre engang når programmet starter.
void setup() {
  // Loader data fra keys.txt filen.
  keys = loadStrings("keys.txt");
  
  // Definere primtal p og q
  p = new BigInteger(keys[1]);
  q = new BigInteger(keys[2]);
  
  // Diverse funktioner for selve vinduet.
  size(500, 500);
  background(0);
  frameRate(10);
  
  // Hvis det er første gang programmet køres eller det har fået nye primtal.
  if (int(keys[0]) == 0) {
    // Køre funktioner til at lave keys
    createPublic();
    createPrivate();
    
    // Siger at keys er genereret til fremtidig brug, og gemmer dem.
    keys[0] = "1";
    saveStrings("keys.txt", keys);
    
  // Hvis det ikke er første gang og nøglerne allerade er lavet.
  } else {
    // Henter variabler fra keys.txt filen.
    N = new BigInteger(keys[3]);
    euler = new BigInteger(keys[4]);
    e = new BigInteger(keys[5]);
    d = new BigInteger(keys[6]);
  }
  
  // Udskriver variabler til consolen.
  println("P = " + keys[1]);
  println("Q = " + keys[2]);
  println("N = " + keys[3]);
  println("Euler = " + keys[4]);
  println("E = " + keys[5]);
  println("D = " + keys[6]);
  
  // Vælger text størelse og position.
  textAlign(CENTER);
  textSize(50);
  
  // Starter servern og åbner for clients.
  s = new Server(this, 12345);
  
  // Udskriver at servern er klar
  println("Ready for Client");
} // setup done.

// Kaldes når en ny client connecter til serveren
void serverEvent(Server someServer, Client someClient) {
  // Udskriver at en client er connectet
  println("Client connected: " + someClient.ip());
  
  // Gemmer den nye client
  client = someClient;
  
  // Sender den offentlige nøgle til clienten.
  String toSend = "Connected," + keys[3] + "," + keys[5];
  client.write(toSend);
}

// Void draw looper igen og igen.
void draw() {
  // Lytter efter input fra clienter
  c = s.available();
  // Hvis modtager information.
  if (c != null) {
    input = client.readString();
    println(input);
    
    // Kalder dekrypterings funktion.
    decryptInput(input);
  }
} // draw slut

// dekrypterings funktion.
void decryptInput(String in) {
  // Opdeler inputet til de forskellige text blokke.
  String[] blocks = in.split(",");
  
  // Looper alle bloksne igennem.
  for (int i = 0; i < blocks.length; i++) {
    // Definere variabler.
    BigInteger block = new BigInteger(blocks[i]);
    BigInteger tempBlock = block;
    BigInteger k;
    
    // Opløfter blokken i dekrypterings eksponenten.
    for (k = new BigInteger("0"); k.compareTo(d.subtract(one)) < 0; k = k.add(one)) {
      block = block.multiply(tempBlock);
      
      // Udskriver til consol, så man kan se hvor langt programmet er.
      if (k.mod(tiK) == BigInteger.ZERO) {
        println(k);
      }
    } // Opløftnings loop slut.
    
    // modulo den opløftede block med N.
    block = block.mod(N);
    
    // Gør blokken klar til at blive lavet om fra tal til bogstaver.
    String temp = block.toString();
    if (temp.length() < 6) {
      if (temp.length() < 5) {
        blocks[i] = "00" + block.toString();
      } else {
        blocks[i] = "0" + block.toString();
      }
    } else {
      blocks[i] = block.toString();
    }
  } // Looper alle bloks slut.
  
  // Definere array til bogstaver.
  char[] chars = new char[blocks.length*2];
  
  // Definere variabel.
  int j = 0;
  
  // Går alle bloksne igennem og laver tallende om til bogstaver.
  for (int i = 0; i < blocks.length; i++) {
    chars[j] = char(int(blocks[i].substring(0, 3)));
    j++;
    chars[j] = char(int(blocks[i].substring(3)));
    j++;
  } // blocks til bogstaver loop slut.
 
  // Laver den string der skal vises på skærmen
  String toDisplay = "";
  for  (int i = 0; i < chars.length; i++) {
    toDisplay = toDisplay + chars[i];
  }// String loop slut.
  
  // Udskriver den dekrypterede tekst på skærmen.
  background(0);
  text(toDisplay, width/2, height/2);
} // Dekrypterings funktion slut.

// Udregner den offentlige nøgle N produktet af p og q.
void createPublic() {
  // Udregner produktet af p og q
  N = p.multiply(q);
  
  // Udvider keys arrayet.
  keys = expand(keys, keys.length+1);
  
  // Gemmer N.
  keys[3] = N.toString();
} // createPublic slut

// Udregner den private nøgle og krypterings eksponenten.
void createPrivate() {
  // Udregner Eulers phi-funktion, for p og q.
  BigInteger p1 = p.subtract(one);
  BigInteger q1 = q.subtract(one);
  euler = p1.multiply(q1);
  
  // Udvider keysarray
  keys = expand(keys, keys.length+1);
  
  // Gemmer Eulers phi-funktion, for p og q.
  keys[4] = euler.toString();
  
  // Definere variabler for at finde krypteringseksponenten e.
  BigInteger e = new BigInteger("1");
  boolean found = false;
  
  // While loop til at finde det første tal der er indbyrdes primisk med
  // Eulers phi-funktion for p og q.
  while (found == false) {
    // Lægger en til e.
    e = e.add(one);
    
    // Definere variabel GCD
    BigInteger GCD;
    
    // Kalder gcd() funktionen som finder gcd for to tal.
    GCD = gcd(e, euler);
    
    // Hvis gcd for e og phi-funktionen er 1.
    if (GCD.compareTo(one) == 0) {
      // Fortæller at e er fundet.
      found = true;
      
      // Udvider keys arrayet og gememr e.
      keys = expand(keys, keys.length+1);
      keys[5] = e.toString();
    }
  } // While loop slut
  
  // Definere variabler for Euklids udvided algoritme.
  BigInteger l1[] = {euler, one, BigInteger.ZERO};
  BigInteger l2[] = {e, BigInteger.ZERO, one};
  
  // While loop, køre indtil Euklids udvided algoritme har en rest på 0
  while (((l1[0].subtract(l2[0])).multiply((l1[0].divide(l2[0])))).compareTo(BigInteger.ZERO) > 0) {
    // laver udregningerne for Euklids udvided algoritme.
    BigInteger l3[] = l2;
    BigInteger q = l1[0].divide(l2[0]);
    l2[0] = (l1[0].subtract(l2[0])).multiply(q);
    l2[1] = (l1[1].subtract(l2[1])).multiply(q);
    l2[2] = (l1[2].subtract(l2[2])).multiply(q);
    l1 = l3;
  } // While loop slut
  
  // Udregner x' så vi ikke for en negativ dekrypteringseksponent.
  if (l1[2].compareTo(BigInteger.ZERO) < 0) {
    l1[2] = l1[2].add(euler);
  }
  
  // Udvider keys arrayet og gemmer d.
  keys = expand(keys, keys.length+1);
  d = l1[2];
  keys[6] = l1[2].toString();
} // createPrivate slut. 

// Funktion til at finde største fælles devisor.
BigInteger gcd(BigInteger a, BigInteger b) {
  
  // While loop køre så længe a er forskellig fra b.
  while (a.compareTo(b) != 0) {
    
    // Hvis a er støre end b
    if (a.compareTo(b) > 0) {
      a = a.subtract(b);
      // Hvis b er støre end a.
    } else { 
      b = b.subtract(a);
    }
  } // While loop slut
  
  // Når while loop et slutter er b = gcd(a, b).
  // Sender b tilbage.
  return b;
}
