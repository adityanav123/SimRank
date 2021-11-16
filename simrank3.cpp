#include <iostream>
#include <vector>
#include <unordered_map>
#include "converge.h"
#include <fstream>
#include <stdio.h>
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


double simrank(int from, int to, int k, double CONDIFENCE_VALUE, matrix_INT Graph, ROW_DOUBLE &SimRank_) {
    int vertices = Graph.size();
    if (k == 0) { // 0th iteration - is a Identity matrix.
        return SimRank_[from * vertices + to];
    } 
    /*GPU- 
     * int id = blockIdx.x * blockDim.x + threadIdx.x;
     *if(id == 0) SimRank_[..] = SimRank[from*SimRankCurrent.size()+to];
     *
     * */
    if(from == to) return 1.0; // node to itself is always 1.0 on simrank value.

    /* The main issue for GPU */ 
    ROW_INT inNeigbours_from = findInNeighbors(from, Graph); // returns all the in-neighbours of 'from'
    ROW_INT inNeigbours_to = findInNeighbors(to, Graph);
    
    if(inNeigbours_to.size() == 0 || inNeigbours_from.size() == 0) return 0.0;
    //int vertices = SimRankCurrent.size();
    double summation = 0.0;
    for(auto x : inNeigbours_from) {
        for(auto y : inNeigbours_to) {
            summation += SimRank_[x*vertices+y];
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

void SimrankForAllNodes(int k, double C, int V, matrix_INT Graph, ROW_DOUBLE &SimRank_) {
    /* 2D - CPU Config */
    /*matrix_DOUBLE tempSimrank;
    resizeSimrankMatrix(tempSimrank, V, -1.0);
    */

    /* 1D - GPU */
    ROW_DOUBLE tmpSimRank(V*V, -1.0);
    
    // To See SimRank output for every iteration, un-comment the below line.
    //showSimrankMatrix(SimRank); 
    
    for(int i = 0; i < V; i++) {
        for(int j = 0; j < V; j++) {
            tmpSimRank[i*V+j] = simrank(i, j, k-1, C, Graph, SimRank_);
        }
    }
    
    // adding similarity values for further iterations
    //SimRank = tempSimrank;
    SimRank_ = tmpSimRank;
}

void ComputeSimrankMatrix(matrix_INT Graph,int noOfVertices, int noOfEdges, int max_iterations, double confidence_value) {
    // Optimising for space.
    //matrix_DOUBLE SimRankCurrent;

    /* Optimising for GPU */
    ROW_DOUBLE SimRank_(noOfVertices * noOfVertices, 0.0);

    //matrix_DOUBLE initMatrix(noOfVertices, ROW_DOUBLE(noOfVertices, 0.0));
    
    for(int i = 0; i < noOfVertices ; i++) {
        SimRank_[i * noOfVertices + i] = 1.0;
    }
   
    /*
    cout << "1D SimRank: \n";
    for(int i = 0; i < noOfVertices ; i++) {
        for(int j = 0; j < noOfVertices; j++) {
            printf("%.4f ", SimRank_[i*noOfVertices+j]);
        }
        printf("\n");
    }
    */
    
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
        storeL2Norm(SimRank_, noOfVertices);
        storel1Norm(SimRank_, noOfVertices);
        SimrankForAllNodes(k, confidence_value, noOfVertices, Graph, SimRank_);
    }
    cout << "SimRank Algorithm Converged!\n";
    
    cout << "Final Simrank Matrix : \n";
    
    for(int i = 0; i < noOfVertices; i++) {
        for(int j = 0; j < noOfVertices; j++) {
            printf("%.4f ", SimRank_[i*noOfVertices+j]);
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
    scanf("%d", &iterations);
    printf("Enter Confidence-Value[0-1, for default, input -1]: ");
    scanf("%lf",&confidence);

    if(iterations == -1) iterations = 1000;
    if(confidence == -1) confidence = 0.9;

    printf("\n*SimRank Configuration Chosen: \n\tIterations: %d\n\tConfidence Value: %lf\n",iterations, confidence);
}



int main() {
    Message();
    system("./delete_l1_l2.sh"); 
    //system("echo $PWD");
    int noOfVertices, noOfEdges;
    matrix_INT Graph;

    /*Taking Input from a File.*/
    Graph = TakeInput(&noOfVertices,&noOfEdges);

    int noOfIterations;
    double confidence_value;

    /*Take SimRank Configuration Input*/
    TakeSimRankConfigurationInput(noOfIterations, confidence_value);

    /*SHOW GRAPH*/
    see_graph(Graph);
    clock_t startTime, endTime; 
    // SimRank Computation function
    startTime = clock();
    ComputeSimrankMatrix(Graph, noOfVertices, noOfEdges, noOfIterations, confidence_value);
    endTime = clock();
    float time2 = (float)(endTime - startTime) / CLOCKS_PER_SEC;
    printf("[CPU]Time Elapsed in seconds: %.4f\n", time2);
    system("python numpy_test.py");
    return 0;
}
