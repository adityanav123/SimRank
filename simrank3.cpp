#include <iostream>
#include <vector>
#include <unordered_map>
#include "converge.h"
#include <fstream>
using namespace std;

#define matrix_INT vector<vector<int>>
#define matrix_DOUBLE vector<vector<double>>
#define ROW_INT vector<int>
#define ROW_DOUBLE vector<double>

/* File Output
ofstream fout;
fout.open("output_simrank.txt");
****************/

void Message() {
    cout << "Default Configuration : \n\t1. [Directed-Graph]\n\t2. [Confidence Value] : 0.9\n\t3. [No. of Iterations] : 1000\n";
}

void see_graph(matrix_INT Graph) {
    cout << "\nInput Graph:\n";
    for(int i = 0; i < Graph.size(); i++) {
       cout << i << " : ";
       for(auto x : Graph[i]) {
            cout << x << " ";
       }
       cout << "\n";
    }
    cout << "\n";
}

void InsertEdge(matrix_INT &graph, int n1, int n2) {
    graph[n1][n2] = 1;
}

void resizeSimrankMatrix(matrix_DOUBLE &mtx, int size, double init_value = 0.0) {
    mtx.resize(size, ROW_DOUBLE(size, init_value));
}

ROW_INT findInNeighbors (int node, matrix_INT Graph) {
    ROW_INT answer;
    for(int i = 0; i < Graph.size(); i++) {
        if(i != node && Graph[i][node] == 1)
            answer.push_back(i);
    }
    return answer;
}

void show_ROW(ROW_INT row) {
    for(auto x : row) {
        cout << x << " ";
    }cout << "\n";
}

double simrank(matrix_DOUBLE &current, int from, int to, int k, double CONDIFENCE_VALUE, matrix_INT Graph, matrix_DOUBLE &SimRankCurrent) {
    if (k == 0) { // 0th iteration - is a Identity matrix.
        return SimRankCurrent[from][to];
    } 

    if(from == to) return 1.0; // node to itself is always 1.0 on simrank value.

    
    ROW_INT inNeigbours_from = findInNeighbors(from, Graph); // returns all the in-neighbours of 'from'
    ROW_INT inNeigbours_to = findInNeighbors(to, Graph);
    
    if(inNeigbours_to.size() == 0 || inNeigbours_from.size() == 0) return 0.0;

    double summation = 0.0;
    for(auto x : inNeigbours_from) {
        for(auto y : inNeigbours_to) {
            summation += SimRankCurrent[x][y];
        }
    }
    int size1 = inNeigbours_from.size(), size2 = inNeigbours_to.size();
 
    double NORMALISATION_FACTOR = (double)(CONDIFENCE_VALUE / (double)(size1 * size2));

    return summation * NORMALISATION_FACTOR;
}

void showSimrankMatrix(vector<matrix_DOUBLE> simrank) {
    for(int i = 0; i < simrank.size(); i++) {
        cout << "#" << i << " : \n";
        matrix_DOUBLE tmp = simrank[i];
        for(auto x : tmp) {
            for(auto y : x) {
                cout << y << " ";
            }
            cout << "\n";
        }
        cout << "======\n";
    }
}

void SimrankForAllNodes(matrix_DOUBLE &SimRank, int k, double C, int V, matrix_INT Graph) {
    matrix_DOUBLE tempSimrank;
    resizeSimrankMatrix(tempSimrank, V, -1.0);
    
    // To See SimRank output for every iteration, un-comment the below line.
    //showSimrankMatrix(SimRank); 
    
    for(int i = 0; i < V; i++) {
        for(int j = 0; j < V; j++) {
            tempSimrank[i][j] = simrank(tempSimrank, i, j, k-1, C, Graph, SimRank);
        }
    }
    
    // adding similarity values for further iterations
    SimRank = tempSimrank;
}

void ComputeSimrankMatrix(matrix_INT Graph,int noOfVertices, int noOfEdges, int max_iterations, double confidence_value) {
    //vector<matrix_DOUBLE> SimRank; 
    // Optimising for space.
    matrix_DOUBLE SimRankCurrent;

    matrix_DOUBLE initMatrix(noOfVertices, ROW_DOUBLE(noOfVertices, 0.0));
    
    for(int i = 0; i < noOfVertices; i++) {
        initMatrix[i][i] = 1.0;
    }
    
    SimRankCurrent = initMatrix; /* 0th Iteration */
    
    int k = 1;
    for(; k < max_iterations; k++) {
        // Below line - debugging.
        //cout << "iteration no. -> " << k << "\n";

        /*
            For each iterations, we have to see whether it converges or not.
            See : converge.h
            *READ MORE*
        if(checkConvergence(SimRank, confidence_value) == true) {
            break;
        }*/
        SimrankForAllNodes(SimRankCurrent, k, confidence_value, noOfVertices, Graph);
    }

    cout << "SimRank Algorithm Converged!\n";
    
    cout << "Final Simrank Matrix : \n";
    for(auto x : SimRankCurrent) {
        for(auto y : x) {
            printf("%.4f ", y);
        }printf("\n");
    }
    printf("\n");
}   

matrix_INT TakeInput(int *V, int *E) {
    ifstream file("input.txt");
    file >> *V;
    file >> *E;
    int from, to;
    int idx = 0;
    cout << "\nEntered Graph Configuration: \n";
    cout << "\tnoOfVertices: " << *V << "\n\tnoOfEdges: " << *E << "\n";
    matrix_INT Graph(*V, ROW_INT(*V, 0));
    while(idx < *E) {
        file >> from;
        file >> to;
        Graph[from][to] = 1;
        idx++; 
    }
    return Graph;
}

void TakeSimRankConfigurationInput(int &iterations, double &confidence) {
    int noOfIterations=1000;
    double confidence_value=0.9; 

    printf("Enter no. of iterations[for default, input -1]: ");
    cin >> iterations;
    printf("Enter Confidence-Value[0-1, for default, input -1]: ");
    cin >> confidence;

    if(iterations == -1) iterations = 1000;
    if(confidence == -1) confidence = 0.9;

    cout << "\n*SimRank Configuration Chosen: \n\tIterations: " << noOfIterations << "\n\tConfidence Value: " << confidence_value << "\n";
}



int main() {
    Message();
    
    int noOfVertices, noOfEdges;
    matrix_INT Graph;

    /*Taking Input from a File.*/
    Graph = TakeInput(&noOfVertices,&noOfEdges);

    int noOfIterations;
    double confidence_value;
    
    TakeSimRankConfigurationInput(noOfIterations, confidence_value);

    /*SHOW GRAPH*/
    see_graph(Graph);
    
    // SimRank Computation function
    ComputeSimrankMatrix(Graph, noOfVertices, noOfEdges, noOfIterations, confidence_value);
    return 0;
}
