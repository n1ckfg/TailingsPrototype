WorldParser wp;
Target target;

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
  
  tex.tint(255, 40);
  tex.image(layer1, 0, 0);
  tex.noTint();
  tex.image(layer2, 0, 0);
  tex.endDraw();
  
  bloomDraw();
  
  surface.setTitle("" + frameRate);
}
