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

int DIMX=48;
int DIMY=48;
int DIMZ=48;

float ISO_THRESHOLD = 0.1;
float NS=0.03;
Vec3D SCALE2 = new Vec3D(1,1,1).scaleSelf(400);

boolean isWireframe = false;
float currScale = 1;

VolumetricSpaceArray volume2 = new VolumetricSpaceArray(SCALE2,DIMX,DIMY,DIMZ);
IsoSurface surface2=new ArrayIsoSurface(volume2);
TriangleMesh mesh2;

ToxiclibsSupport gfx;

void noiseSetup() {
  //size(1024,576,P3D);
  gfx = new ToxiclibsSupport(this);
}

void noiseDraw() {
  float[] volumeData=volume2.getData();
  // fill volume with noise
  /*
  for (int z=0; z<DIMZ; z++) {
    for (int y=0; y<DIMY; y++) {
      for (int x=0; x<DIMX; x++) {
        //float val = (float) SimplexNoise.noise(x * NS, y * NS, z * NS, frameCount * NS) * 0.5;
        float val = 0;
        if (x == 2) val = 1;
        volumeData[index++] = val;
      } 
    } 
  }
  */
  int loc = (int) random(volumeData.length);
  int val = 0;
  if (random(1) < 0.33) val = 1;
  volumeData[loc] = val;
  
  volume2.closeSides();
  
  // store in IsoSurface and compute surface mesh for the given threshold value
  surface2.reset();
  mesh2 = (TriangleMesh) surface2.computeSurfaceMesh(mesh2, ISO_THRESHOLD);

  translate(0,0,0);

  scale(currScale);

  
  if (isWireframe) {
    stroke(255);
    noFill();
  } else {
    noStroke();
    fill(255);
  }
  
  gfx.mesh(mesh2,true);
}
