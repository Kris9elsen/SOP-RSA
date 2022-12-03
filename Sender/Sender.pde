import java.math.BigInteger;
import processing.net.*;
import controlP5.*;

Client c;
String input;
boolean gotKeys = false;
BigInteger[] keys = new BigInteger[2];

ControlP5 P5;
controlP5.Textfield Send;

void setup() {
  P5 = new ControlP5(this);
  size(500, 500);
  background(30);
  startFunktion();
  c = new Client(this, "192.168.87.124", 12345);
}

void draw() {
  if (!gotKeys) {
    if (c.available() > 0) {
      input = c.readString();
      String[] in = input.split(",");
      if (in[0].equals("Connected")) {
        keys[0] = new BigInteger(in[1]);
        keys[1] = new BigInteger(in[2]);
        println("N = " + keys[0] + " E = " + keys[1]);
        gotKeys = true;
      }
    }
  }
}

void startFunktion() {
  PFont font = createFont("arial", 35);

  Send = P5.addTextfield("Send")
    .setPosition(width/2-100, height/2-25)
    .setColorBackground(color(50))
    .setFont(font)
    .setSize(200, 50)
    .setFocus(true)
    .setColor(color(255))
    .setLabel("")
    ;
}

public void Send(String in) {
  krypterSend(in);
}

void krypterSend(String text) {
  
}
