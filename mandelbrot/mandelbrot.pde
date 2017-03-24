// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/6z7GQewK-Ks
// --------------------------------------
// Edited by Toby Lockley on 2017-03-24
// Added rainbow colors and zooming
// Left click on a spot to zoom to, set this spot to center of screen
// Spacebar zooms into center
// Right click resets sketch

final int maxiterations = 200; // Maximum number of iterations for each point on the complex plane
final int colors = 20; // Number of different colors to use
final float sat = 0.8; // This makes it a bit easier on the eyes
final float zoomLevel = 2; // How far to zoom each click

// Some global variables to save our zoom state
boolean clickFlag = false; // Used to choose zoom origin
boolean spacebarFlag = false; // Used to zoom into the center
float initW = 5; // This is a good starting value to see the whole set
float initH;
float xmin; // Calculate these in setup
float ymin;
float xmax; // x goes from xmin to xmax
float ymax; // y goes from ymin to ymax

void setup() {
  size(640, 480);
  colorMode(HSB, colors);
  initH = (initW * height) / width;
  resetXY();
}

void draw() {
  background(255);

  // Make sure we can write to the pixels[] array.
  // Only need to do this once since we don't do any other drawing.
  loadPixels();
  
  // Using "else if" so we only process one at a time
  if (clickFlag && (mouseButton == LEFT)) {
    float clickX = map(mouseX, 0, width, xmin, xmax);
    float clickY = map(mouseY, 0, height, ymin, ymax);
    zoom(clickX, clickY);
    clickFlag = false;
  }
  else if (clickFlag && (mouseButton == RIGHT)) {
    resetXY();
    clickFlag = false;
  }
  else if (spacebarFlag) {
    float zeroX = xmin + (xmax - xmin) / 2; // Find the current origin values
    float zeroY = ymin + (ymax - ymin) / 2;
    zoom(zeroX, zeroY); // Zoom into the center
    spacebarFlag = false;
  }

  // Calculate amount we increment x,y for each pixel
  float dx = (xmax - xmin) / (width);
  float dy = (ymax - ymin) / (height);

  // Start y
  float y = ymin;
  for (int j = 0; j < height; j++) {
    // Start x
    float x = xmin;
    for (int i = 0; i < width; i++) {

      // Now we test, as we iterate z = z^2 + cm does z tend towards infinity?
      float a = x;
      float b = y;
      int n = 0;
      while (n < maxiterations) {
        float aa = a * a;
        float bb = b * b;
        if (aa + bb > initW) {
          break;  // Bail
        }
        float twoab = 2.0 * a * b;
        a = aa - bb + x;
        b = twoab + y;
        n++;
      }

      // We color each pixel based on how long it takes to get to infinity
      // If we never got there, let's pick the color black
      if (n == maxiterations) {
        pixels[i+j*width] = color(0);
      } else {
        int c = n % colors;
        pixels[i+j*width] = color(c, colors * sat, colors);
      }
      x += dx;
    }
    y += dy;
  }
  updatePixels();
  //println(frameRate);
}

void zoom(float newOriginX, float newOriginY) {
  float zoomDiffX = (xmax - xmin) / (2 * zoomLevel); // We use these to determine new xy range
  float zoomDiffY = (ymax - ymin) / (2 * zoomLevel); // The 2 splits the zoom range in half to add to newOriginX/Y
  xmin = newOriginX - zoomDiffX;
  ymin = newOriginY - zoomDiffY;
  xmax = newOriginX + zoomDiffX;
  ymax = newOriginY + zoomDiffY;
  println("New range: [" + xmin + ", " + xmax + "], [" + ymin + ", " + ymax + "]");
}

void resetXY() {
  xmin = -initW/2; // Start at negative half the width and height
  ymin = -initH/2;
  xmax = xmin + initW;
  ymax = ymin + initH;
}

void mouseClicked() {
  clickFlag = true;
}

void keyPressed() {
  if (key == ' ') spacebarFlag = true;
}