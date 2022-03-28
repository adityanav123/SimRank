#include "array_operations.h"
#include "convergeGPU.h"
#include "include_files.h"
#include "cuda_operations_simrank.cuh"
// #include <__clang_cuda_runtime_wrapper.h>
#include <system_error>

void ShowMessage() {
    cout << "Default Configuration : \n\t1. [Directed-Graph]\n\t2. [Confidence Value] : " << defaultConfidenceValue 
            << "\n\t3. [No. of Iterations] : " << defaultMaxIterations << "\n";
}


__managed__ double ConfidenceValue_;
__managed__ int ThreadCount_, BlockCount_;


__global__
void computeForAPairNodes (int *graph, int verticesCount, double *currentSimRankMtx, double *futureSimRankMtx, int *in_neighbours) {
    // printf("blockIdx : %d\tThreadIdx : %d\n", threadIdx.x, blockIdx.x);
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    // int sqVertices = verticesCount * verticesCount;
    int gridStride = gridDim.x * blockDim.x;
    for (int i = id; i < verticesCount * verticesCount; i += gridStride) { 
        // cout << "i : " << i << "\n";
        // printf ("i : %d\n", i);
        int from, to; // store nodes;
        from = i % verticesCount;
        to = i / verticesCount;
        // printf ("current node pair [%d, %d]\n", from, to);

        futureSimRankMtx[from * verticesCount + from] = 1.0;
        futureSimRankMtx[to * verticesCount + to] = 1.0;
        
        int count_inNeighbours_FROM = calculateCountOfInNeighbours (in_neighbours, from, verticesCount);
        int count_inNeighbours_TO =  calculateCountOfInNeighbours (in_neighbours, to, verticesCount);
        
        // DEBUG-In_Neighbour count.
        // if (from == 10 && to == 12) {
        //     printf ("inNeighbours count; for %d : %d and %d : %d\n", from, count_inNeighbours_FROM, to, count_inNeighbours_TO);
        // }
        if (from == to) return;
        if (count_inNeighbours_FROM == 0 || count_inNeighbours_TO == 0) {
            // printf ("pair of nodes with zero In_neighbours : %d and %d\n", from, to);
            // printf ("thread blocked : %d\n", threadIdx.x);
            futureSimRankMtx[from * verticesCount + to] = 0.0;
            return;
        }

        double NORMALISATION_FACTOR = ConfidenceValue_ / (double)(count_inNeighbours_FROM * count_inNeighbours_TO);
        // if (from == 4 && to == 2)
        //     printf ("normalisation factor : %lf\n", NORMALISATION_FACTOR);

        // CPU [experimental] -> [faster than GPU]
        double simrank_computed_in_neighbour = computeFromInNeighbours (futureSimRankMtx, currentSimRankMtx, 
                                                                        graph, verticesCount, in_neighbours, 
                                                                        from, to, count_inNeighbours_FROM, count_inNeighbours_TO,
                                                                        NORMALISATION_FACTOR);
        // cudaDeviceSynchronize();
        futureSimRankMtx[from * verticesCount + to] = NORMALISATION_FACTOR * simrank_computed_in_neighbour;
    }
}

void calculateSimRankForEachPair (double *simrank, int n_vertices, int *graph, double confidenceValue, int iterationCount) {
    // for each pair of nodes
    double *tmpSimRank;
    cudaMallocManaged(&tmpSimRank, sizeof(double) * n_vertices * n_vertices);
    
    // int total_threads = n_vertices * n_vertices;
    cudaGetDevice(&deviceId);
    cudaDeviceGetAttribute(&noOfSMs, cudaDevAttrMultiProcessorCount, deviceId);
    cudaDeviceGetAttribute(&warp_size, cudaDevAttrWarpSize, deviceId);
    
    // THREAD CONFIG.
    int sqVertices = n_vertices * n_vertices;
    if (n_vertices > 1024)
        ThreadCount_ = 1024;
    else ThreadCount_ = n_vertices;
    BlockCount_ = ceil (sqVertices / ThreadCount_);
    if (BlockCount_ == 0) BlockCount_ = 1;

    int *InNeighbours;
    cudaMallocManaged (&InNeighbours, sizeof(int) * sqVertices);
    calculateAllInNeighbours(graph,n_vertices,InNeighbours); // calculates and stores all the in-neighbours 

    // DEBUG.
    // seeGraph<int>(InNeighbours,n_vertices); // wrong.
    // printf ("in-neighbours for node - 12\n");
    // for (int i = 0; i < n_vertices; i++) {
    //     printf ("%d ", InNeighbours[12 * n_vertices + i]);
    // }printf ("\n");

    // printf ("ThreadCount : %d & BlockCount : %d\n", ThreadCount_, BlockCount_);
    // printf ("computeForAPairNodes() call.\n");

    computeForAPairNodes <<< BlockCount_, ThreadCount_ >>> (graph, n_vertices, simrank, tmpSimRank, InNeighbours);
    cudaDeviceSynchronize();


    printf ("iteration : #%d \n", iterationCount);
    seeSimrank(tmpSimRank, n_vertices);
    copyArr<double>(tmpSimRank, simrank, n_vertices); // iteration complete. 

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
        // printf ("calculateSimRankForEachPair() call.\n");
        calculateSimRankForEachPair(simrank, noOfVertices, graph, confidenceValue, currentIteration); // for each (i, j) from |V x V|
        ++currentIteration;
    }


    // un-comment for verbose output.
    // seeSimrank(simrank, noOfVertices); // print ans.

    // cout << "converged!\n";
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
    // seeGraph<int>(Graph, noOfVertices);

    int MaxNoOfIterations;
    double confidenceValue;
    TakeSimRankConfigurationInput(MaxNoOfIterations, confidenceValue);
    assert (MaxNoOfIterations <= 1000 && confidenceValue <= 1.0);
    cout << "computing simrank : \n";
    compute_simrank (Graph, noOfVertices, MaxNoOfIterations, confidenceValue);

    // system("python numpy_test.py"); // generates convergence graph

    return 0;
}