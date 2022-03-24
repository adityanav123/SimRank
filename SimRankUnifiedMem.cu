#include "convergeGPU.h"
#include "include_files.h"
#include "cuda_operations_simrank.cuh"
#include <__clang_cuda_runtime_wrapper.h>
#include <system_error>

void ShowMessage() {
    cout << "Default Configuration : \n\t1. [Directed-Graph]\n\t2. [Confidence Value] : " << defaultConfidenceValue 
            << "\n\t3. [No. of Iterations] : " << defaultMaxIterations << "\n";
}

__managed__ double ConfidenceValue_;
__managed__ int ThreadCount_, BlockCount_;


__global__
void computeForAPairNodes (int *graph, int verticesCount, double *currentSimRankMtx, double *futureSimRankMtx, int *in_neighbours) {
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    int sqVertices = verticesCount * verticesCount;
    int gridStride = gridDim.x * blockDim.x;
    for (int i = id; i < verticesCount * verticesCount; i += gridStride) { 
        int from, to; // store nodes;
        from = i % verticesCount;
        to = i / verticesCount;

        futureSimRankMtx[from * verticesCount + from] = 1.0;
        futureSimRankMtx[to * verticesCount + to] = 1.0;
        
        // other kernel.
    

        int count_inNeighbours_FROM = calculateCountOfInNeighbours (in_neighbours, from, verticesCount);
        int count_inNeighbours_TO =  calculateCountOfInNeighbours (in_neighbours, to, verticesCount);
        
        int totalCount = count_inNeighbours_FROM * count_inNeighbours_TO;
        int N_THREADS, N_BLOCKS;
        
        N_THREADS = 1024;
        N_BLOCKS =  ceil (totalCount / N_THREADS);

        // CPU is faster. [experimental]
        computeFromInNeighbours (futureSimRankMtx, currentSimRankMtx, graph, verticesCount, in_neighbours, from, to);
    }
}

void calculateSimRankForEachPair (double *simrank, int n_vertices, int *graph, double confidenceValue) {
    // for each pair of nodes
    double *tmpSimRank;
    cudaMallocManaged(&tmpSimRank, sizeof(double) * n_vertices * n_vertices);
    
    int total_threads = n_vertices * n_vertices;
    cudaGetDevice(&deviceId);
    cudaDeviceGetAttribute(&noOfSMs, cudaDevAttrMultiProcessorCount, deviceId);
    cudaDeviceGetAttribute(&warp_size, cudaDevAttrWarpSize, deviceId);
    int sqVertices = n_vertices * n_vertices;
    ThreadCount_ = 1024;
    BlockCount_ = ceil (sqVertices / ThreadCount_);


    int *InNeighbours = calculateAllInNeighbours(graph,n_vertices); // calculates and stores all the in-neighbours 


    computeForAPairNodes <<< BlockCount_, ThreadCount_ >>> (graph, n_vertices, simrank, tmpSimRank, InNeighbours);
    return; 
}

void compute_simrank (int *graph, int noOfVertices, int noOfIterations, double confidenceValue) {
    double *simrank;
    cudaMallocManaged(&simrank, sizeof(double) * noOfVertices * noOfVertices);
    initGraph<double> (simrank, noOfVertices, 0.0);

    double normValue=0.0; // for convergence calculation // donot change.
    int currentIteration = 1;

    ConfidenceValue_ = confidenceValue;

    while (currentIteration <= noOfIterations) {
        storeNorm(simrank, noOfVertices, "L1");
        storeNorm(simrank, noOfVertices, "L2");

        // after experimentation; min value of currerntIteration = 3 can be used.
        if (currentIteration > 3 && checkConvergence(simrank, noOfVertices, &normValue, "L1")) {
            // using L1 Norm for convergence
            break;
        }

        calculateSimRankForEachPair(simrank, noOfVertices, graph, confidenceValue); // for each (i, j) from |V x V|
        ++currentIteration;
    }
}


int *TakeGraphInput(int *vertices, int *edges, string fileName) {
    ifstream filePtr(DATASET_FOLDER + fileName);
    filePtr >> *vertices;
    filePtr >> *edges;

    int from, to, idx=0, N = *vertices;

    cout << "\nEntered Graph Configuration : \n\tnoOfVertices : " << *vertices << "\n\tnoOfEdges : " << *edges << "\n";

    // storing graph in unified memory.
    int *graph;
    cudaMallocManaged(&graph, N * N);
    initGraph<int>(graph, N, 0); // initialise graph to zero

    while (idx < *edges) {
        filePtr >> from;
        filePtr >> to;
        graph[from * N + to] = 1;
        ++idx;
    }
    return graph;
}

int main() {
    ShowMessage();
    // system("./delete_l1_l2.sh");

    int noOfVertices, noOfEdges;
    int *Graph;
    Graph = TakeGraphInput(&noOfVertices, &noOfEdges, "graph_input.txt");
    seeGraph<int>(Graph, noOfVertices);

    int MaxNoOfIterations;
    double confidenceValue;
    TakeSimRankConfigurationInput(MaxNoOfIterations, confidenceValue);

    // compute_simrank (Graph, noOfVertices, MaxNoOfIterations, confidenceValue);

    // system("python numpy_test.py"); // generates convergence graph

    return 0;
}