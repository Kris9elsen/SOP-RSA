
import java.math.BigInteger;

BigInteger p, q, publicKey, privateKey, msg, en, mp, mq, helpValue;

void setup() {
  p = new BigInteger("53");
  q = new BigInteger("47");
  en = new BigInteger("1");
  msg = new BigInteger("99");
  helpValue = new BigInteger("2105");
  int k = 25;
  publicKey = p.multiply(q);
  mp = p.subtract(en);
  mq = q.subtract(en);
  privateKey = mp.multiply(mq);
  println("Public key = " + publicKey);
  println("Private key = " + privateKey);
  println();
  msg = krypter(publicKey, msg, k);
  println("Krypteret besked = " + msg);
  println("dekrypteret besked = " + dekrypter(publicKey, helpValue, msg));

}

void draw() {

}

BigInteger krypter(BigInteger m, BigInteger tekst,  int k) {
  BigInteger krypto;
  krypto = tekst;
  for (int i = 0; i < k-1; i++) {
    krypto = krypto.multiply(tekst);
  }
  krypto = krypto.mod(m);
  return krypto;
}

BigInteger dekrypter(BigInteger m, BigInteger u, BigInteger tekst) {
  BigInteger i;
  BigInteger krypto;
  krypto = tekst;
  i = new BigInteger("0");
  u = u.subtract(en);
  while (i.compareTo(u) < 0) {
    krypto = krypto.multiply(tekst);
    i = i.add(en);
  }
  krypto = krypto.mod(m);
  return krypto;
}
