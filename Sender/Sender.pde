import java.math.BigInteger;
import processing.net.*;
import controlP5.*;

Client c;
String input;
boolean gotKeys = false;
BigInteger[] keys = new BigInteger[2];
BigInteger one = new BigInteger("1");

ControlP5 P5;
controlP5.Textfield Send;

void setup() {
  P5 = new ControlP5(this);
  size(500, 500);
  background(30);
  startFunktion();
  c = new Client(this, "192.168.87.178", 12345);
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
  String[] blocks = new String[0];
  String blockChain = "";
  for (int i = 0; i < text.length(); i++) {
    if (int(text.charAt(i)) < 10) {
      blockChain = blockChain + "00" + str(int(text.charAt(i))) + ",";
    } else if (int(text.charAt(i)) > 10 && int(text.charAt(i)) < 100) {
      blockChain = blockChain + "0" + str(int(text.charAt(i))) + ",";
    } else blockChain = blockChain + str(int(text.charAt(i))) + ",";
  }

  String[] blocksString = blockChain.split(","); //<>//

  if (blocksString.length % 2 == 1) {
    blocks = expand(blocks, blocksString.length/2+1);
    int j = 0;
    for (int i = 0; i < blocks.length-1; i++) {
     blocks[i] = blocksString[j];
     j++;
     blocks[i] = blocks[i] + blocksString[j];
     j++;
    }
    blocks[blocks.length-1] = blocksString[blocksString.length-1] + "000";
  } else {
    blocks = expand(blocks, blocksString.length/2);
    int j = 0;
    for (int i = 0; i < blocks.length; i++) {
     blocks[i] = blocksString[j];
     j++;
     blocks[i] = blocks[i] + blocksString[j];
     j++;
    }
  }

  for (int i = 0; i < blocks.length; i++) {
    BigInteger block = new BigInteger(blocks[i]);
    BigInteger temp = block;
    BigInteger j;
    for (j = new BigInteger("0"); j.compareTo(keys[1].subtract(one)) < 0; j = j.add(one)) {
      block = block.multiply(temp);
    }
    block = block.mod(keys[0]);
    blocks[i] = block.toString();
  }

  String toSend = "";

  for (int i = 0; i < blocks.length; i++) {
    toSend = toSend + blocks[i] + ",";
  }
  c.write(toSend);
}
