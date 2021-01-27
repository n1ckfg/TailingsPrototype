import peasy.PeasyCam;

PeasyCam cam;

WorldParser wp;
Target target;

void setup() {
  size(1024, 768, P3D);
  frameRate(60);
  
  cam = new PeasyCam(this, 300);
  wp = new WorldParser();
  
  boxFluidSetup();
  noiseSetup();
}

void draw() { 
  background(0);

  wp.update();
  
  boxFluidDraw();
  noiseDraw();
  
  surface.setTitle("" + frameRate);
}
