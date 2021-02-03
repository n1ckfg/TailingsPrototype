using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Turtle {

    public Vector3 pos, dir;
    public float angle;

    public Turtle(Vector3 _pos, Vector3 _dir, float _angle) {
        pos = _pos;
        dir = _dir;
        angle = _angle;
    }

}