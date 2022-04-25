#ifndef CUDA_SIMRANK_OPS_H
#define CUDA_SIMRANK_OPS_H

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <stdexcept>
#include <stdio.h>


#define __printInt(a) printf ("%d\n",a)
#define __time clock()
#define __printFloat(a) printf ("%lf\n",a)
#define __nl printf ("\n")

float totalTime=0.0;

// store the array in unified memory
__global__ 
void calculateInNeighbours (int *graph, int *in_neighbours, int N, int node) {
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    for (int i = id; i < N; i += (gridDim.x * blockDim.x)) {
        in_neighbours[i] = graph[i * N + node];
    }
}


__host__ __device__
int __2dValueAt (int *arr, int x_position, int y_positon, int size) {
    return arr[x_position * size + y_positon];
}


int* calculateAllInNeighbours (int *graph, int vertexCount, int *inNeighbours) {
    // CUDA DEVICE ATTRIBUTES 
    int deviceId;
    cudaGetDevice(&deviceId);
    int no_of_sms, warp_size;
    cudaDeviceGetAttribute(&no_of_sms, cudaDevAttrMultiProcessorCount, deviceId);
    cudaDeviceGetAttribute(&warp_size, cudaDevAttrWarpSize, deviceId);
    // GPU PARAMETERS ^^

    for (int i = 0; i < vertexCount; i++) {
        int n_threads = 1023, n_blocks= no_of_sms * 1024;
        
        int *tmpCalculation;
        cudaMallocManaged (&tmpCalculation, sizeof(int) * vertexCount);
        
        calculateInNeighbours <<<n_blocks, n_threads>>> (graph, tmpCalculation, vertexCount, i); 
        cudaDeviceSynchronize();
        // copy the computation.
        for (int j = 0; j < vertexCount; j++) {
            inNeighbours[i * (vertexCount+1) + j] = tmpCalculation[j];
        }

        // store the count in the last index.
        int cntOne=0;
        for (int f = 0; f < (vertexCount); f++) cntOne += (inNeighbours[i * (vertexCount+1) + f] == 1);
        inNeighbours[i * (vertexCount+1) + vertexCount] = cntOne;        

        /********************DEBUG********************/
        // int debugNode_=12;
        // if (i == debugNode_) {
        //     printf ("node : %d [in-neighbours]\n", debugNode_);
        //     for (int j = 0; j < vertexCount; j++) {
        //         cout << inNeighbours[i * vertexCount + j] << " ";
        //     }cout << "\n";
        // }
        /********************DEBUG********************/
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


__host__ __device__
double computeFromInNeighbours (double *currentSimRankMtx,int vertexCount, int *inNeighbours, int from, int to, int c_from, int c_to) {
    double result = 0.0;
    int size_row = vertexCount + 1;
    for (int i = 0; i < vertexCount; i++) {
        if (inNeighbours[from * size_row + i] == 0) continue;      
        for (int j = 0; j < vertexCount; j++) {
            if (inNeighbours[to * size_row + j] == 1) {
                printf ("computing for : %d, %d\n", i, j);
                result += currentSimRankMtx[inNeighbours[from * size_row + i] * vertexCount + inNeighbours[to * size_row + j]];
            }
        }
    }
    return result;
}



#endif
