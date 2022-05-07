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
		cudaMemcpy (deviceGraph, graph, sizeof(int) * vertexCount * vertexCount, cudaMemcpyHostToDevice);

		//cout << "curr node : " << i << "\n";

		cudaMemPrefetchAsync (tmp, sizeof(int) * vertexCount, deviceId);

		inNeighboursParallel <<< blockCnt, threadCnt >>> (deviceGraph, tmp, vertexCount, i);
		cudaDeviceSynchronize();

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


#endif


