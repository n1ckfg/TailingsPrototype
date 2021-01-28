/* 
 * Copyright (c) 2010 Karsten Schmidt
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
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.volume.*;
import toxi.math.noise.*;
import toxi.processing.*;

int dim2 = 48;
int DIMX = dim2;
int DIMY = dim2;
int DIMZ = dim2;

float ISO_THRESHOLD = 0.1;
float NS=0.03;
Vec3D SCALE2 = new Vec3D(1,1,1).scaleSelf(400);

boolean isWireframe = false;
float currScale = 1;

// http://toxiclibs.org/docs/volumeutils/
VolumetricSpaceArray volume2 = new VolumetricSpaceArray(SCALE2,DIMX,DIMY,DIMZ);
IsoSurface surface2=new ArrayIsoSurface(volume2);
TriangleMesh mesh2;

ToxiclibsSupport gfx;
PGraphics3D layer2;

void noiseSetup() {
  layer2 = (PGraphics3D) createGraphics(width, height, P3D);
  gfx = new ToxiclibsSupport(this, layer2);
}

void noiseDraw() {
  //float[] volumeData=volume2.getData();
  
  for (int z=0; z<DIMZ; z++) {
    for (int y=0; y<DIMY; y++) {
      for (int x=0; x<DIMX; x++) {
        float vox = volume2.getVoxelAt(x, y, z);
        if (vox > random(0.4, 0.8)) {
          float val = (float) SimplexNoise.noise(x * NS, y * NS, z * NS, frameCount * NS) * 0.5;
          int rnd_x = int(random(3)) - 1;
          int rnd_y = int(random(3)) - 1;
          int rnd_z = int(random(3)) - 1;

          volume2.setVoxelAt(x + rnd_x, y + rnd_y, z + rnd_z, val);
        }
      } 
    } 
  }
  
  /*
  if (wp.sp.changed) {
    wp.sp.changed = false;
    int loc = (int) random(volumeData.length);
    volumeData[loc] = 1;
  }
  */
  
  if (wp.sp.changed) {
    wp.sp.changed = false;
    volume2.setVoxelAt(int(random(DIMX)), int(random(DIMY)), int(random(DIMZ)), 1);
  }
  
  volume2.closeSides();
  
  // store in IsoSurface and compute surface mesh for the given threshold value
  surface2.reset();
  mesh2 = (TriangleMesh) surface2.computeSurfaceMesh(mesh2, ISO_THRESHOLD);
  
  layer2.beginDraw();
  layer2.clear();
  layer2.pushMatrix();
  layer2.translate(width/2, height/2, 0);
  layer2.rotateY(globalRot);
  layer2.scale(currScale);

  
  if (isWireframe) {
    layer2.stroke(255);
    layer2.noFill();
  } else {
    layer2.noStroke();
    layer2.fill(200 + random(55), 100, random(10));
  }
  
  gfx.mesh(mesh2,true);
  layer2.popMatrix();
  layer2.endDraw();
}
