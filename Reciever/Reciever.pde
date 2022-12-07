import java.math.BigInteger;
import processing.net.*;

Server s;
Client c;
Client client;
String input;
String[] keys;
BigInteger p, q, N, euler, e, d;
BigInteger one = new BigInteger("1");
BigInteger tiK = new BigInteger("10000");

void setup() {
  keys = loadStrings("keys.txt");
  p = new BigInteger(keys[1]);
  q = new BigInteger(keys[2]);
  size(500, 500);
  background(0);
  frameRate(10);
  if (int(keys[0]) == 0) {
    createPublic();
    createPrivate();
    keys[0] = "1";
    saveStrings("keys.txt", keys);
  } else {
    N = new BigInteger(keys[3]);
    euler = new BigInteger(keys[4]);
    e = new BigInteger(keys[5]);
    d = new BigInteger(keys[6]);
  }
  println("P = " + keys[1]);
  println("Q = " + keys[2]);
  println("N = " + keys[3]);
  println("Euler = " + keys[4]);
  println("E = " + keys[5]);
  println("D = " + keys[6]);
  textAlign(CENTER);
  textSize(50);
  s = new Server(this, 12345);
  println("Ready for Client");
}

void serverEvent(Server someServer, Client someClient) {
  println("Client connected: " + someClient.ip()); 
  client = someClient;
  String toSend = "Connected," + keys[3] + "," + keys[5];
  client.write(toSend);
}

void draw() {
  c = s.available();
  if (c != null) {
    input = client.readString();
    println(input);
    decryptInput(input);
  }
}

void decryptInput(String in) {
  String[] blocks = in.split(",");
  for (int i = 0; i < blocks.length; i++) {
    BigInteger block = new BigInteger(blocks[i]);
    BigInteger tempBlock = block;
    BigInteger k;
    for (k = new BigInteger("0"); k.compareTo(d.subtract(one)) < 0; k = k.add(one)) {
      block = block.multiply(tempBlock);
      if (k.mod(tiK) == BigInteger.ZERO) {
        println(k);
      }
    }
    block = block.mod(N);
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
  }
  char[] chars = new char[blocks.length*2];
  int j = 0;
  for (int i = 0; i < blocks.length; i++) {
    chars[j] = char(int(blocks[i].substring(0, 3)));
    j++;
    chars[j] = char(int(blocks[i].substring(3)));
    j++;
  }
  String toDisplay = "";
  for  (int i = 0; i < chars.length; i++) {
    toDisplay = toDisplay + chars[i];
  }
  background(0);
  text(toDisplay, width/2, height/2);
}

void createPublic() {
  N = p.multiply(q);
  keys = expand(keys, keys.length+1);
  keys[3] = N.toString();
}

void createPrivate() {
  BigInteger p1 = p.subtract(one);
  BigInteger q1 = q.subtract(one);
  euler = p1.multiply(q1);
  keys = expand(keys, keys.length+1);
  keys[4] = euler.toString();
  BigInteger e = new BigInteger("1");
  boolean found = false;
  while (found == false) {
    e = e.add(one);
    BigInteger GCD;
    GCD = gcd(e, euler);
    if (GCD.compareTo(one) == 0) {
      found = true;
      keys = expand(keys, keys.length+1);
      keys[5] = e.toString();
    }
  }
  BigInteger l1[] = {euler, one, BigInteger.ZERO};
  BigInteger l2[] = {e, BigInteger.ZERO, one};
  while (((l1[0].subtract(l2[0])).multiply((l1[0].divide(l2[0])))).compareTo(BigInteger.ZERO) > 0) {
    BigInteger l3[] = l2;
    BigInteger q = l1[0].divide(l2[0]);
    l2[0] = (l1[0].subtract(l2[0])).multiply(q);
    l2[1] = (l1[1].subtract(l2[1])).multiply(q);
    l2[2] = (l1[2].subtract(l2[2])).multiply(q);
    l1 = l3;
  }
  if (l1[2].compareTo(BigInteger.ZERO) < 0) {
    l1[2] = l1[2].add(euler);
  }
  keys = expand(keys, keys.length+1);
  d = l1[2];
  keys[6] = l1[2].toString();
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
