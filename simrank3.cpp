#include "./include/array_operations.hpp"
#include <climits>
/* global parameters */
int noOfVertices;

void PreSetup () {
	system("truncate -s 0 ./data/l1Norm.txt"); // clearing up previous norms.
}

void ShowAlgoDefaults () {
    printf ("Default Configuration : \n\t1. [directed-graph]\n\t2. [confidence value] : %lf\n\t3. [max. no of iterations] : %d\n", defaultConfidenceValue, defaultMaxIterations);
}

int* findInNeighbours (int node, int *graph, int vertexCount, int *size) {
	int *arr = createArray<int> (noOfVertices);
	int cnt=0;
	for (int i = 0; i < vertexCount; i++) {
		if (graph[node * vertexCount + i] == 1) {
			++cnt;
			arr[i] = 1;
		}else {
			arr[i] = 0;
		}
	}

	*size = cnt;
	return arr;
}


double simrankUtil(int from, int to, int k, double confidenceValue, int *Graph, double* simrankMatrix, int n_vertices) {
    if (k == 0) return simrankMatrix[from * n_vertices + to];
    if (from == to) return 1.0;

    int ia_size, ib_size;
    int* inNeighbours_from = findInNeighbours(from, Graph, n_vertices, &ia_size);
    int* inNeighbours_to = findInNeighbours(to, Graph, n_vertices, &ib_size);
    
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
void SimRankForAllNodes (int k, double* simrank, int *Graph, int noOfVertices, double confidenceValue) {
   	// double* tmpSimRank = createArray_D(noOfVertices); // default initialisation with 0.0 as array values.
	double* tmpSimRank = createArray <double> (noOfVertices);
	
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
   
void ComputeSimRankMatrix (int* Graph, int noOfVertices, int max_iterations, double confidence_value) {
    double* SimRank = (double*) malloc(sizeof(double) * noOfVertices * noOfVertices);
    int V = noOfVertices;
    // 1 st iterations.
    for(int i = 0; i < V; i++) {
        for(int j = 0; j < V; j++) {
            SimRank[i*V+j] = 0.0 + 1.0 * (i==j);
        }
    } 
    double scoreOfSimrankMatrix  = 0.00;
   	converge (SimRank, noOfVertices, &scoreOfSimrankMatrix);
   
    // rest of the iterations/
    int k = 1, ConvergedPoint=INT_MAX;
    clock_t start, end;
    for(; k<max_iterations; k++) {
        /* below two functions are for plotting convergence graph */
		storeSimrankScore (SimRank, noOfVertices);
        
		start = clock();
        SimRankForAllNodes(k, SimRank, Graph, noOfVertices, confidence_value);
        end = clock();
    
        totalComputationTime += (double)(end-start)/CLOCKS_PER_SEC;

        bool convergeflag = converge (SimRank, noOfVertices, &scoreOfSimrankMatrix);
		if (k >= 3 && convergeflag == true) {
			ConvergedPoint = k;
			break;
		}
    }
    printf("Total Kernel Time : %.5f\n",totalComputationTime); 
   // printf("Converged on : %d\n",k);
 
    printf("SimRank Algorithm Converged!\nFinal SimRank Matrix : \n");
    for(int i = 0; i < noOfVertices; i++) {
        for(int j = 0; j < noOfVertices; j++) {
            printf("%.4f ", SimRank[i*noOfVertices+j]);
        }printf("\n");
    }
    printf("\n");
}

int* GraphInput () {
	int edges;
	ifstream fileptr ("./data/datasets/graph_input.txt");
	fileptr >> noOfVertices >> edges;
	
	int from, to, id=0, N=noOfVertices;
	printf("\ngraph config : \n\tno of vertices: %d\n\tno of edges : %d\n", noOfVertices, edges);
	int* graph;
	//graph = createArray<int> (noOfVertices);
	graph = (int*)calloc(noOfVertices * noOfVertices, sizeof(int));
	
	while (id < edges) {
		fileptr >> from;
		fileptr >> to;
		graph[from * N + to] = 1;
		++id;
	}	
	return graph;
}




int main() {
 	PreSetup();
	ShowAlgoDefaults();

	int *graph = GraphInput();
    
	int MaxIterations;
	double ConfidenceValue;
	simrankConfigInput (MaxIterations, ConfidenceValue);
	
    printf("adjacency matrix of graph :\n");
	seeMatrix<int> (graph, noOfVertices);

    // SimRank Computation function
    clock_t startTime, endTime; 

    startTime = clock();
    ComputeSimRankMatrix(graph, noOfVertices, MaxIterations, ConfidenceValue);
    endTime = clock();
    /*****************************/ 
    float time2 = (float)(endTime - startTime) / CLOCKS_PER_SEC;
    
    printf("[CPU]Time Elapsed in seconds: %.4f\n", time2);
    
    /* generating convergence plot. */
    //system("python numpy_test.py");
    
    return 0;
}
