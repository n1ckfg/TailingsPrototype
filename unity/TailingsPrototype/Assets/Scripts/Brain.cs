using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Brain : MonoBehaviour {

	float[] pop;
	float pop_size = 200f;
	float creature_size = 1f / 100f;

	float N = 3f;
	float L = 3f;

	// N+1 (to include bias) weights per neuron per layer:
	float MAXW = 10f;

	float gamesteps = 0f;
	float MAX_STEPS = 500f;

	float mutability = 5f;
	float elitism = 1f / 10f;
	float randomized = 1f / 20f;

	float[] inputs = { 0f, 0f, 0f };
	float[] outputs = { 0f, 0f, 0f };

	float SPEED_MAX;
	float NUMWEIGHTS;
	float[] nn;
	List<float[]> activations;

	private void Awake() {
		SPEED_MAX = creature_size * 10f;
		NUMWEIGHTS = (N + 1) * N * L;
		nn = createNN();
		activations = createActivations();
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

	private float[] createNN() {
		NUMWEIGHTS = (N + 1f) * N * L;
		float[] w = new float[(int) NUMWEIGHTS];
		for (int i = 0; i < NUMWEIGHTS; i++) {
			w[i] = randomGene();
		}
		return w;
	}

	private List<float[]> createActivations() {
		List<float[]> activations = new List<float[]>();
		for (int l = 0; l < this.L + 1; l++) {
			float[] layer = new float[N];
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
		float[] outputs;
		for (int l = 0; l < L; l++) {
			// we will activate layer l+1 by the values in layer l:
			outputs = activations[l + 1];
			// iterate over neurons in the layer:
			for (int n = 0; n < N; n++) {
				// start with bias term:
				let sum = this.nn[w++];
				// add the weighted inputs:
				for (let i = 0; i < this.N; i++) {
					// use the next weight from the NN:
					sum += inputs[i] * this.nn[w++];
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

	private void run(float input0, float input1, float input2) {
		setInputs(input0, input1, input2);
		getOutputs();
	}

}
