/*
  RSA-krypterings cracker.
  
  Programmet er lavet til at forbinde ti len server.
  Modtage den offentlige nøgle og bruge den til at fidne frem til de originale primtal.
  Med de originale primtal kan man så aflæse andres beskeder.
  
  Udviklet af Kristoffer Nielsen.
*/

// Importere biblioteker.
// Importere BigInteger biblioteket.
import java.math.BigInteger;

// Importere processing.net blioteket.
import processing.net.*;

// Definere vriabler for client.
Client c;
String input;

// Definere variabler der skal bruges for at finde primtals faktorende.
String[] publicKey;
String[] solutions = new String[0];
Boolean gotKey = false;
Boolean foundSolutions = false;
BigInteger N, sqrtN;
BigInteger one = new BigInteger("1");

// Void setup køre engang når programmet startes.
void setup() {
  // Starter clienten og forbinder til serveren.
  c = new Client(this, "192.168.87.124", 12345);
} // setup slut.

// Void draw looper over og over så længe programmet køre.
void draw() {
  // Hvis vi endnu ikke har modtaget den offentlige nøgle
  if (!gotKey) {
    // Lytter efter input fra serverren.
    if (c.available() > 0) {
      // Læser input fra serveren.
      input = c.readString();
      publicKey = input.split(",");
      // Hvis input fra serveren er den offentlige nøgle.
      if (publicKey[0].equals("Connected")) {
        println(input);
        gotKey = true;
      }
    }
  }
  
  // Hvis vi har modatget den offentlige nøgle og ikke har fundet løsningen endnu.
  if (gotKey && !foundSolutions) {
    // Kalder solutionFinder funktion.
    solutionFinder(publicKey[1]);
    
    // Gemmer løsningen i solutions.txt
    saveStrings("solutions.txt", solutions);
    foundSolutions = true;
  }
} // draw slut.

// SolutionFinder funktion, finder alle løsninger til den offentlige nøgle.
void solutionFinder(String publicKey) {
  
  // Sætter den offentlige nøgle til N
  N = new BigInteger(publicKey);
  
  // kalder kvadratrodsfunktion og får kvadratroden af den offentlige nøgle.
  sqrtN = sqrt(N);
  
  // Hvis kvadrat roden er et lige tal trækkes der en fra så det bliver ulige.
  if (sqrtN.mod(BigInteger.valueOf(2)) == BigInteger.ZERO) sqrtN.subtract(one);
  BigInteger i;
  
  // For loop der tester om alle ulige tal mindre end kvadratroden af N går op i N.
  for (i = sqrtN; i.compareTo(BigInteger.ZERO) > 0; i = i.subtract(BigInteger.valueOf(2))) {
    // Hvis tallet går op i N.
    if (N.mod(i) == BigInteger.ZERO) {
      // Udskriver til consol at den har fundet en.
      println(N + " MOD " + i + " = 0");
      // Udvider solutions array og gemmer muligheden.
      solutions = expand(solutions, solutions.length+1);
      solutions[solutions.length-1] = i.toString();
    }
  } // for loop slut
  
  // For loop der fidner det andet tal for alle løsninger fundet i tidligere for loop.
  for (int k = 0; k < solutions.length; k++) {
    // Henter mulighed fra solutions array.
    BigInteger p = new BigInteger(solutions[k]);
    
    // Finder det andet tal i løsningen.
    BigInteger q = N.divide(p);
    
    // Gemmer det andet tal i løsningen.
    solutions[k] = solutions[k] + "," + q.toString();
  } // for loop slut
} // solutionFinder slut.

// Kvadratrods funktion, fidner kvadratroden af et give tal.
BigInteger sqrt(BigInteger x) { 
  // Sætter bit værdien ved bit nr halvdelen af længden af bitsne i x til 0.
  BigInteger div = BigInteger.ZERO.setBit(x.bitLength()/2);
  
  // Siger at div2 = div.
  BigInteger div2 = div;
  
  // For loop der køre indtil der bliver tilbage sendt en værdi.
  for (;; ) {
    // Udregner y til at være div + (x/div), og bitsne skubbes mod højre med 1.
    BigInteger y = div.add(x.divide(div)).shiftRight(1);
    
    // Hvis y enten er ligmed div eller div2.
    if (y.equals(div) || y.equals(div2))
      // Sendes y tilbage som er kvadratroden af x.
      return y;
    
    // Hvis kvadrat roden ikke er fundet endnu. Laver den udregningen igen.
    div2 = div;
    div = y;
  } // for loop slut.
} // kvadratrods funktion slut.
