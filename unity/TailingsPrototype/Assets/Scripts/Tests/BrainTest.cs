using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrainTest : MonoBehaviour {

    private Brain brain;

    private void Start() {
        brain = new Brain();
        Debug.Log(brain.activations);
    }

}
