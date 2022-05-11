#include <stdio.h>
#include <iostream>
using namespace std;
__managed__ int noOfVertices;
__managed__ double cal;

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


int* GraphInput () {
	int edges;
    //int noOfVertices;
    cin >> noOfVertices >> edges;
	int from, to, id=0, N=noOfVertices;
	printf("\ngraph config : \n\tno of vertices: %d\n\tno of edges : %d\n", noOfVertices, edges);
	int* graph;
	//graph = (int*)calloc(noOfVertices * noOfVertices, sizeof(int));
	cudaMallocManaged(&graph, sizeof(int) * noOfVertices * noOfVertices);

	while (id < edges) {
        cin >> from >> to;
		graph[from * N + to] = 1;
		++id;
	}
	return graph;
}


// __global__
// void kernel (double *simrank, int from, int to, int *inNeighbours, int *graph) {
// 	int id = threadIdx.x + (blockIdx.x * blockDim.x);
// 	int stride = gridDim.x * blockDim.x;
// 	for (int i =  id; i <=
// }


int main() {
    freopen64("input.txt", "r", stdin);
    int *graph = GraphInput();

    int inNeighboursSize = sizeof(int) * (noOfVertices * (noOfVertices + 1));
	int *inNeighbours;
	cudaMallocManaged (&inNeighbours, inNeighboursSize);
    inNeighbours = allInNeighbours (graph, noOfVertices, inNeighbours);
	printf("in-neighbours : \n");
    printInNeighbours (inNeighbours, noOfVertices);

    double *simrank;
    cudaMallocManaged (&simrank, sizeof(double) * noOfVertices * noOfVertices);

    for (int i = 0; i < noOfVertices; i++) {
        for (int j = 0; j < noOfVertices; j++) {
            simrank[i * noOfVertices + j] = (1.0 * (i == j)) + 0.0;
        }
    }
    printf("before calculating simrank :\n");
	for (int i = 0; i < noOfVertices; i++) {
		for (int j = 0; j < noOfVertices; j++) {
			printf("%lf ", simrank[i * noOfVertices + j]);
		}printf("\n");
	}

    cal=0.0;
    /*kernel <<< noOfVertices * noOfVertices, 1024 >>> (simrank, 2, 3, inNeighbours, graph);
    cudaDeviceSynchronize();
	*/
    return 0;
}
