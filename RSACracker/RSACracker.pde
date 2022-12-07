import java.math.BigInteger;
import processing.net.*;

Client c;
String input;
String[] publicKey;
String[] solutions = new String[0];
Boolean gotKey = false;
Boolean foundSolutions = false;
BigInteger N, sqrtN;
BigInteger one = new BigInteger("1");




void setup() {
  c = new Client(this, "192.168.87.124", 12345);
}

void draw() {
  if (!gotKey) {
    if (c.available() > 0) {
      input = c.readString();
      publicKey = input.split(",");
      if (publicKey[0].equals("Connected")) {
        println(input);
        gotKey = true;
      }
    }
  }
  if (gotKey && !foundSolutions) {
    solutionFinder(publicKey[1]);
    saveStrings("solutions.txt", solutions);
    foundSolutions = true;
  }
}

void solutionFinder(String publicKey) {
  N = new BigInteger(publicKey);
  sqrtN = sqrt(N);
  if (sqrtN.mod(BigInteger.valueOf(2)) == BigInteger.ZERO) sqrtN.subtract(one);
  BigInteger i;
  for (i = sqrtN; i.compareTo(BigInteger.ZERO) > 0; i = i.subtract(BigInteger.valueOf(2))) {
    if (N.mod(i) == BigInteger.ZERO) {
      println(N + " MOD " + i + " = 0");
      solutions = expand(solutions, solutions.length+1);
      solutions[solutions.length-1] = i.toString();
    }
  }
  for (int k = 0; k < solutions.length; k++) {
    BigInteger p = new BigInteger(solutions[k]);
    BigInteger q = N.divide(p);
    solutions[k] = solutions[k] + "," + q.toString();
  }
}

BigInteger sqrt(BigInteger x) { 
  BigInteger div = BigInteger.ZERO.setBit(x.bitLength()/2);
  BigInteger div2 = div;
  for (;; ) {
    BigInteger y = div.add(x.divide(div)).shiftRight(1);
    if (y.equals(div) || y.equals(div2))
      return y;
    div2 = div;
    div = y;
  }
}
