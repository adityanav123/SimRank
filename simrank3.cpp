#include <iostream>
#include <vector>
#include <unordered_map>
#include "convergeGPU.h"
#include <fstream>
#include <stdio.h>
#include "array_operations.h"
#include <bits/stdc++.h>
using namespace std;

#define d_ for(int i = 0; i < 1000000; i++)
#define matrix_INT vector<vector<int>>
#define matrix_DOUBLE vector<vector<double>>
#define ROW_INT vector<int>
#define ROW_DOUBLE vector<double>

void Message() {
    cout << "Default Configuration : \n\t1. [Directed-Graph]\n\t2. [Confidence Value] : 0.9\n\t3. [No. of Iterations] : 1000\n";
}

double simrankUtil(int from, int to, int k, double confidenceValue, int **Graph, double* simrankMatrix, int n_vertices) {
    if (k == 0) return simrankMatrix[from * n_vertices + to];
    if (from == to) return 1.0;

    int ia_size, ib_size;
    int* inNeighbours_from = findInNeighbors(from, Graph, n_vertices, &ia_size);
    int* inNeighbours_to = findInNeighbors(to, Graph, n_vertices, &ib_size);
    
    if(ia_size == 0 || ib_size == 0) return 0.0;
    
    double summation = 0.0;
    for(int i = 0; i < ia_size; i++) {
        for(int j = 0; j < ib_size; j++) {
            summation += simrankMatrix[inNeighbours_from[i] * n_vertices + inNeighbours_to[j]];
        }
    }
    
    double normalisationFactor = (double) (confidenceValue / (double)(ia_size * ib_size));
    //printf("returning: %lf", summation * normalisationFactor);
    return summation * normalisationFactor;
}

double totalComputationTime = 0.00;
void SimRankForAllNodes (int k, double* simrank, int **Graph, int noOfVertices, double confidenceValue) {
   double* tmpSimRank = createArray_D(noOfVertices); // default initialisation with 0.0 as array values.
   //clock_t start, end;
   //d_;
   for(int i = 0; i < noOfVertices; i++) {
       for(int j = 0; j < noOfVertices; j++) {
           //start = clock();
           tmpSimRank[i * noOfVertices + j] = simrankUtil(i, j, k - 1, confidenceValue, Graph, simrank, noOfVertices);
           //end = clock();
           //totalComputationTime += (double)(end - start) / CLOCKS_PER_SEC;
       }
   }
    
   for(int i = 0; i < noOfVertices; i++) {
       for(int j = 0; j < noOfVertices; j++) {
           simrank[i * noOfVertices + j] = tmpSimRank[i * noOfVertices + j];
       } 
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
    double normValue = 0.00;
    checkConvergence(SimRank, V, &normValue);
    printf("starting norm value: %d\n", normValue);
    // rest of the iterations/
    int k = 1;
    clock_t start, end;
    for(; k<max_iterations; k++) {
        /* below two functions are for plotting convergence graph */
        storeL2Norm(SimRank, noOfVertices);
        storel1Norm(SimRank, noOfVertices);
        
        start = clock();
        SimRankForAllNodes(k, SimRank, Graph, noOfVertices, confidence_value);
        end = clock();
        
        totalComputationTime += (double)(end-start)/CLOCKS_PER_SEC;
        /* Checking Convergence of SimRank Matrix */ 
        //printf("\nnorm values : %lf\n", normValue);
        if (k > 2 && checkConvergence(SimRank, noOfVertices, &normValue) == true) {
            break;
        }
    }
    printf("Total Kernel Time : %.5f\n",totalComputationTime); 
    printf("Converged on : %d\n",k);
 
    printf("SimRank Algorithm Converged!\nFinal SimRank Matrix : \n");
    for(int i = 0; i < noOfVertices; i++) {
        for(int j = 0; j < noOfVertices; j++) {
            printf("%.4f ", SimRank[i*noOfVertices+j]);
        }printf("\n");
    }
    printf("\n");
}

int** TakeInput(int *V, int *E) {
    //ifstream file("input.txt");
    //ifstream file("wiki-Vote.txt");
    string filePath = "./tests/datasets/";
    //string fileName = "watts_strogatz.txt";
    string fileName = "graph_input.txt"; 
    ifstream file(filePath + fileName);
    
    file >> *V;
    file >> *E;
    
    int n_vertices = *V, n_edges = *E;
    int from, to;
    int idx = 0;
    
    printf("\nEntered Graph Configuration : \n");
    printf("\tnoOfVertices: %d\n\tnoOfEdges: %d\n",*V,*E);  
    int** Graph = new int*[n_vertices+1];
    for(int i = 0; i <= n_vertices; i++) {
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
    
    system("./delete_l1_l2.sh"); 
    
    // Graph Input.
    int noOfVertices, noOfEdges;
    int** Graph = TakeInput(&noOfVertices, &noOfEdges);

    // SimRank Configuration.
    int noOfIterations;
    double confidence_value;
    TakeSimRankConfigurationInput(noOfIterations, confidence_value);
    
    /*SHOW GRAPH*/
    //seeGraph(Graph, noOfVertices);
    
    // SimRank Computation function
    clock_t startTime, endTime; 

    startTime = clock();
    ComputeSimRankMatrix(Graph, noOfVertices, noOfEdges, noOfIterations, confidence_value);
    endTime = clock();
    /*****************************/ 
    float time2 = (float)(endTime - startTime) / CLOCKS_PER_SEC;
    
    printf("[CPU]Time Elapsed in seconds: %.4f\n", time2);
    
    /* generating convergence plot. */
    system("python numpy_test.py");
    
    return 0;
}
