// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/6z7GQewK-Ks
// --------------------------------------
// Edited by Toby Lockley on 2017-03-24
// Added rainbow COLORS and zooming
// Left click on a spot to zoom to, set this spot to center of screen
// Spacebar zooms into center
// Right click resets sketch

// SETTINGS
final int MAXITERATIONS = 200; // Maximum number of iterations for each point on the complex plane
final int COLORS = 20; // Number of different COLORS to use
final float SAT = 0.8; // This makes it a bit easier on the eyes
final float ZOOMFACTOR = 2; // Bigger = more zoom
final int MAXZOOM = 17; // Set this higher to see the precision limit behaviour

// Some global variables to save our zoom state
boolean clickFlag = false; // Used to choose zoom origin
boolean spacebarFlag = false; // Used to zoom into the center
float rangeX = 5; // This is a good starting value to see the whole set
float rangeY; // Calculate the following during setup
float xmin; // x goes from xmin to xmax
float ymin;
float xmax;
float ymax; // y goes from ymin to ymax
int zoomStep = 0; // Keeps track of how many times we zoom

void setup() {
  size(640, 480);
  colorMode(HSB, COLORS);
  rangeY = (rangeX * height) / width;
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
      while (n < MAXITERATIONS) {
        float aa = a * a;
        float bb = b * b;
        if (aa + bb > 4) { // All numbers outside circle radius 2 tend to infinity
          break;  // Bail
        }
        float twoab = 2.0 * a * b;
        a = aa - bb + x;
        b = twoab + y;
        n++;
      }

      // We color each pixel based on how long it takes to get to infinity
      // If we never got there, let's pick the color black
      if (n == MAXITERATIONS) {
        pixels[i+j*width] = color(0);
      } else {
        int c = n % COLORS;
        pixels[i+j*width] = color(c, COLORS * SAT, COLORS);
      }
      x += dx;
    }
    y += dy;
  }
  updatePixels();
  //println(frameRate);
}

void zoom(float newOriginX, float newOriginY) {
  float zoomDiffX = (xmax - xmin) / (2 * ZOOMFACTOR); // We use these to determine new xy range
  float zoomDiffY = (ymax - ymin) / (2 * ZOOMFACTOR); // The 2 splits the zoom range in half to add to newOriginX/Y
  
  if (zoomStep <= MAXZOOM) {
    xmin = newOriginX - zoomDiffX;
    ymin = newOriginY - zoomDiffY;
    xmax = newOriginX + zoomDiffX;
    ymax = newOriginY + zoomDiffY;
    zoomStep++;
    println("New range: [" + xmin + ", " + xmax + "], [" + ymin + ", " + ymax + "]");
  }
  else {
    println("Max zoom reached.");
  }
}

void resetXY() {
  xmin = -rangeX/2; // Start at negative half the width and height
  ymin = -rangeY/2;
  xmax = xmin + rangeX;
  ymax = ymin + rangeY;
  zoomStep = 0;
}

void mouseClicked() {
  clickFlag = true;
}

void keyPressed() {
  if (key == ' ') spacebarFlag = true;
}