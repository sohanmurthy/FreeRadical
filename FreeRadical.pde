/********************************************************

FREE RADICAL
Sohan Murthy
2017

FREE RADICAL is an LED art installation located in a
private residence in South Carolina. This program
controls 480 individually addressable LEDs, and mimics
light filtering through a dense forest.

*********************************************************/

import ddf.minim.*;

final static int INCHES = 1;
final static int FEET = 12*INCHES;
final static int SECONDS = 1000;
final static int MINUTES = 60*SECONDS;

Model model;
P3LX lx;
LXOutput output;
UI3dComponent pointCloud;

void setup() {

  model = new Model();
  lx = new P3LX(this, model);

  lx.setPatterns(new LXPattern[] {

    new Spirals(lx),
    new Shadows(lx),
    new ColorSwatches(lx, 20),
    //new IteratorTestPattern(lx),
    //new BaseHuePattern(lx),

  });

  final LXTransition multiply = new MultiplyTransition(lx).setDuration(11.22*MINUTES);

  for (LXPattern p : lx.getPatterns()) {
    p.setTransition(multiply);
  }

  lx.enableAutoTransition(9*MINUTES);

  output = buildOutput();

  // Adds UI elements -- REMOVE if running on Linux in a headless environment
  size(640, 480, P3D);
  lx.ui.addLayer(
   new UI3dContext(lx.ui)
   .setCenter(model.cx, model.cy, model.cz)
   .setRadius(6*FEET)
   .setTheta(PI/6)
   .setPhi(PI/64)
   .addComponent(pointCloud = new UIPointCloud(lx, model).setPointSize(4))
  );

}


void draw() {
  background(#191919);
}
