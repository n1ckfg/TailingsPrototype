using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Brain {

	[HideInInspector] public List<float[]> activations;
	[HideInInspector] public float[] outputs = { 0f, 0f, 0f };
	[HideInInspector] public float mutability = 5f;
	[HideInInspector] public float elitism = 1f / 10f;
	[HideInInspector] public List<float> nn;

	private float[] pop;
    private float pop_size = 200f;
    private float creature_size = 1f / 100f;

    private float N = 3f;
    private float L = 3f;

    // N+1 (to include bias) weights per neuron per layer:
    private float MAXW = 10f;

    private float gamesteps = 0f;
    private float MAX_STEPS = 500f;

    private float randomized = 1f / 20f;

    private float[] inputs = { 0f, 0f, 0f };

    private float SPEED_MAX;
    private float NUMWEIGHTS;

	public Brain() {
		SPEED_MAX = creature_size * 10f;
		NUMWEIGHTS = (N + 1) * N * L;
		nn = createNN();
		activations = createActivations();
	}

    public void update(float input0, float input1, float input2) {
        setInputs(input0, input1, input2);
        getOutputs();
    }

    private float sigmoid(float x) {
		return 1f / (1f + Mathf.Exp(-x));
	}

	private float srandom() {
		return (Random.Range(0f, 1f) - 0.5f) * 2f;
	}

	private float randomGene() {
		return (Random.Range(0f, 1f) * (MAXW * 2f)) - MAXW;
	}

	private List<float> createNN() {
		NUMWEIGHTS = (N + 1f) * N * L;
		List<float> w = new List<float>();
		for (int i = 0; i < NUMWEIGHTS; i++) {
			w.Add(randomGene());
		}
		return w;
	}

	private List<float[]> createActivations() {
		List<float[]> activations = new List<float[]>();
		for (int l = 0; l < this.L + 1; l++) {
			float[] layer = new float[(int) N];
			// iterate over neurons in the layer:
			for (int n = 0; n < N; n++) {
				layer[n] = 0;
			}
			activations.Add(layer);
		}
		return activations;
	}

	private float[] activate(float[] inputVector) {
		activations[0] = inputVector;
		int w = 0; // index into the weights list
		float[] inputs = activations[0];
		float[] outputs = new float[activations[0].Length];

        for (int l = 0; l < L; l++) {
			// we will activate layer l+1 by the values in layer l:
			outputs = activations[l + 1];
			// iterate over neurons in the layer:
			for (int n = 0; n < N; n++) {
				// start with bias term:
				float sum = nn[w++];
				// add the weighted inputs:
				for (int i = 0; i < N; i++) {
					// use the next weight from the NN:
					sum += inputs[i] * nn[w++];
				}
				// apply activation function:
				outputs[n] = this.sigmoid(sum);
			}
			// outputs becomes inputs of next round:
			inputs = outputs;
		}

        return outputs;
	}

	private float[] setInputs(float input0, float input1, float input2) {
		inputs[0] = input0;
		inputs[1] = input1;
		inputs[2] = input2;
		return inputs;
	}

	private float[] getOutputs() {
		outputs = activate(inputs);
		return outputs;
	}

}
