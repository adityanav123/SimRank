#include "convergeGPU.h"
#include "include_files.h"

extern void in_neighbour_calculation_cuda(int *graph, int *in_neighbour, int node, int n_vertices);

void ShowMessage() {
    cout << "Default Configuration : \n\t1. [Directed-Graph]\n\t2. [Confidence Value] : " << defaultConfidenceValue 
            << "\n\t3. [No. of Iterations] : " << defaultMaxIterations << "\n";
}

void calculateSimRankForEachPair () {
    return; 
}

void compute_simrank (int *graph, int noOfVertices, int noOfIterations, double confidenceValue) {
    double *simrank;
    initGraph<double> (simrank, noOfVertices, 0.0);

    double normValue=0.0; // for convergence calculation // donot change.
    int currentIteration = 1;


    while (currentIteration <= noOfIterations) {
        storeNorm(simrank, noOfVertices, "L1");
        storeNorm(simrank, noOfVertices, "L2");

        // after experimentation; min value of currerntIteration = 3 can be used.
        if (currentIteration > 3 && checkConvergence(simrank, noOfVertices, &normValue, "L1")) {
            // using L1 Norm for convergence
            break;
        }

        calculateSimRankForEachPair(); // for each (i, j) from |V x V|
        


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