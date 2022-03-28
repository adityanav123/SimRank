#ifndef CUDA_SIMRANK_OPS_H
#define CUDA_SIMRANK_OPS_H

#include <algorithm>
#include <cstdlib>
#include <stdexcept>
#include <stdio.h>


// store the array in unified memory
__global__ 
void calculateInNeighbours (int *graph, int *in_neighbours, int N, int node) {
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    for (int i = id; i < N; i += (gridDim.x * blockDim.x)) {
        in_neighbours[i] = graph[i * N + node];
    }
    // __syncthreads();
}


int* calculateAllInNeighbours (int *graph, int vertexCount, int *inNeighbours) {
    int deviceId;
    cudaGetDevice(&deviceId);
    int no_of_sms, warp_size;
    cudaDeviceGetAttribute(&no_of_sms, cudaDevAttrMultiProcessorCount, deviceId);
    cudaDeviceGetAttribute(&warp_size, cudaDevAttrWarpSize, deviceId);
    for (int i = 0; i < vertexCount; i++) {
        int n_threads = 1023, n_blocks= no_of_sms * 1024;
        // calculateInNeighbours<<<n_threads, n_blocks>>>(graph, inNeighbours, vertexCount, i);
        
        int *tmpCalculation;
        cudaMallocManaged (&tmpCalculation, sizeof(int) * vertexCount);
        
        calculateInNeighbours <<<n_blocks, n_threads>>> (graph, tmpCalculation, vertexCount, i); 
        cudaDeviceSynchronize();
        // copy the computation.
        for (int j = 0; j < vertexCount; j++) {
            inNeighbours[i * vertexCount + j] = tmpCalculation[j];
        }

        // Debug Block.
        // if (i == 12) {
        //     printf ("node : 12 [in-neighbours]\n");
        //     for (int j = 0; j < vertexCount; j++) {
        //         cout << inNeighbours[i * vertexCount + j] << " ";
        //     }cout << "\n";
        // }
        cudaDeviceSynchronize();
    }

    return inNeighbours;
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
double computeFromInNeighbours (double *futureSimRankMtx, double *currentSimRankMtx, int *graph, int vertexCount, int *inNeighbours, int from, int to, int c_from, int c_to, int normal_factor) {
    double result = 0.0;
    for (int i = 0; i < c_from; i++) {
        for (int j = 0; j < c_to; j++) {
            result += currentSimRankMtx[inNeighbours[from * vertexCount + i] * vertexCount + inNeighbours[to * vertexCount + j]];
        }
    }
    // Verbose Debug
    // printf ("for nodes : %d and %d (calculation : %lf)\n", from, to, result);
    return result;
}


#endif
