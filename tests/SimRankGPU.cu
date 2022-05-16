#include <stdio.h>
#include <vector>
#include <unordered_map>
#include "convergeGPU.h"
#include <fstream>
#include <stdio.h>
#include "array_operations.h"
#include <cuda_profiler_api.h>
#define d_ for(int i = 0; i < 100000; i++)
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

/* GPU Kernel */
__global__ void calculateSimRankPair (int *A, int *B, double *simrank, double *summation, int* n_Vertices) {
    atomicAdd(&summation[0], simrank[A[blockIdx.x] * n_Vertices[0] + B[threadIdx.x]]);
}
/*************/


double totalKernelTime = 0.0;
void SimRankForAllNodes(int iteration, double* SimRank, int** Graph, int n_vertices, double confidence_value) {
   double* tmpSimrank = createArray_D(n_vertices); // default initialisation with 0.0 as array values. 
   
   /* Kernel Timing */
   clock_t startKernel, endKernel;
   //double totalKernelTime = 0.0;

   for(int i = 0; i < n_vertices; i++) {
       //cudaStream_t streams[n_vertices];
       for(int j = 0; j < n_vertices; j++) {
           // GPU Computation.
           /* base condition: [1] Same Node */
           if(i == j) { 
               tmpSimrank[i * n_vertices + j] = 1.0;
               //printf("base case - 1[same node]\n");
               continue;
           }
           /* this code has some problem */
           int ia_size, ib_size;
           int* I_A = findInNeighbors(i, Graph, n_vertices, &ia_size);
           int* I_B = findInNeighbors(j, Graph, n_vertices, &ib_size);
           /******************************/
           /* Normalisation Factor */ 
           double normalisation_factor = confidence_value / (ia_size * ib_size);
            
           /* Base Condition : [2] No In_Neighbours of one of the edges */
           if(ia_size == 0 || ib_size == 0) {
               tmpSimrank[i * n_vertices + j] = 0.0;
               //printf("base case - 2[no in-neighbors]\n");
               continue;
           }

           /* GPU PARAMETERS */
           int n_CUDA_threads = ib_size;
           int n_CUDA_blocks = ia_size;

           //printf("GPU PARAMETERS :\t # of blocks : %d\t # of threads : %d\n", n_CUDA_blocks, n_CUDA_threads);
           /******************/ 

           /* not used.
              int nodes[2];
           nodes[0] = i;
           nodes[1] = j;

           int* device_nodes;
           cudaMalloc(&device_nodes, sizeof(int) * 2); // 2 integers are stored, the #from node and the #to node
           cudaMemcpy(device_nodes, nodes, sizeof(int) * 2, cudaMemcpyHostToDevice);
           */
           int* d_I_A, *d_I_B;
           
           /* nv profiling */
           //cudaProfilerStart();
           
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
 
           /* kernel call */
           startKernel = clock();
           calculateSimRankPair<<<n_CUDA_blocks, n_CUDA_threads>>>(d_I_A, d_I_B, d_simrank, d_ans, device_n_vertices);
           endKernel = clock();
           /***************/

           totalKernelTime += (double)(endKernel - startKernel) / CLOCKS_PER_SEC;
           //cudaDeviceSynchronize(); 
           cudaMemcpy(tmp_ans, d_ans, sizeof(double), cudaMemcpyDeviceToHost);  

           // nv profiler end
           //cudaProfilerStop();
           
           tmpSimrank[i * n_vertices + j] = tmp_ans[0] * normalisation_factor;
       }
   } 
   
    for(int i = 0; i < n_vertices; i++) {
        for(int j = 0; j < n_vertices; j++) {
            SimRank[i * n_vertices + j] = tmpSimrank[i * n_vertices + j];
        }
    }

    // debug each iteration.
    //printf("Simrank updated!\n");
    /*for(int i = 0; i < n_vertices; i++) {
        for(int j = 0; j < n_vertices; j++) {
            printf("%lf ", SimRank[i * n_vertices + j]);
        }
        printf("\n");
    }*/
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
    double normValue = 0.00;
    checkConvergence(SimRank, V, &normValue);
    // rest of the iterations/
    int k = 1;
    for(; k<max_iterations; k++) {
    //printf("iteration : #%d\n", k);
        /* below two functions are for plotting convergence graph */
        storeL2Norm(SimRank, noOfVertices);
        storel1Norm(SimRank, noOfVertices);

        SimRankForAllNodes(k, SimRank, Graph, noOfVertices, confidence_value);
        /* Checking Convergence of SimRank Matrix */ 
        if (k > 2 && checkConvergence(SimRank, noOfVertices, &normValue) == true) {
            break;
        }
    }
    //printf("Total Kernel Time : %.5f\n",totalKernelTime); 
    //printf("Converged on : %d\n",k);
    
    //printf("SimRank Algorithm Converged!\nFinal SimRank Matrix : \n");
    /*for(int i = 0; i < noOfVertices; i++) {
        for(int j = 0; j < noOfVertices; j++) {
            printf("%.4f ", SimRank[i*noOfVertices+j]);
        }printf("\n");
    }*/
    printf("\n");

}

int** TakeInput(int *V, int *E) {
    string filePath = "./tests/datasets/";
    string fileName = "watts_strogatz.txt";
    ifstream file(filePath + fileName);
    
    //ifstream file("input.txt");
    file >> *V;
    file >> *E;
    
    int n_vertices = *V, n_edges = *E;
    int from, to;
    int idx = 0;
    
    printf("\nEntered Graph Configuration : \n");
    printf("\tnoOfVertices: %d\n\tnoOfEdges: %d\n",*V,*E);  
    int** Graph = new int*[n_vertices+1];
    for(int i = 0; i < n_vertices; i++) {
        Graph[i] = new int[n_vertices+1];
    }
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
    
    //Deleting the l1 norm parameters, for future creation.unavoidable 
    system("./delete_l1_l2.sh"); 
    
    // Graph Input.
    int noOfVertices, noOfEdges;
    
    int** Graph = TakeInput(&noOfVertices, &noOfEdges);

    // Input of SimRank Configuration parameters
    int noOfIterations;
    double confidence_value;
    TakeSimRankConfigurationInput(noOfIterations, confidence_value);
    
    // Time Calculation for Whole Computation.
    //clock_t startTime,endTime;
    
    //startTime = clock();
    ComputeSimRankMatrix(Graph, noOfVertices, noOfEdges, noOfIterations, confidence_value);
    //endTime = clock();
    
    //float time2 = (float)(endTime - startTime) / CLOCKS_PER_SEC;
    printf("[GPU]Time Elapsed in seconds: %.4f\n", totalKernelTime);
    
    //Generating Convergence Graph. 
    //system("python numpy_test.py");
    return 0;
}
