using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Child {

    [HideInInspector] public List<Vector3> points;
    [HideInInspector] public Brain brain;
    [HideInInspector] public List<string> cmds;

    private int index;
    private float x, y, z;
    private float randomDrift, velRange, size, timeShift, now;
    private Vector3 pos, vel, head, tail, rel;

    public Child(int idx) {
        index = idx;
        cmds = createCmds(School.numCmds);
        x = UnityEngine.Random.Range(0f, 1f) - 0.5f;
        y = UnityEngine.Random.Range(0f, 1f) - 0.5f;
        z = UnityEngine.Random.Range(0f, 1f) - 0.5f;
        pos = new Vector3(x, y, z / 2f) * School.globalSpread;
		pos.Scale(School.globalScale);
        float randomDrift = 500f + (UnityEngine.Random.Range(0f, 500f));
        points = new List<Vector3>();
        //this.geo = new MeshLine();
        //this.geoBuffer = new THREE.BufferGeometry();
        //this.newLine;
        brain = new Brain();
        velRange = 0.4f;
        vel = new Vector3(UnityEngine.Random.Range(0f, 1f) * velRange, UnityEngine.Random.Range(0f, 1f) * velRange, UnityEngine.Random.Range(0f, 1f) * velRange);
        size = School.triggerDistance;
        timeShift = UnityEngine.Random.Range(0f, 0.2f);
    }

    private void updateBrain() {
        head = points[0];
        tail = points[points.Count - 1];
        float input0 = 0f;
        float input1 = 0f;
        float input2 = 0f;

        float mindist = 20f; // 2;

		// get relative vector from my head to its tail:
		Vector3 newRel = tail - head;
		newRel = Quaternion.AngleAxis(-Vector3.Angle(vel, head), School.axisZ) * newRel;
        float distance = newRel.magnitude;

		// TODO: could also limit relative angle here
        if (distance < mindist) {
            mindist = distance;

            // update sensors, which should range from 0..1

            // for distance we'd like intensity to be highest when near, lowest when far; a 1/distance-squared is good; 
            // and made relative to our size:
            input0 = size / (size + Vector3.Dot(newRel, newRel));

            // relative angle ordinarily runs -pi...pi
            // we can take the cosine of the angle to get -1..1
            // then scale this to 0..1:
            input1 = Mathf.Cos(Vector3.Angle(newRel, head)) * 0.5f + 0.5f;

            // 3rd input tells us whether we are closer to the head or the tail:
            float distance2 = Vector3.Distance(head, tail);
            input2 = distance2 < distance ? 0 : 1;

            // store relative vector here for sake of visualization later
            rel = newRel;
        }

        // ~ ~ ~ ~ ~

        brain.update(input0, input1, input2);
        float speed = brain.outputs[0];
        float angle = brain.outputs[1] - brain.outputs[2];
        vel = Quaternion.AngleAxis(angle, School.axisZ) * vel;

        //this.pofs.add(this.vel);
        pos.x += this.vel.x;
        pos.y += Mathf.Sin(now * 10) / this.randomDrift;
        pos.z += this.vel.z;
    }

    public void draw() {
        Turtle turtle = new Turtle(new Vector3(0.5f, 0.9f, 0f), new Vector3(0f, 0.1f, 0f), Mathf.PI / 4f);

        points = turtledraw(turtle, cmds);
        Debug.Log(points.Count);
        //updateBrain();

        for (int i=0; i<points.Count; i++) {
            points[i].Scale(School.globalScale);
			points[i] += pos + School.globalOffset;
            Debug.Log("!!!!" + points[i]);
            //bigPoints.push(point);
			// TODO draw
        }
    }

    private List<string> createCmds(int size) {
        List<string> geno = new List<string>();
        for (int i = 0; i < size; i++) {
            int index = (int) (UnityEngine.Random.Range(0f, 1f) * School.lexicon.Length);
            geno.Add(School.lexicon[index]);
        }
        return geno;
    }

    private float getTimeShift(float val) {
        return val * (Mathf.Sin(now) + timeShift);
    }

    private List<Vector3> turtledraw(Turtle t, List<string> _cmds) {
        List<Vector3> lines = new List<Vector3>();
        now = Time.timeSinceLevelLoad / School.globalSpeedFactor;
        float turtleStep = 0.5f;

        for (int i=0; i<_cmds.Count; i++) {
            string cmd = _cmds[i];
            Debug.Log(cmd);

            if (cmd == "F") {
                // move forward, drawing a line:
                lines.Add(t.pos);
                t.pos += t.dir; // move
                lines.Add(t.pos);
            } else if (cmd == "f") {
                // move forward, drawing a line:
                lines.Add(t.pos);
                t.pos += t.dir * turtleStep; //0.5)); // move
                lines.Add(t.pos);
            } else if (cmd == "X") {
                // rotate +x:
				t.dir = Quaternion.AngleAxis(getTimeShift(t.angle), School.axisX) * t.dir;
            } else if (cmd == "x") {
                // rotate -x:
                t.dir = Quaternion.AngleAxis(getTimeShift(-t.angle), School.axisX) * t.dir;
            } else if (cmd == "Y") {
                // rotate +y:
                t.dir = Quaternion.AngleAxis(getTimeShift(t.angle), School.axisY) * t.dir;
            } else if (cmd == "y") {
                // rotate -y:
                t.dir = Quaternion.AngleAxis(getTimeShift(-t.angle), School.axisY) * t.dir;
            } else if (cmd == "Z") {
                // rotate +z:
                t.dir = Quaternion.AngleAxis(getTimeShift(t.angle), School.axisZ) * t.dir;
            } else if (cmd == "z") {
                // rotate -z:
                t.dir = Quaternion.AngleAxis(getTimeShift(-t.angle), School.axisZ) * t.dir;
            } else if (cmd == "<") {
                t.angle *= School.angleChange;
            } else if (cmd == ">") {
                t.angle /= School.angleChange;
            } else if (cmd == "(") {
                // spawn a copy of the turtle:
                Turtle t1 = new Turtle(t.pos, t.dir, -t.angle);

                List<Vector3> morelines = turtledraw(t1, _cmds.GetRange(i + 1, _cmds.Count-1));
                lines.AddRange(morelines);
            }
        }

        if (lines.Count > School.maxComplexity) lines.RemoveRange(School.maxComplexity, lines.Count-1);

        return lines;
    }

}