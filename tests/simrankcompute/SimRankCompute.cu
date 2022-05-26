#include <cuda_runtime.h>
#include <device_atomic_functions.h>
#include <stdio.h>
#include <fstream>
using namespace std;
__managed__ int edgecnt, vertexcnt;
int* inputmatrix () {
	ifstream file("./graph.txt");
	file>>vertexcnt>>edgecnt;

	int from,to,i=0;
	int *graph;
	cudaMallocManaged(&graph, sizeof(int) * vertexcnt * vertexcnt);
	
	while (i < vertexcnt) {
		file>>from;
		file>>to;

		graph[from*vertexcnt+to]=1;
		++i;
	}
	return graph;
}

__managed__ double ans;
__global__
void compute (int from, int to, double *simrank, int *graph) {
	int id = threadIdx.x + (blockIdx.x * blockDim.x);
	for (int i = id; i < vertexcnt; i++) {
		int f = i / vertexcnt;
		int t = i % vertexcnt;
		if (graph[from * vertexcnt + f] != 1 && graph[to * vertexcnt + t] != 1) return;
		printf("node : %d, %d\n", f, t);
		atomicAdd(&ans, simrank[f * vertexcnt + t]);
	}
}

int main() {
	int *graph;
	graph = inputmatrix();

	printf("graph : \n");
	for (int i = 0; i < vertexcnt; i++) {
		for (int j = 0; j < vertexcnt; j++) {
			printf("%d ", graph[i * vertexcnt + j]);
		}printf("\n");
	}
	
	double *simrank;
	cudaMallocManaged(&simrank, sizeof(double) * vertexcnt * vertexcnt);

	for (int i = 0; i < vertexcnt; i++) {
		for (int j = 0; j < vertexcnt; j++) {
			simrank[i*vertexcnt+j] = (i == j) ? 1 : 0;	
		}
	}

	printf ("simrank matrix : \n");
	for (int i = 0; i < vertexcnt; i++) {
		for (int j = 0; j < vertexcnt; j++) {
			printf ("%lf ", simrank[i*vertexcnt+j]);
		}printf("\n");
	}
	
	int threads = 256;
	int blocks = vertexcnt * vertexcnt;

	ans=0;
	compute <<< blocks, threads >>> (2, 3, simrank, graph);
	cudaDeviceSynchronize();
	
	printf ("ans : %lf\n", ans);

	return 0;
}
