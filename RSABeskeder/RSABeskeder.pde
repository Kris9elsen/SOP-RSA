
import java.math.BigInteger;

BigInteger p, q, publicKey, privateKey, msg, en, mp, mq, helpValue;

void setup() {
  p = new BigInteger("331");
  q = new BigInteger("149");
  en = new BigInteger("1");
  msg = new BigInteger("1017");
  helpValue = new BigInteger("41863");
  int k = 7;
  publicKey = p.multiply(q);
  mp = p.subtract(en);
  mq = q.subtract(en);
  privateKey = mp.multiply(mq);
  println("Public key = " + publicKey);
  println("Private key = " + privateKey);
  println();
  msg = krypter(publicKey, msg, k);
  println("Krypteret besked = " + msg);
  println("dekrypteret besked = " + dekrypter(privateKey, helpValue, msg));

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

BigInteger dekrypter(BigInteger key1, BigInteger u, BigInteger tekst) {
  BigInteger i;
  BigInteger krypto;
  krypto = tekst;
  println(krypto);
  i = new BigInteger("0");
  println(u);
  println(u);
  while (i.compareTo(u) < 0) {
    krypto = krypto.multiply(tekst);
    i = i.add(en);
  }
  println("i = " + i);
  //println("Krypto in u = " + krypto);
  krypto = krypto.mod(key1);
  return krypto;
}
