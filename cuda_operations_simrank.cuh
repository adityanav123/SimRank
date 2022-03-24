#ifndef CUDA_OPS_H
#define CUDA_OPS_H

#include <algorithm>
#include <stdexcept>
#include <stdio.h>


// store the array in unified memory
__global__ 
void calculateInNeighbours (int *graph, int *in_neighbours, int N, int node) {
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    for (int i = id; i < N; i += (gridDim.x * blockDim.x)) {
        in_neighbours[i] = graph[i * N + node];
    }
    __syncthreads();
}


int* calculateAllInNeighbours (int *graph, int vertexCount) {
    int allInNeighbours[vertexCount * vertexCount]; // stores in-neighbours for all the nodes

    for (int i = 0; i < vertexCount; i++) {
        calculateInNeighbours(graph, allInNeighbours[i], vertexCount, i);
    }

    return allInNeighbours;
}

int sizeCalculateInNeighbour (int *in_neighbours, int node, int noOfVertices) {
    int size = 0;
    for (int i = 0; i < noOfVertices; i++) {
        size += in_neighbours[node * noOfVertices + i];
    }
    return size;
}

// can be called both from device and host.
__host__  __device__
int calculateCountOfInNeighbours(int *in_neighbours, int node, int size) {
    int count=0;
    for (int i = 0; i < size; i++) {
        count += (in_neighbours[node*size+i]);
    }
    return count;
}

__host__ __device__
void computeFromInNeighbours (double *futureSimRankMtx, double *currentSimRankMtx, int *graph, int V, int *inNeighbours, int from, int to) {
    double result = 0;
    
}


#endif
