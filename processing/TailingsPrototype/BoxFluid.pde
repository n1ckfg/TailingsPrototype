/* 
 * Copyright (c) 2009 Karsten Schmidt
 * 
 * This demo & library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

import toxi.physics3d.*;
import toxi.physics3d.behaviors.*;
import toxi.physics3d.constraints.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;
import toxi.volume.*;

import java.util.Iterator;
import controlP5.*;

int NUM_PARTICLES = 100; //200;
float REST_LENGTH = 375;
int DIM = 200;

int GRID = 36; //18;
float VS = 2 * DIM / GRID;
Vec3D SCALE = new Vec3D(DIM, DIM, DIM).scale(2);
float isoThreshold = 3;

int numP;
VerletPhysics3D physics;
ParticleConstraint3D boundingSphere;
GravityBehavior3D gravity;

VolumetricSpaceArray volume;
IsoSurface surface1;

TriangleMesh mesh1 = new TriangleMesh("fluid");

boolean isWireFrame = false;
boolean isClosed = true;
boolean useBoundary = true;

Vec3D colAmp = new Vec3D(400, 200, 200);
PGraphics3D layer1;

void boxFluidSetup() {
  initPhysics();
  volume = new VolumetricSpaceArray(SCALE,GRID,GRID,GRID);
  surface1 = new ArrayIsoSurface(volume);
  
  layer1 = (PGraphics3D) createGraphics(width, height, P3D);
}

void boxFluidDraw() { 
  updateParticles();
  computeVolume();

  layer1.beginDraw();
  layer1.background(0);
  layer1.pushMatrix();
  layer1.translate(width/2,height/2,0);
  layer1.rotateY(globalRot);
  layer1.noFill();
  layer1.stroke(255,192);
  layer1.strokeWeight(1);
  layer1.box(physics.getWorldBounds().getExtent().x * 2);

  layer1.ambientLight(216, 216, 216);
  layer1.directionalLight(255, 255, 255, 0, 1, 0);
  layer1.directionalLight(96, 96, 96, 1, 1, -1);
  if (isWireFrame) {
    layer1.stroke(255);
    layer1.noFill();
  } else {
    layer1.noStroke();
    layer1.fill(224, 0, 51);
  }
  layer1.beginShape(TRIANGLES);
  if (!isWireFrame) {
    drawFilledMesh();
  } else {
    drawWireMesh();
  }
  layer1.endShape();

  layer1.popMatrix();
  layer1.endDraw();
}

// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

void computeVolume() {
  float cellSize=(float)DIM*2/GRID;
  Vec3D pos=new Vec3D();
  Vec3D offset=physics.getWorldBounds().getMin();
  float[] volumeData=volume.getData();
  for(int z=0,index=0; z<GRID; z++) {
    pos.z=z*cellSize+offset.z;
    for(int y=0; y<GRID; y++) {
      pos.y=y*cellSize+offset.y;
      for(int x=0; x<GRID; x++) {
        pos.x=x*cellSize+offset.x;
        float val=0;
        for(int i=0; i<numP; i++) {
          Vec3D p=(Vec3D)physics.particles.get(i);
          float mag=pos.distanceToSquared(p)+0.00001;
          val+=1/mag;
        }
        volumeData[index++]=val;
      }
    }
  }
  if (isClosed) {
    volume.closeSides();
  }
  surface1.reset();
  surface1.computeSurfaceMesh(mesh1, isoThreshold * 0.001);
}

void drawFilledMesh() {
  int num = mesh1.getNumFaces();
  mesh1.computeVertexNormals();
  for(int i = 0; i < num; i++) {
    Face f = mesh1.faces.get(i);
    
    Vec3D col = new Vec3D(0,0,255);//f.a.add(colAmp).scaleSelf(0.5);
    layer1.fill(col.x,col.y,col.z);
    normal(f.a.normal);
    vertex(f.a);
    
    col = new Vec3D(0,127,255); //f.b.add(colAmp).scaleSelf(0.5);
    layer1.fill(col.x,col.y,col.z);
    normal(f.b.normal);
    vertex(f.b);
    
    col = new Vec3D(63,127,255); //f.c.add(colAmp).scaleSelf(0.5);
    layer1.fill(col.x,col.y,col.z);
    normal(f.c.normal);
    vertex(f.c);
  }
}

void drawWireMesh() {
  layer1.noFill();
  int num = mesh1.getNumFaces();
  for (int i = 0; i < num; i++) {
    Face f = mesh1.faces.get(i);
    Vec3D col = f.a.add(colAmp).scaleSelf(0.5);
    layer1.stroke(col.x, col.y, col.z);
    vertex(f.a);
    col = f.b.add(colAmp).scaleSelf(0.5);
    layer1.stroke(col.x, col.y, col.z);
    vertex(f.b);
    col = f.c.add(colAmp).scaleSelf(0.5);
    layer1.stroke(col.x, col.y, col.z);
    vertex(f.c);
  }
}

void normal(Vec3D v) {
  layer1.normal(v.x,v.y,v.z);
}

void vertex(Vec3D v) {
  layer1.vertex(v.x,v.y,v.z);
}

// ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

void initPhysics() {
  physics = new VerletPhysics3D();
  physics.setWorldBounds(new AABB(new Vec3D(), new Vec3D(DIM, DIM, DIM)));
  if (surface1 != null) {
    surface1.reset();
    mesh1.clear();
  }
  
  boundingSphere = new SphereConstraint(new Sphere(new Vec3D(), DIM), SphereConstraint.INSIDE);
  gravity = new GravityBehavior3D(new Vec3D(0, 1, 0));
  physics.addBehavior(gravity);
}

void updateParticles() {
  Vec3D grav = Vec3D.Y_AXIS.copy();
  // 1. subtle cycle
  //grav.rotateX(sin(frameCount * 0.01)); 
  //grav.rotateY(cos(frameCount * 0.01)); 
  // 2. follow mouse
  //grav.rotateX(mouseY * 0.01);
  //grav.rotateY(mouseX * 0.01);
  // 3. randomize
  grav.rotateX(wp.target.pos.y * 0.01);
  grav.rotateY(wp.target.pos.x * 0.01);
  gravity.setForce(grav.scaleSelf(2));
  numP = physics.particles.size();
  
  if (random(1) < 0.2 && numP < NUM_PARTICLES) {
    VerletParticle3D p = new VerletParticle3D(new Vec3D(random(-1, 1) * 10, -DIM, random(-1, 1) * 10));
    if (useBoundary) p.addConstraint(boundingSphere);
    physics.addParticle(p);
  }
  
  if (numP > 10 && physics.springs.size() < 1400) {
    for(int i=0; i<60; i++) {
      if (random(1) < 0.04) {
        VerletParticle3D q = physics.particles.get((int) random(numP));
        VerletParticle3D r = q;
        while(q == r) {
          r = physics.particles.get((int) random(numP));
        }
        physics.addSpring(new VerletSpring3D(q, r, REST_LENGTH, 0.0002));
      }
    }
  }
  float len = (float) numP / NUM_PARTICLES * REST_LENGTH;
  for (VerletSpring3D s : physics.springs) {
    s.setRestLength(random(0.9, 1.1) * len);
  }
  
  physics.update();
}
