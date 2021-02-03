using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class School : MonoBehaviour {

    public LatkDrawing ld;

    [HideInInspector] public static string[] lexicon = "FfXxYyZz<>(.".Split();
    [HideInInspector] public static float triggerDistance = 35f;
    [HideInInspector] public static Vector3 globalScale = new Vector3(50f, -50f, 50f);
    [HideInInspector] public static Vector3 globalOffset = new Vector3(-20f, 60f, -350f);
    [HideInInspector] public static float globalSpread = 7f;
    [HideInInspector] public static float globalSpeedFactor = 4f;
    [HideInInspector] public static Vector3 axisX = new Vector3(1f, 0f, 0f);
    [HideInInspector] public static Vector3 axisY = new Vector3(0f, 1f, 0f);
    [HideInInspector] public static Vector3 axisZ = new Vector3(0f, 0f, 1f);
    [HideInInspector] public static float angleChange = 1.25f;
    [HideInInspector] public static int numCmds = 60;
    [HideInInspector] public static int maxComplexity = numCmds * 3;

    private bool armRegenerate = false;
    private bool armRedmat = false;
    private int armRegenerateIndex = 0;

    private float meshLineWidth = 0.6f;
    private float meshLineOpacity = 0.1f;
    private int meshLineResolution = 1;

    private float movingSpeedMax = 1.3f;
    private float movingDelta = 0.03f;
    private float now = 0f;

    private List<Child> pop = new List<Child>();
    private int pop_size = 35;
    private float mutability = 0.5f;
    private bool firstRun = true;

    private void Awake() {
        if (ld == null) ld = GetComponent<LatkDrawing>();
    }

    private void Start() {
        reset();
        regenerate(0);
        resetCameraPosition();
    }

    private void Update() {
        //clearScene(scene);
        for (int i = 0; i < pop.Count; i++) {
            try {
                pop[i].draw();

                /*
				if (!armRegenerate && Vector3.Distance(pop[i].points[0], Camera.main.transform.position) < triggerDistance) {
                    Debug.Log("Selected " + i);
                    armRegenerateIndex = i;
                    armRegenerate = true;
                    armRedmat = true;
                }
				*/
            } catch (UnityException e) {
                Debug.Log(e);
            }
        }

        //console.log("Total points in frame: " + bigPoints.length);
        //bigGeoBuffer.setFromPoints(bigPoints);

        if (armRegenerate) {
            //bigLine.material.color.setHex(0xff1111);
        } else {
            if (UnityEngine.Random.Range(0f,1f) < 0.2) {
                if (armRedmat) {
                    //bigLine.material.color.setHex(0xff1111);
                } else {
                    //bigLine.material.color.setHex(0xffffaa);
                }
            } else {
                //bigLine.material.color.setHex(0xaaffff);
            }
        }

        //bigLine.frustumCulled = false;

        //updatePlayer();

        if (armRegenerate) {
            StartCoroutine("resetArmRegenerate");
        }

        if (armRedmat) {
            StartCoroutine("resetArmRedmat");
        }
    }

    private IEnumerator resetArmRegenerate() {
        yield return new WaitForSeconds(0.2f);
        regenerate(armRegenerateIndex);
        armRegenerate = false;
    }

    private IEnumerator resetArmRedmat() {
		yield return new WaitForSeconds(0.6f);
		armRedmat = false;
	}

    private void regenerate(int chosen) {
        List<Child> newpop = new List<Child>();
        Child parent = pop[chosen];

        for (int i = 0; i < pop_size; i++) {
            Child child = new Child(i);

            // brain
            if (i / pop_size < parent.brain.elitism) {
                child.brain.nn = parent.brain.nn;
            } else {
                child.brain.nn = parent.brain.nn.GetRange(1, parent.brain.nn.Count-1);

                for (int j = 0; j < child.brain.nn.Count; j++) {
                    if (UnityEngine.Random.Range(0f, 1f) < child.brain.mutability / child.brain.nn.Count) {
                        child.brain.nn[j] += (UnityEngine.Random.Range(0f, 1f) * 5f) - 2f;
                    }
                }
            }

            // body
            for (int j = 0; j < parent.cmds.Count; j++) {
                if (UnityEngine.Random.Range(0f, 1f) < mutability / parent.cmds.Count) {
                    int index = (int) (UnityEngine.Random.Range(0f, 1f) * lexicon.Length);
                    child.cmds[j] = lexicon[index];
                } else {
                    child.cmds[j] = parent.cmds[j];
                }
            }

            newpop.Add(child);
        }
        pop = newpop;

        resetCameraPosition();
    }

    private void reset() {
        pop = new List<Child>();
        for (int i = 0; i < pop_size; i++) {
            pop.Add(new Child(i));
        }
    }

    private void resetCameraPosition() {
		//
	}

}

