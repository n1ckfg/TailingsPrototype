using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Drawing : MonoBehaviour
{
    public LatkDrawing ld;
	public List<Vector3> points;

	private void Awake() {
		if (ld == null) ld = GetComponent<LatkDrawing>();
	}

	private void Start() {
		ld.makeCurve(points);
	}

	private void Update() {
        //
    }

}
