import java.math.BigInteger;
import processing.net.*;

Client c;
String input;
String[] publicKey;
Boolean gotKey;
BigInteger N, sqrtN;
BigInteger[][] solutions = new BigInteger[0][2];

void setup() {
  c = new Client(this, "", 12345);
}

void draw() {
  if (!gotKey) {
    if (c.available() > 0) {
      input = c.readString();
      publicKey = input.split(",");
      if (publicKey[0].equals("Connected")) {
        gotKey = true;
      }
    }
  }
  if (gotKey) {
    solutionFinder(publicKey[1]);
    String[] toSave = new String[solutions.length];
    for (int i = 0; i < solutions.length; i++) {
      toSave[i] = solutions[i][0] + "," + solutions[i][1];
    }
    saveStrings("solutions.txt", toSave);
  }
}

void solutionFinder(String publicKey) {
  N = new BigInteger(publicKey);
  sqrtN = sqrt(N);
  if (sqrtN.getLowestSetBit() == 0) sqrtN = sqrtN.subtract(BigInteger.ONE);
  BigInteger i;
  for (i = sqrtN; i.compareTo(BigInteger.ZERO) > 1; i = i.subtract(BigInteger.valueOf(2))) {
    if (sqrtN.mod(i) == BigInteger.ZERO) {
      solutions = new BigInteger[solutions.length+1][2];
      solutions[solutions.length-1][0] = i;
    }
  }
  for (int k = 0; k < solutions.length; k++) {
    BigInteger q = N.divide(solutions[k][0]);
    solutions[k][1] = q;
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
