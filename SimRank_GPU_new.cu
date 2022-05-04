#include "./include/include_files.hpp"

void defaultAlgoPara () {
    printf ("Default Configuration : \n\t1. [directed-graph]\n\t2. [confidence value] : %lf\n\t3. [max. no of iterations] : %d\n", defaultConfidenceValue, defaultMaxIterations);
}

int* GraphInput (int *vertices, int *edges) {
	ifstream fileptr (DATASET_FOLDER + "graph_input.txt");
	fileptr >> *vertices >> *edges;
	
	int from, to, id=0, N=*vertices;
	printf("\ngraph config : \n\tno of vertices: %d\n\tno of edges : %d\n", *vertices, *edges);
	int* graph;
	graph = createArray<int> (*vertices);
	
	while (id < *edges) {
		fileptr >> from;
		fileptr >> to;
		
		graph[from * N + to] = 1;
		++id;
	}	
	return graph;
}


int main() {
	defaultAlgoPara();
	int vertices, edges;
	int *graph = GraphInput(&vertices, &edges);
	
	int MaxIterations;
	double ConfidenceValue;
	simrankConfigInput (MaxIterations, ConfidenceValue);
	
	
	
	// compute simrank
	
	return 0;
}
