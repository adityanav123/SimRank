#include <stdio.h>
#include <vector>
#include <unordered_map>
#include "converge.h"
#include <fstream>
#include <stdio.h>
#include "array_operations.h"

#define matrix_INT vector<vector<int>>
#define matrix_DOUBLE vector<vector<double>>
#define ROW_INT vector<int>
#define ROW_DOUBLE vector<double>

/* File Output
ofstream fout;
fout.open("output_simrank.txt");
****************/

void Message() {
    printf("Default Configuration : \n\t1. [Directed-Graph]\n\t2. [Confidence Value] : 0.9\n\t3. [No. of Iterations] : 1000\n");
}
__global__ void calculateSimRankPair (int *A, int *B, double *simrank, double *summation, int* n_Vertices) {
    int from = blockIdx.x;
    int to = threadIdx.x;
    
    atomicAdd(&summation[0], simrank[A[from] * n_Vertices[0] + B[to]]);

}
void SimRankForAllNodes(int iteration, double* SimRank, int** Graph, int n_vertices, double confidence_value) {
   double* tmpSimrank = createArray_D(n_vertices); // default initialisation with 0.0 as array values. 
   
   for(int i = 0; i < n_vertices; i++) {
       for(int j = 0; j < n_vertices; j++) {
           // GPU Computation.
           /* base conditions */
           if(i == j) { 
               tmpSimrank[i * n_vertices + j] = 1.0;
               continue;
           }

           int* I_A = findInNeighbors(i, Graph, n_vertices);
           int* I_B = findInNeighbors(j, Graph, n_vertices);
           int ia_size = sizeof(I_A) / sizeof(int);
           int ib_size = sizeof(I_B) / sizeof(int);

           if(ia_size == 0 || ib_size == 0) {
               tmpSimrank[i * n_vertices + j] = 0.0;
               continue;
           }

           /* GPU PARAMETERS */
           int n_CUDA_threads = ib_size;
           int n_CUDA_blocks = ia_size;
           /******************/ 

           int nodes[2];
           nodes[0] = i;
           nodes[1] = j;

           int* device_nodes;
           cudaMalloc(&device_nodes, sizeof(int) * 2); // 2 integers are stored, the #from node and the #to node
           cudaMemcpy(device_nodes, nodes, sizeof(int) * 2, cudaMemcpyHostToDevice);
           
           int* d_I_A, *d_I_B;
           cudaMalloc(&d_I_A, sizeof(int) * ia_size);
           cudaMalloc(&d_I_B, sizeof(int) * ib_size);
           cudaMemcpy(d_I_A, I_A, sizeof(int) * ia_size, cudaMemcpyHostToDevice);
           cudaMemcpy(d_I_B, I_B, sizeof(int) * ib_size, cudaMemcpyHostToDevice);
            
           int n_simrank = n_vertices * n_vertices;
           double* d_simrank;
           cudaMalloc(&d_simrank, sizeof(double) * n_simrank);
           cudaMemcpy(d_simrank, SimRank, sizeof(double) * n_simrank, cudaMemcpyHostToDevice);

           double tmp_ans[1]; tmp_ans[0] = 0.0;
           double* d_ans;
           cudaMalloc(&d_ans, sizeof(double));        
           cudaMemcpy(d_ans, tmp_ans, sizeof(double), cudaMemcpyHostToDevice);
        
           int d_vert[1]; d_vert[0] = n_vertices;
           int *device_n_vertices;
           cudaMalloc(&device_n_vertices, sizeof(int));
           cudaMemcpy(device_n_vertices, d_vert, sizeof(int), cudaMemcpyHostToDevice); 

           calculateSimRankPair<<<n_CUDA_threads, n_CUDA_blocks>>>(d_I_A, d_I_B, d_simrank, d_ans, device_n_vertices);
           
           cudaMemcpy(tmp_ans, d_ans, sizeof(double), cudaMemcpyDeviceToHost);          
           tmpSimrank[i * n_vertices + j] = tmp_ans[0];
       }
   } 
   
    for(int i = 0; i < n_vertices; i++) {
        for(int j = 0; j < n_vertices; j++) {
            SimRank[i * n_vertices + j] = tmpSimrank[i * n_vertices + j];
        }
    }
    printf("Simrank updated!\n");
    for(int i = 0; i < n_vertices; i++) {
        for(int j = 0; j < n_vertices; j++) {
            printf("%lf ", SimRank[i * n_vertices + j]);
        }
        printf("\n");
    }
}

void ComputeSimRankMatrix (int** Graph, int noOfVertices, int noOfEdges, int max_iterations, double confidence_value) {
    double* SimRank = (double*) malloc(sizeof(double) * noOfVertices * noOfVertices);
    int V = noOfVertices;
    // 1 st iterations.
    for(int i = 0; i < V; i++) {
        for(int j = 0; j < V; j++) {
            SimRank[i*V+j] = 0.0 + 1.0 * (i==j);
        }
    } 

    // rest of the iterations/
    for(int k=1; k<max_iterations; k++) {
        // convergence will be checked here.
        /**/
        SimRankForAllNodes(k, SimRank, Graph, noOfVertices, confidence_value);
    }

 
    printf("SimRank Algorithm Converged!\nFinal SimRank Matrix : \n");
    for(int i = 0; i < noOfVertices; i++) {
        for(int j = 0; j < noOfVertices; j++) {
            printf("%.4f ", SimRank[i*noOfVertices+j]);
        }printf("\n");
    }
    printf("\n");

}

// leave this function alone.
// void ComputeSimrankMatrix(matrix_INT Graph,int noOfVertices, int noOfEdges, int max_iterations, double confidence_value) {
//     // Optimising for space.
//     //matrix_DOUBLE SimRankCurrent;

//     /* Optimising for GPU */
//     ROW_DOUBLE SimRank_(noOfVertices * noOfVertices, 0.0);

//     //matrix_DOUBLE initMatrix(noOfVertices, ROW_DOUBLE(noOfVertices, 0.0));
    
//     for(int i = 0; i < noOfVertices ; i++) {
//         SimRank_[i * noOfVertices + i] = 1.0;
//     }
   
//     /*
//     cout << "1D SimRank: \n";
//     for(int i = 0; i < noOfVertices ; i++) {
//         for(int j = 0; j < noOfVertices; j++) {
//             printf("%.4f ", SimRank_[i*noOfVertices+j]);
//         }
//         printf("\n");
//     }
//     */
    
//     int k = 1;
//     for(; k < max_iterations; k++) {
//         // Below line - debugging.
//         //cout << "iteration no. -> " << k << "\n";

//         /*
//             For each iterations, we have to see whether it converges or not.
//             See : converge.h
//             *READ MORE*
//         if(checkConvergence(SimRank, confidence_value) == true) {
//             break;
//         }*/
//         SimrankForAllNodes(k, confidence_value, noOfVertices, Graph, SimRank_);
//     }
    
//     printf("SimRank Algorithm Converged!\nFinal SimRank Matrix : \n");
//     for(int i = 0; i < noOfVertices; i++) {
//         for(int j = 0; j < noOfVertices; j++) {
//             printf("%.4f ", SimRank_[i*noOfVertices+j]);
//         }printf("\n");
//     }
//     printf("\n");
// }   
int** TakeInput(int *V, int *E) {
    ifstream file("input.txt");
    file >> *V;
    file >> *E;
    
    int n_vertices = *V, n_edges = *E;
    int from, to;
    int idx = 0;
    
    printf("\nEntered Graph Configuration : \n");
    printf("\tnoOfVertices: %d\n\tnoOfEdges: %d\n",*V,*E);  
    int** Graph = new int*[n_vertices];
    for(int i = 0; i < n_vertices; i++) {
        Graph[i] = new int[n_vertices];
    }
   // matrix_INT Graph(*V, ROW_INT(*V, 0));
    while(idx < n_edges) {
        file >> from;
        file >> to;
        Graph[from][to] = 1;
        idx++; 
    }
    return Graph;
}

void TakeSimRankConfigurationInput(int &iterations, double &confidence) {

    printf("Enter no. of iterations[for default, input -1]: ");
    scanf("%d",&iterations);
    printf("Enter Confidence-Value[0-1, for default, input -1]: ");
    scanf("%lf",&confidence);

    if(iterations == -1) iterations = 1000;
    if(confidence == -1) confidence = 0.9;

    cout << "\n*SimRank Configuration Chosen: \n\tIterations: " << iterations << "\n\tConfidence Value: " << confidence << "\n";
}

int main() {
    Message();
    
    // Graph Input.
    int noOfVertices, noOfEdges;
    //matrix_INT Graph = TakeInput(&noOfVertices,&noOfEdges);
    int** Graph = TakeInput(&noOfVertices, &noOfEdges);

    // SimRank Configuration.
    int noOfIterations;
    double confidence_value;
    TakeSimRankConfigurationInput(noOfIterations, confidence_value);
    ComputeSimRankMatrix(Graph, noOfVertices, noOfEdges, noOfIterations, confidence_value);
    return 0;
}
