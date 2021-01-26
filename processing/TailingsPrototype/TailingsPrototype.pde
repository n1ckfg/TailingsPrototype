import peasy.PeasyCam;

PeasyCam cam;

WorldParser wp;

void setup() {
  size(1024, 768, P3D);
  cam = new PeasyCam(this, 400);
  wp = new WorldParser();
}

void draw() {
  background(0);
  
  pushMatrix();
  translate(0, 0, 200);
  box(40);
  popMatrix();
}
