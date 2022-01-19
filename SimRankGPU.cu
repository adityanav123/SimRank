#include <stdio.h>
#include <vector>
#include <unordered_map>
#include "convergeGPU.h"
#include <fstream>
#include <stdio.h>
#include "array_operations.h"
#include <cuda_profiler_api.h>
#include <thrust/scan.h>
#include <thrust/count.h>

#define matrix_INT vector<vector<int>>
#define matrix_DOUBLE vector<vector<double>>
#define ROW_INT vector<int>
#define ROW_DOUBLE vector<double>
#define newline printf("\n")

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

__device__ int n_vertices_gpu;
__device__ int inNeighbourIndex; // stores the in-neighbour index for further calculation.
__device__ int *calculationArray;

__device__ int inAsize, inBsize, tmpCalculation; // global; device declaration.
__device__ double tmpSimrankComputation; // stores temporary simrank values.

__global__ void computeSimrank (int* Graph, double* SimRank, int* inNeighbours, int node_from, int node_to) {
    int bid = blockIdx.x;
    //int ia_neighbour = blockIdx.x, 
    //    ib_neighbour = blockIdx.y;

    int from = node_from,
        to = node_to;
    int ia_neighbour = bid / n_vertices_gpu, 
        ib_neighbour = bid % n_vertices_gpu;
    
   
    if (inNeighbours[from * (n_vertices_gpu + 1) + ia_neighbour] == 1 && inNeighbours[to * (n_vertices_gpu + 1) + ib_neighbour] == 1) {
       // printf("inNeighbours : %d and %d\n", ia_neighbour, ib_neighbour);
        tmpSimrankComputation = SimRank[ia_neighbour * n_vertices_gpu + ib_neighbour];  
    }

}


__global__ void kernel_ (int *Graph, int *noOfVertices, double *confidence_value, double *simrankCurrent, double *simrank, int *inNeighbours) {
   n_vertices_gpu = noOfVertices[0]; // global device variable : # of vertices
   int bid = blockIdx.x;
   int node_from, node_to;

   node_from = bid / n_vertices_gpu;
   node_to = bid % n_vertices_gpu;
    
   //printf("%d and %d\n", node_from, node_to);

   /*if (node_from == node_to) {
      simrankCurrent[node_from * n_vertices_gpu + node_to] = 1.0; 
    return;
   }*/

   simrankCurrent[node_from * n_vertices_gpu + node_to] = (node_from == node_to) * 1.0 + (node_from != node_to) * 0.0;


   if (node_from != node_to) {
       tmpSimrankComputation = 0.0; // stores the temporary simrank computaion for any 2 nodes. 
   
        computeSimrank <<< n_vertices_gpu * n_vertices_gpu, 1 >>> (Graph, simrank, inNeighbours, node_from, node_to);
        cudaDeviceSynchronize();
   
        double mul = inNeighbours[node_from * (n_vertices_gpu + 1) + n_vertices_gpu] * inNeighbours[node_to * (n_vertices_gpu + 1) + n_vertices_gpu];
        //simrankCurrent[node_from * n_vertices_gpu + node_to] = (mul > 0) * tmpSimrankComputation * (confidence_value[0] / mul) + (mul == 0) * 0;
        if (mul == 0) {
            simrankCurrent[node_from * n_vertices_gpu + node_to] = 0.0;
        }
        else {
            simrankCurrent[node_from * n_vertices_gpu + node_to] = tmpSimrankComputation * (confidence_value[0] / mul);
        }
    }
}


double totalKernelTime = 0.0;
// updated kernel call.
void SimRankForAllNodes_ (int iteration, double *SimRank, int *Graph, int n_vertices, double confidence_value) {
    double *tmpSimrank = createArray_D(n_vertices);
    
    clock_t startKernel, endKernel; // timing the external kernel.

    int n_blocks = n_vertices;
    
    int sizeofSimRank = n_vertices * n_vertices;    

    /* Device Parameters */

    double *device_tmpSimrank;
    cudaMalloc(&device_tmpSimrank, sizeof(double) * sizeofSimRank);
    cudaMemcpy(device_tmpSimrank, tmpSimrank, sizeof(double) * sizeofSimRank, cudaMemcpyHostToDevice);

    double *device_currentSimrank;
    cudaMalloc(&device_currentSimrank, sizeof(double) * sizeofSimRank);
    cudaMemcpy(device_currentSimrank, SimRank, sizeof(double) * sizeofSimRank, cudaMemcpyHostToDevice);
        
    int vertex[1] = {n_vertices};
    int *device_vertex;
    cudaMalloc(&device_vertex, sizeof(int));
    cudaMemcpy(device_vertex, vertex, sizeof(int), cudaMemcpyHostToDevice);

    int *device_Graph;
    cudaMalloc(&device_Graph, sizeof(int) * sizeofSimRank);
    cudaMemcpy(device_Graph, Graph, sizeof(int) * sizeofSimRank, cudaMemcpyHostToDevice);

    double cv[1] = {confidence_value};
    double *device_cv;
    cudaMalloc(&device_cv, sizeof(double));
    cudaMemcpy(device_cv, cv, sizeof(double), cudaMemcpyHostToDevice);
    
    /* Pre-Computing the in-neighbours */
    int *in_neighbours;
    in_neighbours = findInNeighbours_(Graph, n_vertices); // <array_operations.h>
    // print the in-neighbours
    //printInNeighbours (in_neighbours, n_vertices); <array_operations.h>
   
    int* device_in_neighbours;
    cudaMalloc(&device_in_neighbours, sizeof(int) * n_vertices * (n_vertices + 1));
    cudaMemcpy(device_in_neighbours, in_neighbours, sizeof(int) * n_vertices * (n_vertices + 1), cudaMemcpyHostToDevice);

    /* Kernel Call */ 
    startKernel = clock();
    kernel_ <<< n_blocks * n_blocks, 1 >>>(device_Graph, device_vertex, device_cv, device_tmpSimrank, device_currentSimrank, device_in_neighbours);
    endKernel = clock();
    
    totalKernelTime += (endKernel - startKernel) / CLOCKS_PER_SEC;

    cudaMemcpy(tmpSimrank, device_tmpSimrank, sizeof(double) * sizeofSimRank, cudaMemcpyDeviceToHost); 
    
    for(int i = 0; i < n_vertices; i++) {
        for(int j = 0; j < n_vertices; j++) {
            SimRank[i * n_vertices + j] = tmpSimrank[i * n_vertices + j];
        }    
    }


    /*for (int i = 0; i < n_vertices; i++) {
        for (int j = 0; j < n_vertices; j++) {
            printf("%d ", SimRank[i * n_vertices + j]);
        }
        printf("\n");
    }*/
}

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
void ComputeSimRankMatrix (int* Graph, int noOfVertices, int noOfEdges, int max_iterations, double confidence_value) {
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

        SimRankForAllNodes_(k, SimRank, Graph, noOfVertices, confidence_value);
        /* Checking Convergence of SimRank Matrix */ 
        if (k > 2 && checkConvergence(SimRank, noOfVertices, &normValue) == true) {
            break;
        }
    }
    //printf("Total Kernel Time : %.5f\n",totalKernelTime); 
    printf("Converged on : %d\n",k);
    
    printf("SimRank Algorithm Converged!\nFinal SimRank Matrix : \n");
    for(int i = 0; i < noOfVertices; i++) {
        for(int j = 0; j < noOfVertices; j++) {
            printf("%.4f ", SimRank[i*noOfVertices+j]);
        }printf("\n");
    }
    printf("\n");
}

int* TakeInput(int *V, int *E) {
    string filePath = "./tests/datasets/";
    //string fileName = "watts_strogatz.txt";
    string fileName = "graph_input.txt";
    ifstream file(filePath + fileName);
    
    //ifstream file("input.txt");
    file >> *V;
    file >> *E;
    
    int n_vertices = *V, n_edges = *E;
    int from, to;
    int idx = 0;
    
    printf("\nEntered Graph Configuration : \n");
    printf("\tnoOfVertices: %d\n\tnoOfEdges: %d\n",*V,*E);  
    
    int *Graph; 
    Graph = (int*) malloc(sizeof(int) * n_vertices * n_vertices);
    
    /* int** Graph = new int*[n_vertices+1];
    for(int i = 0; i < n_vertices; i++) {
        Graph[i] = new int[n_vertices+1];
    }*/
    
    for (int i = 0; i < n_vertices; i++) {
        for (int j = 0; j < n_vertices; j++) {
           Graph[i * n_vertices + j] = 0; 
        }
    }
    

    while(idx < n_edges) {
        file >> from;
        file >> to;
        Graph[from * n_vertices + to] = 1;
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
    // converting to 1-d array
    //int** Graph = TakeInput(&noOfVertices, &noOfEdges);
    int *Graph = TakeInput (&noOfVertices, &noOfEdges); 

    // see graph
    for (int i = 0; i < noOfVertices; i++) {
        for (int j = 0; j < noOfVertices; j++) {
            printf("%d ", Graph[i * noOfVertices + j]);
        }newline;
    }

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
