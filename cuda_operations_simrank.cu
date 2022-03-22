#ifndef CUDA_OP_H
#define CUDA_OP_H

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



#endif