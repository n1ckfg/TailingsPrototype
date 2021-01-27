WorldParser wp;
Target target;
float globalRot = 0;
float globalRotStep = 0.005;

void setup() {
  size(1024, 768, P3D);
  bloomSetup();
  frameRate(30);
  
  wp = new WorldParser();
  
  boxFluidSetup();
  noiseSetup();
}

void draw() { 
  background(127);
  
  wp.update();
  boxFluidDraw();
  noiseDraw();

  tex.beginDraw();
  tex.background(0);
  
  tex.tint(200, 255, 200, 40);
  tex.image(layer1, 0, 0);
  tex.tint(200 + random(55), 200);
  tex.image(layer2, 0, 0);
  tex.endDraw();
  
  bloomDraw();
  
  globalRot += globalRotStep;
  
  surface.setTitle("" + frameRate);
}
