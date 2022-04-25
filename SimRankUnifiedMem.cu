#include "array_operations.h"
#include "convergeGPU.h"
#include "include_files.h"
#include "cuda_operations_simrank.cuh"
// #include <__clang_cuda_runtime_wrapper.h>
#include <ctime>
#include <system_error>

void ShowMessage() {
    cout << "Default Configuration : \n\t1. [Directed-Graph]\n\t2. [Confidence Value] : " << defaultConfidenceValue 
            << "\n\t3. [No. of Iterations] : " << defaultMaxIterations << "\n";
}


// Variables in Unified Memory
__managed__ double ConfidenceValue_;
__managed__ int ThreadCount_, BlockCount_;


__global__
void computeForAPairNodes (int *graph, int verticesCount, double *currentSimRankMtx, double *futureSimRankMtx, int *in_neighbours) {
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    // __printInt(id); // checking current thread.
    if (id > verticesCount * verticesCount) return;
    // int gridStride = gridDim.x * blockDim.x;
    // for (int i = id; i < verticesCount * verticesCount; i += gridStride) { 
    
        int from, to; // store nodes;
        from = id % verticesCount;
        to = id / verticesCount;
        
        // BASE CONDITIONS --> thread break//
        if (from == to) {
            futureSimRankMtx[from * verticesCount + to] = 1.0;
            return;
        }
        
        // printf ("pair formed : (%d , %d)\n",from, to);
        
        int count_inNeighbours_FROM;
        count_inNeighbours_FROM = in_neighbours[from * (verticesCount+1) + verticesCount];
        int count_inNeighbours_TO;
        count_inNeighbours_TO = in_neighbours[to * (verticesCount+1) + verticesCount];
        
        if (count_inNeighbours_FROM == 0 || count_inNeighbours_TO == 0) {
            futureSimRankMtx[from * verticesCount + to] = 0.0;
            return;
        }

        long mul_Cnt = (count_inNeighbours_TO * count_inNeighbours_FROM);
        double NORMALISATION_FACTOR = ConfidenceValue_ / (double)(mul_Cnt);

        /********************DEBUG********************/
        // if (from == 2 && to == 4) {
        //     printf ("inNeighbours count; \n %d : %d \n %d : %d\n", from, count_inNeighbours_FROM, to, count_inNeighbours_TO);
        // }
        /********************DEBUG********************/

        // CPU [experimental] -> [faster than GPU] [result.]
        double simrank_computed_in_neighbour = NORMALISATION_FACTOR * computeFromInNeighbours (currentSimRankMtx, 
                                                                        verticesCount, in_neighbours, 
                                                                        from, to, count_inNeighbours_FROM, count_inNeighbours_TO);
        
        // uncomment for verbose output.
        // printf ("future simrank for pair (%d, %d) : %lf\n", from, to, simrank_computed_in_neighbour * NORMALISATION_FACTOR);

        futureSimRankMtx[from * verticesCount + to] = simrank_computed_in_neighbour;

    // }
}

void calculateSimRankForEachPair (double *simrank, int n_vertices, int *graph, double confidenceValue, int iterationCount) {
    // for each pair of nodes
    double *tmpSimRank;
    cudaMallocManaged(&tmpSimRank, sizeof(double) * n_vertices * n_vertices);
    
    cudaGetDevice(&deviceId);
    cudaDeviceGetAttribute(&noOfSMs, cudaDevAttrMultiProcessorCount, deviceId);
    cudaDeviceGetAttribute(&warp_size, cudaDevAttrWarpSize, deviceId);
    
    // THREAD CONFIG. GENERATION. --> bad.
    // int sqVertices = n_vertices * n_vertices;
    // if (n_vertices > 1024)
    //     ThreadCount_ = 1024;
    // else ThreadCount_ = n_vertices;
    // BlockCount_ = ceil (sqVertices / ThreadCount_);
    // if (BlockCount_ == 0) BlockCount_ = 1;
    BlockCount_ = n_vertices * n_vertices;
    ThreadCount_ = 1;


    // Pre-compute the in-neighbour matrix
    int *InNeighbours;
    int InNeighboursSize= sizeof(int) * (n_vertices) * (n_vertices + 1);
    cudaMallocManaged (&InNeighbours, InNeighboursSize);
    calculateAllInNeighbours(graph,n_vertices,InNeighbours); // calculates and stores all the in-neighbours 

    
    // if (iterationCount == 1){
    //     printf ("in-neighbours calculation : \n");
    //     for (int i = 0; i < n_vertices; i++) {
    //         printf ("%d : ", i);
    //         for (int j = 0; j < n_vertices + 1; j++) {
    //             printf ("%d ", InNeighbours[i * (n_vertices + 1) + j]);
    //             // __printInt(InNeighbours[i * (n_vertices + 1) + j]);
    //         }
    //         __nl;
    //     }
    // }
    /********************DEBUG********************/
    // seeGraph<int>(InNeighbours,n_vertices); // wrong.
    // int debugNode = 4;
    // printf ("in-neighbours for node - %d\n", debugNode);
    // for (int i = 0; i < (n_vertices+1); i++) {
    //     printf ("%d ", InNeighbours[debugNode * (n_vertices+1) + i]);
    // }printf ("\n");

    // printf ("ThreadCount : %d & BlockCount : %d\n", ThreadCount_, BlockCount_);
    // printf ("computeForAPairNodes() call.\n");
    /********************DEBUG********************/

    float start,end;
    // printf ("current iteration : %d\n", iterationCount);
    start = __time;
    computeForAPairNodes <<< BlockCount_, ThreadCount_ >>> (graph, n_vertices, simrank, tmpSimRank, InNeighbours);
    end = __time;
    totalTime += (float)(end - start) / CLOCKS_PER_SEC;
    cudaDeviceSynchronize();

    /********************DEBUG********************/
    // printf ("iteration : #%d \n", iterationCount);
    // seeSimrank(tmpSimRank, n_vertices);
    // printf ("\n\n");
    /********************DEBUG********************/
    
    // copyArr<double>(tmpSimRank, simrank, n_vertices); // iteration complete. 

    // COPY ARRAY TO ORIGINAL.
    for (int i = 0; i < n_vertices; i++) {
        for (int j = 0; j < n_vertices; j++) {
            simrank[i * n_vertices + j] = tmpSimRank[i * n_vertices + j];
        }
    }


    return; 
}

void compute_simrank (int *graph, int noOfVertices, int noOfIterations, double confidenceValue) {
    double *simrank;
    cudaMallocManaged(&simrank, sizeof(double) * noOfVertices * noOfVertices);
    initGraph<double> (simrank, noOfVertices, 0.0);

    for(int i = 0; i < noOfVertices; i++) {
        for(int j = 0; j < noOfVertices; j++) {
            simrank[i*noOfVertices+j] = 0.0 + 1.0 * (i==j);
        }
    }

    double normValue=0.0; // for convergence calculation // donot change.
    int currentIteration = 1;

    ConfidenceValue_ = confidenceValue;
    checkConvergence(simrank, noOfVertices, &normValue, "L1");
    printf("starting norm value: %lf\n", normValue);
    while (currentIteration <= noOfIterations) {
        storeNorm(simrank, noOfVertices, "L1");
        storeNorm(simrank, noOfVertices, "L2");

        calculateSimRankForEachPair(simrank, noOfVertices, graph, confidenceValue, currentIteration); // for each (i, j) from |V x V|


        // after experimentation; min value of currerntIteration = 3 can be used.
        if (currentIteration > 3 && checkConvergence(simrank, noOfVertices, &normValue, "L1")) {
            // using L1 Norm for convergence
            break;
        }
        // printf ("calculateSimRankForEachPair() call.\n");
        // printf ("iteration %d\n", currentIteration);
        // seeSimrank(simrank, noOfVertices);
        // printf ("\n\n");
        ++currentIteration;
    }


    /************VERBOSE OUTPUT************/
    seeSimrank(simrank, noOfVertices); // print ans.
    // cout << "converged!\n";
    printf ("converged! @%d\n", currentIteration);
    /************VERBOSE OUTPUT************/
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

    // Graph Generation.
    // system ("bash start_simrank.sh gnm_random_graph.py");

    __fileIO(); // file input output.

    ShowMessage();
    // system("./delete_l1_l2.sh");

    int noOfVertices, noOfEdges;
    int *Graph;
    Graph = TakeGraphInput(&noOfVertices, &noOfEdges, "graph_input.txt");
    // seeGraph<int>(Graph, noOfVertices);

    int MaxNoOfIterations;
    double confidenceValue;
    TakeSimRankConfigurationInput(MaxNoOfIterations, confidenceValue);
    assert (MaxNoOfIterations <= 1000 && confidenceValue <= 1.0 && (confidenceValue < 0 && confidenceValue != -1));
    cout << "computing simrank : \n";
    compute_simrank (Graph, noOfVertices, MaxNoOfIterations, confidenceValue);

    // system("python numpy_test.py"); // generates convergence graph

    cout << "time taken : ";
    __printFloat(totalTime);

    return 0;
}