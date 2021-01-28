WorldParser wp;
Target target;
float globalRot = 0;
float globalRotStep = 0.005;

void setup() {
  size(1024, 768, P3D);
  frameRate(30);
  
  wp = new WorldParser();
  wp.start();
  
  boxFluidSetup();
  noiseSetup();
  bloomSetup();
}

void draw() { 
  background(127);
  
  boxFluidDraw();
  noiseDraw();

  tex.beginDraw();
  tex.background(0);

  tex.tint(60 + random(15));
  tex.image(layer0, 0, 0);
  
  layer1.filter(shader_sharpen);
  tex.tint(200, 255, 200, 40);
  tex.image(layer1, 0, 0);

  tex.tint(200 + random(55), 0, 0);
  tex.image(layer2, 0, 0);
 
  tex.endDraw();
  
  bloomDraw();

  globalRot += globalRotStep;
  
  surface.setTitle("" + frameRate);
}
