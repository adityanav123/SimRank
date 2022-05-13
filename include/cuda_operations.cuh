#ifndef CUDA_SIMRANK_CUH
#define CUDA_SIMRANK_CUH

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <stdexcept>
#include <stdio.h>

#define _timeit clock()

// calculate in-neighbours
__global__
void inNeighboursParallel (int *graph, int *in_neighbours, int N, int node) {
	int id = threadIdx.x + (blockDim.x * blockIdx.x);
	for (int i = id; i < N; i += (gridDim.x * blockDim.x)) {
		in_neighbours[i] = graph[i * N + node];
	}
}


void printInNeighbours (int *inNeighbours, int size) {
	for (int i = 0; i < size; i++) {
		for (int j = 0; j <= size; j++) {
			printf ("%d ", inNeighbours[i * (size+1) + j]);
		}printf("\n");
	}
}

int *allInNeighbours (int *graph, int vertexCount, int *inNeighbours) {
	//printf("alliNNeighbours().\n");

	int deviceId;
	cudaGetDevice (&deviceId);
	
	int noOfSMs, warpSize;
	cudaDeviceGetAttribute (&noOfSMs, cudaDevAttrMultiProcessorCount, deviceId);
	cudaDeviceGetAttribute (&warpSize, cudaDevAttrWarpSize, deviceId);

	//printf ("cuda parameters --> deviceId(%d), noOfSMs(%d).\n", deviceId, noOfSMs);

	for (int i = 0; i < vertexCount; i++) {
		int threadCnt = 1023, blockCnt = noOfSMs * 1024;
		int *tmp;
		cudaMallocManaged (&tmp, sizeof(int) * vertexCount);
		
		int *deviceGraph;
		cudaMallocManaged (&deviceGraph, sizeof(int) * vertexCount * vertexCount);

		cudaMemPrefetchAsync (tmp, sizeof(int) * vertexCount, deviceId);
		cudaMemcpy (deviceGraph, graph, sizeof(int) * vertexCount * vertexCount, cudaMemcpyHostToDevice);

		//cout << "curr node : " << i << "\n";

		inNeighboursParallel <<< blockCnt, threadCnt >>> (deviceGraph, tmp, vertexCount, i);
		cudaDeviceSynchronize();

		// CPU Miss.--> since data is in the unfied GPU. --> other process --> store explicitly in GPU memory.
		for (int j = 0; j < vertexCount; j++) {
			inNeighbours[i * (vertexCount + 1) + j] = tmp[j];
		}
		int one=0;
		for (int f = 0; f < vertexCount; f++)
			one += (inNeighbours[i * (vertexCount+1) + f] == 1);

		// store count.
		inNeighbours[i * (vertexCount+1) + vertexCount] = one;
		//printInNeighbours (inNeighbours, vertexCount);

	}
	return inNeighbours;
}


// generate pairs.
int* storePairs (int *pairs, int noOfVertices, int noOfPairs) {
	for (int i = 0; i < noOfPairs; i++) {
		int from = i / noOfVertices;
		int to = i % noOfVertices;
		pairs[i * 2 + 0] = from;
		pairs[i * 2 + 1] = to;
	}
	return pairs;
}

__managed__ double anssimrank;

__global__
void smrank_compute (int noOfVertices, int *graph, int* inNeighbours, double *simrank) {
	int id = threadIdx.x + (blockIdx.x * blockDim.x);
	int gridStride = blockDim.x * gridDim.x;
	for (int i = id; i <= noOfVertices * noOfVertices; i+=gridStride) {
		int node_1 = i / noOfVertices;
		int node_2 = i % noOfVertices;

		if (inNeighbours[node_1 * (noOfVertices + 1) + node_2] == 1) {
			anssimrank += simrank[node_1 * noOfVertices + node_2];
		}
		else break; // break the thread.
	}
}

__host__ __device__
double simrank_utility (int node_from, int node_to, int *graph, int *inNeighbours, double *prevsimrank, int noOfVertices, double ConfidenceValue) {
	if (node_from == node_to) return 1.0;
	int in_Node_from = inNeighbours[node_from * (noOfVertices + 1) + noOfVertices];
	int in_Node_to = inNeighbours[node_to * (noOfVertices + 1) + noOfVertices];
	if (in_Node_from == 0 || in_Node_to == 0) return 0.0;

	anssimrank=0.0;
	// calculate simrank for pairs.
	/*int localBlockSize = noOfVertices * noOfVertices;
	int localThreadSize = 1024;
*/
	/*smrank_compute <<< localBlockSize, localThreadSize >>> (noOfVertices, graph, inNeighbours, prevsimrank);
	cudaDeviceSynchronize ();
	*/
	
	// CPU version
	for (int i = 0; i < noOfVertices; i++) {
		for (int j = 0; j < noOfVertices; j++) {
			if (inNeighbours[node_from * (noOfVertices+1) + i] == 1 && inNeighbours[node_to * (noOfVertices + 1) + j] == 1) {
				anssimrank += prevsimrank[i * noOfVertices + j];
			}
		}		
	}

	return ((ConfidenceValue * anssimrank) / (in_Node_from * in_Node_to));

}


#endif


