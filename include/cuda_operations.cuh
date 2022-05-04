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


int *allInNeighbours (int *graph, int vertexCount, int *inNeighbours) {
	int deviceId;
	cudaGetDevice (&deviceId);
	
	int noOfSMs, warpSize;
	cudaDeviceGetAttribute (&noOfSMs, cudaDevAttrMultiProcessorCount, deviceId);
	cudaDeviceGetAttribute (&warpSize, cudaDevAttrWarpSize, deviceId);

	for (int i = 0; i < vertexCount; i++) {
		int threadCnt = 1023, blockCnt = noOfSMs * 1024;
		int *tmp, *currNeighbour;
		cudaMalloc(&tmp, sizeof(int) * vertexCount);
		
		inNeighboursParallel <<< blockCnt, threadCnt >>> (graph, tmp, vertexCount, i);
		cudaMemcpy (currNeighbour, tmp, sizeof(int) * vertexCount,cudaMemcpyDeviceToHost);
		
		for (int j = 0; j < vertexCount; j++) {
			inNeighbours[i * (vertexCount + 1) + j] = currNeighbour[j];
		}
		int one=0;
		for (int f = 0; f < vertexCount; f++) one+=(inNeighbours[i * (vertexCount+1) + f] == 1);
		inNeighbours[i * (vertexCount+1) + vertexCount] = one;
	}
	return inNeighbours;
}

#endif


