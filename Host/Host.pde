import java.math.BigInteger;
import processing.net.*;

Server s;
Client c;
Client client;
String input;
String toDisplay = "GAY NIGGA";
String[] keys;
BigInteger p, q, N, euler, e;
BigInteger one = new BigInteger("1");

void setup() {
  keys = loadStrings("keys.txt");
  p = new BigInteger("331");
  q = new BigInteger("149");
  size(500, 500);
  background(0);
  frameRate(10);
  if (int(keys[0]) == 0) {
    createPublic();
    createPrivate();
    keys[0] = "1";
  }
  println("P = " + keys[1]);
  println("Q = " + keys[2]);
  println("N = " + keys[3]);
  println("Euler = " + keys[4]);
  println("E = " + keys[5]);
  //println("D = " + keys[6]);
  textAlign(CENTER);
  textSize(50);
  s = new Server(this, 12345);
}

void serverEvent(Server someServer, Client someClient) {
  println("Client connected: " + someClient.ip()); 
  client = someClient;
  client.write("Connected," + keys[3] + "," + keys[5]);
}

void draw() {
  c = s.available();
  if (c != null) {
    toDisplay = stringInput();
  }
  
  text(toDisplay, width/2, height/2);
  
}

String stringInput() {
  input = client.readString();
  println(input);
  return input;
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
