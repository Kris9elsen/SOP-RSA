import java.math.BigInteger;


BigInteger x = new BigInteger("1");
BigInteger euler = new BigInteger("91");
BigInteger one = new BigInteger("1");
boolean found = false;


void setup() {
  while (found == false) {
    x = x.add(one);
    BigInteger GCD;
    GCD = gcd(x, euler);
    if (GCD.compareTo(one) == 0) {
      found = true;
      println("GCD = " + x);
    }
  }
}

BigInteger gcd(BigInteger a, BigInteger b) {
  while (a.compareTo(b) != 0) {
    if (a.compareTo(b) > 0) {
      a = a.subtract(b);
    } else {
      b = b.subtract(a);
    }
  }
  return b;
}
