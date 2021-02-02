using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class School : MonoBehaviour {

    bool armRegenerate = false;
    bool armRedmat = false;
    int armRegenerateIndex = 0;

    float meshLineWidth = 0.6f;
    float meshLineOpacity = 0.1f;
    int meshLineResolution = 1;

    Material mat1 = new THREE.LineBasicMaterial({ color: 0xaaffff });

    Vector3 globalScale = new Vector3(50f, -50f, 50f);
    Vector3 globalOffset = new Vector3(-20f, 60f, -350f);
    float globalSpeedFactor = 4f;
    float globalSpread = 7f;

    const axisX = new THREE.Vector3(1, 0, 0);
    const axisY = new THREE.Vector3(0, 1, 0);
    const axisZ = new THREE.Vector3(0, 0, 1);

    const triggerDistance = 35;

    movingSpeedMax = 1.3;
    movingDelta = 0.03;

    let now = 0;

    let lexicon = "FfXxYyZz<>(.".split("");
    let pop = [];
    const pop_size = 35;
    const mutability = 0.5;
    const numCmds = 60;
    const angleChange = 1.25;
    let firstRun = true;
    const maxComplexity = numCmds * 3;

    let bigGeoBuffer = new THREE.BufferGeometry();
    let bigPoints = [];
    let bigLine = new THREE.LineSegments(bigGeoBuffer, mat1);

    private void Start() {
        resetCameraPosition();
        scene.add(bigLine);
    }

    private void Update() {
        //clearScene(scene);
        bigPoints = [];

        for (let i = 0; i < pop.length; i++) {
            try {
                pop[i].draw();

                if (!armRegenerate && pop[i].points[0].distanceTo(camera.position) < triggerDistance) {
                    console.log("Selected " + i);
                    armRegenerateIndex = i;
                    armRegenerate = true;
                    armRedmat = true;
                }
            } catch (e) {
                console.log(e);
            }
        }

        //console.log("Total points in frame: " + bigPoints.length);
        bigGeoBuffer.setFromPoints(bigPoints);

        if (armRegenerate) {
            bigLine.material.color.setHex(0xff1111);
        } else {
            if (Math.random() < 0.2) {
                if (armRedmat) {
                    bigLine.material.color.setHex(0xff1111);
                } else {
                    bigLine.material.color.setHex(0xffffaa);
                }
            } else {
                bigLine.material.color.setHex(0xaaffff);
            }
        }

        //bigLine.frustumCulled = false;

        updatePlayer();

        if (armRegenerate) {
            setTimeout(function() {
                regenerate(armRegenerateIndex);
                armRegenerate = false;
            }, 200);
        }

        if (armRedmat) {
            setTimeout(function() {
                armRedmat = false;
            }, 600);
        }

        composer.render();

        requestAnimationFrame(draw);
    }

    function createMeshLineMat(_color, _opacity, _lineWidth) {
        let mat = new MeshLineMaterial({
            //useMap: 1,
            //map: texture,
            transparent: false,
            color: _color,
            sizeAttenuation: true,
            opacity: _opacity, 
            lineWidth: _lineWidth,
            depthWrite: false,
            depthTest: false,
            resolution: new THREE.Vector2(meshLineResolution, meshLineResolution),
            blending: THREE.AdditiveBlending
            /*
            blending: THREE[blending],
            blendSrc: THREE[blendSrc[4]],
            blendDst: THREE[blendDst[1]],
            blendEquation: THREE.AddEquation
            */
        });

        return mat;
    }

    void regenerate(chosen) {
        let newpop = [];
        let parent = pop[chosen];

        for (let i = 0; i < pop_size; i++) {
            let child = new Child(i);

            // brain
            if (i / pop_size < parent.brain.elitism) {
                child.brain.nn = JSON.parse(JSON.stringify(parent.brain.nn));
            } else {
                child.brain.nn = parent.brain.nn.slice(0);

                for (let j = 0; j < child.brain.nn.length; j++) {
                    if (Math.random() < child.brain.mutability / child.brain.nn.length) {
                        child.brain.nn[j] += (Math.random() * 5) - 2;
                    }
                }
            }

            // body
            for (let j = 0; j < parent.cmds.length; j++) {
                if (Math.random() < mutability / parent.cmds.length) {
                    child.cmds[j] = lexicon[parseInt(Math.random() * lexicon.length)];
                } else {
                    child.cmds[j] = parent.cmds[j];
                }
            }

            newpop.push(child);
        }
        pop = newpop;

        resetCameraPosition();
    }

    void reset() {
        pop = [];
        for (let i = 0; i < pop_size; i++) {
            pop.push(new Child(i));
        }

        if (firstRun) {
            setupPlayer();
            draw();
            firstRun = false;
        }
    }

}


public class Turtle {

    public Turtle(pos, dir, angle) {
        this.pos = pos;
        this.dir = dir;
        this.angle = angle;
    }

}


public class Child {

    public Child(idx) {
        this.index = idx;
        this.cmds = this.createCmds(numCmds);
        let x = Math.random() - 0.5;
        let y = Math.random() - 0.5;
        let z = Math.random() - 0.5;
        this.pos = new THREE.Vector3(x, y, z / 2).multiplyScalar(globalSpread).multiply(globalScale);
        this.randomDrift = 500 + (Math.random() * 500);
        this.points = [];
        //this.geo = new MeshLine();
        //this.geoBuffer = new THREE.BufferGeometry();
        //this.newLine;
        this.brain = new Brain();
        this.head;
        this.tail;
        this.velRange = 0.4;
        this.vel = new THREE.Vector3(Math.random() * this.velRange, Math.random() * this.velRange, Math.random() * this.velRange);
        this.size = triggerDistance;
        this.timeShift = Math.random() * 0.2;
    }

    void updateBrain() {
        this.head = this.points[0].clone();
        this.tail = this.points[this.points.length - 1].clone();
        let input0 = 0;
        let input1 = 0;
        let input2 = 0;

        let mindist = 20; // 2;

        // get relative vector from my head to its tail:
        let rel = this.tail.clone().sub(this.head).applyAxisAngle(axisZ, -this.vel.angleTo(this.head));
        let distance = rel.length();
        // TODO: could also limit relative angle here
        if (distance < mindist) {
            mindist = distance;

            // update sensors, which should range from 0..1

            // for distance we'd like intensity to be highest when near, lowest when far; a 1/distance-squared is good; 
            // and made relative to our size:
            input0 = this.size / (this.size + rel.dot(rel));

            // relative angle ordinarily runs -pi...pi
            // we can take the cosine of the angle to get -1..1
            // then scale this to 0..1:
            input1 = Math.cos(rel.angleTo(this.head)) * 0.5 + 0.5;

            // 3rd input tells us whether we are closer to the head or the tail:
            let distance2 = this.head.distanceTo(this.tail);
            input2 = distance2 < distance ? 0 : 1;

            // store relative vector here for sake of visualization later
            this.rel = rel;
        }

        // ~ ~ ~ ~ ~

        this.brain.update(input0, input1, input2);
        let speed = this.brain.outputs[0];
        let angle = this.brain.outputs[1] - this.brain.outputs[2];
        this.vel.applyAxisAngle(axisZ, angle);

        //this.pos.add(this.vel);
        this.pos.x += this.vel.x;
        this.pos.y += Math.sin(now * 10) / this.randomDrift;
        this.pos.z += this.vel.z;
    }

    void draw() {
        let turtle = new Turtle(new THREE.Vector3(0.5, 0.9, 0), new THREE.Vector3(0, 0.1, 0), Math.PI / 4);

        this.points = this.turtledraw(turtle, this.cmds);

        this.updateBrain();

        for (let point of this.points) {
            point.multiply(globalScale).add(this.pos).add(globalOffset);
            bigPoints.push(point);
        }
    }

    createCmds(size) {
        let geno = [];
        for (let i = 0; i < size; i++) {
            geno.push(lexicon[parseInt(Math.random() * lexicon.length)]);
        }
        return geno;
    }

    getTimeShift(val) {
        return val * (Math.sin(now) + this.timeShift);
    }

    turtledraw(t, cmds) {
        let lines = [];
        now = clock.getElapsedTime() / globalSpeedFactor;
        let turtleStep = 0.5;

        for (let i = 0; i < cmds.length; i++) {
            let cmd = cmds[i];

            if (cmd == "F") {
                // move forward, drawing a line:
                lines.push(t.pos.clone());
                t.pos.add(t.dir); // move
                lines.push(t.pos.clone());
            } else if (cmd == "f") {
                // move forward, drawing a line:
                lines.push(t.pos.clone());
                t.pos.add(t.dir.clone().multiplyScalar(turtleStep));//0.5)); // move
                lines.push(t.pos.clone());
            } else if (cmd == "X") {
                // rotate +x:
                t.dir.applyAxisAngle(axisX, this.getTimeShift(t.angle));
            } else if (cmd == "x") {
                // rotate -x:
                t.dir.applyAxisAngle(axisX, this.getTimeShift(-t.angle));
            } else if (cmd == "Y") {
                // rotate +y:
                t.dir.applyAxisAngle(axisY, this.getTimeShift(t.angle));
            } else if (cmd == "y") {
                // rotate -y:
                t.dir.applyAxisAngle(axisY, this.getTimeShift(-t.angle));
            } else if (cmd == "Z") {
                // rotate +z:
                t.dir.applyAxisAngle(axisZ, this.getTimeShift(t.angle));
            } else if (cmd == "z") {
                // rotate -z:
                t.dir.applyAxisAngle(axisZ, this.getTimeShift(-t.angle));
            } else if (cmd == "<") {
                t.angle *= angleChange;
            } else if (cmd == ">") {
                t.angle /= angleChange;
            } else if (cmd == "(") {
                // spawn a copy of the turtle:
                let t1 = new Turtle(t.pos.clone(), t.dir.clone(), -t.angle);

                let morelines = this.turtledraw(t1, cmds.slice(i + 1));
                lines = lines.concat(morelines);
            }
        }

        if (lines.length > maxComplexity) lines.length = maxComplexity;

        return lines;
    }

}