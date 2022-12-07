import java.math.BigInteger;
import processing.net.*;

Client c;
String input;
Boolean gotKey;
BigInteger[][] solutions = new BigInteger[0][2];

void setup() {
  c = new Client(this, "", 12345);
}

void draw() {
  if (!gotKey) {
    if (c.available() > 0) {
      input = c.readString();
      String[] publicKey = input.split(",");
      if (publicKey[0].equals("Connected")) {
        solutionFinder(publicKey[1]);
      }
    }
  }
}

void solutionFinder(String publicKey) {
  
}
