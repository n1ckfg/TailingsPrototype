import peasy.PeasyCam;

PeasyCam cam;

WorldParser wp;

void setup() {
  size(1024, 768, P3D);
  frameRate(60);
  pixelDensity(1);
  cam = new PeasyCam(this, 300);
  wp = new WorldParser();
  
  boxFluidSetup();
  noiseSetup();
}

void draw() {
  background(0);
  
  boxFluidDraw();
  noiseDraw();
  
  surface.setTitle("" + frameRate);
}
