#include "./include/include_files.hpp"

__managed__ int noOfVertices;

void PreSetup () {
	system("truncate -s 0 ./data/l1Norm.txt"); // clearing up previous norms.
}

void ShowAlgoDefaults () {
    printf ("Default Configuration : \n\t1. [directed-graph]\n\t2. [confidence value] : %lf\n\t3. [max. no of iterations] : %d\n", defaultConfidenceValue, defaultMaxIterations);
}

int* GraphInput () {
	int edges;
	ifstream fileptr (DATASET_FOLDER + "graph_input.txt");
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


void CalculateSimrankUtil (double *SimrankCurrent, int *graph, int currentIteration, double ConfidenceValue) {
	int sizeOfSimrank = noOfVertices * noOfVertices;
	double *nextSimrank = createArray <double> (noOfVertices);
	double *device_nextSimrank;
	cudaMalloc(&device_nextSimrank,sizeof(double) * sizeOfSimrank);
	cudaMemcpy (device_nextSimrank, nextSimrank, sizeof(double) * sizeOfSimrank, cudaMemcpyHostToDevice);

	int BlockCount, ThreadCount;
	cudaGetDevice(&deviceId);
	cudaDeviceGetAttribute (&noOfSMs, cudaDevAttrMultiProcessorCount, deviceId);

	// PreCompute The In-Neighbours;
	int inNeighboursSize = sizeof(int) * (noOfVertices * (noOfVertices + 1));
	int *inNeighbours;
	cudaMallocManaged (&inNeighbours, inNeighboursSize);

	inNeighbours = allInNeighbours (graph, noOfVertices, inNeighbours);

	//debugInNeighbours (inNeighbours, noOfVertices);

	int *pursuePairs;
	int noOfPairs = noOfVertices * noOfVertices;

	pursuePairs = calloc (noOfPairs * 2, sizeof(int)); // init to 0.

	BlockCount = noOfVertices * noOfVertices;
	ThreadCount = 1024;

	pursuePairs = storePairs (pursuePairs, noOfVertices, noOfPairs); // generate pairs.

	// update BlockCount and ThreadCount.
	BlockCount = noOfPairs * 2;
	ThreadCount = 1024;

	// allocating space in GPU
	int *device_Pairs;
	cudaMalloc (&device_Pairs, sizeof(int) * noOfPairs * 2);
	cudaMemcpy (device_Pairs, pursePPairs, sizeof(int) * noOfPairs * 2, cudaMemcpyHostToDevice);

	int *device_graph;
	cudaMalloc(&device_graph, sizeof(int) * noOfVertices * noOfVertices);
	cudaMemcpy(device_graph, graph, sizeof(int) * noOfVertices, noOfVertices, cudaMemcpyHostToDevice);



	kernel <<< BlockCount, ThreadCount >>> (device_Pairs, inNeighbours, device_graph, device_nextSimrank, );
	cudaDeviceSynchronize();

	return;
}

void ComputeSimrank (int *graph, int MaxNoOfIterations, double ConfidenceValue) {
	double *simrank = createArray <double> (noOfVertices);
	for (int i = 0; i < noOfVertices; i++) {
		simrank[i * noOfVertices + i] = 1.0;
	}
	//seeMatrix <double> (simrank, noOfVertices); //--> simrank matrix at iteration-0.
	double scoreOfSimrankMatrix=0.0;
	// calculate score for iteration-0
	converge (simrank, noOfVertices, &scoreOfSimrankMatrix);
	printf ("score of simrank matrix at iteration 0 : %lf\n", scoreOfSimrankMatrix);
	int iteration=1, ConvergedPoint=INT_MAX;

	for ( ; iteration <= MaxNoOfIterations ; iteration++) {
		storeSimrankScore (simrank, noOfVertices);
		// calculating simrank.
		CalculateSimrankUtil (simrank, graph, iteration, ConfidenceValue);

		bool convergeflag = converge (simrank, noOfVertices, &scoreOfSimrankMatrix);
		if (iteration >= 3 && convergeflag == true) {
			ConvergedPoint = iteration;
			break;
		}
	}

	cout << "converged at : " << ConvergedPoint << "\n";
}



int main() {
	PreSetup();
	ShowAlgoDefaults();

	int *graph = GraphInput();
	
	seeMatrix<int> (graph, noOfVertices);

	int MaxIterations;
	double ConfidenceValue;
	simrankConfigInput (MaxIterations, ConfidenceValue);
	
	// compute simrank
	ComputeSimrank (graph, MaxIterations, ConfidenceValue);
	return 0;
}
