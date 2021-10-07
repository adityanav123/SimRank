#include <iostream>
#include <vector>
#include <unordered_map>
using namespace std;
#define matrix_INT vector<vector<int>>
#define matrix_DOUBLE vector<vector<double>>
#define ROW_INT vector<int>
#define ROW_DOUBLE vector<double>

void Message() {
    cout << "default : Directed-Graph\n";
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

double simrank(matrix_DOUBLE &current, int from, int to, int k, vector<matrix_DOUBLE> &SimRank, double CONDIFENCE_VALUE, matrix_INT Graph) {
    if (k == 0) { // 0th iteration - is a Identity matrix.
        return SimRank[k][from][to];
    }

    if(from == to) return 1.0; // node to itself is always 1.0 on simrank value.

    
    ROW_INT inNeigbours_from = findInNeighbors(from, Graph); // returns all the in-neighbours of 'from'
    ROW_INT inNeigbours_to = findInNeighbors(to, Graph);
    
    if(inNeigbours_to.size() == 0 || inNeigbours_from.size() == 0) return 0.0;

    /*cout << "in-neighbors : \n";
    cout << "of : " << from << " --> "; show_ROW(inNeigbours_from);
    cout << "of : " << to << " --> "; show_ROW(inNeigbours_to);
I   */
    double summation = 0.0;
    for(auto x : inNeigbours_from) {
        for(auto y : inNeigbours_to) {
            summation += simrank(current, x, y, k-1, SimRank, CONDIFENCE_VALUE, Graph);
        }
    }
    int size1 = inNeigbours_from.size(), size2 = inNeigbours_to.size();

    //if(size1 == 0 || size2 == 0) return 0.0; // i.e. no in-neighbors.
    
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

void SimrankForAllNodes(vector<matrix_DOUBLE> &SimRank, int k, double C, int V, matrix_INT Graph) {
    //cout << "value of k : " << k << "\n";
    
    matrix_DOUBLE tempSimrank;
    resizeSimrankMatrix(tempSimrank, V, -1.0);
    
    //showSimrankMatrix(SimRank); 
    
    for(int i = 0; i < V; i++) {
        for(int j = 0; j < V; j++) {
            tempSimrank[i][j] = simrank(tempSimrank, i, j, k-1, SimRank, C, Graph);
            //cout << "temp_answer = " << tempSimrank[i][j] << "\n";
        }
    }
    
    SimRank.push_back(tempSimrank);
    //SimRank[k] = tempSimrank;
    
   // cout << "temporary simrank matrix : \n";
    /*for(auto x : SimRank[k]) {
        for(auto y : x) {
            cout << y << " ";
        }cout << "\n";
    }*/
}

void ComputeSimrankMatrix(matrix_INT Graph,int noOfVertices, int noOfEdges, int max_iterations, double confidence_value) {
    vector<matrix_DOUBLE> SimRank; 

    matrix_DOUBLE initMatrix(noOfVertices, ROW_DOUBLE(noOfVertices, 0.0));
    
    for(int i = 0; i < noOfVertices; i++) {
        initMatrix[i][i] = 1.0;
    }
    
    /*
    for(auto x : initMatrix) {
        for(auto y : x) {
            printf("%lf ", y);
        } printf("\n");
    }
    printf("\n\n");
    */

    SimRank.push_back(initMatrix);
    
    for(int k = 1; k < max_iterations; k++) {
        //cout << "iteration : #" << k << "\n";
        SimrankForAllNodes(SimRank, k, confidence_value, noOfVertices, Graph);
    }
    cout << "iterations completed!\n\n\n";

    for(auto x : SimRank[max_iterations-1]) {
        for(auto y : x) {
            printf("%lf ", y);
        }printf("\n");
    }
    printf("\n");
}   


int main() {
    Message();

    /*#ifndef ONLINE_JUDGE
        freopen("input.txt", "r", stdin);
        freopen("output.txt", "w", stdout);
    #endif
    */
    int noOfVertices, noOfEdges;
    cin >> noOfVertices >> noOfEdges; 

    matrix_INT Graph;
    Graph.resize(noOfVertices, ROW_INT(noOfVertices, 0));

    for(int i = 0; i < noOfEdges; i++) {
        int from, to;
        cin >> from >> to;
        Graph[from][to] = 1;
    }
    /*SHOW GRAPH*/
    cout << "Graph Entered ! : \n";
    for(int i = 0; i < noOfVertices; i++) {
        cout << i << " : ";
        for(int j = 0; j < Graph[i].size(); j++) {
            cout << Graph[i][j] << " ";
        }
        cout << "\n";
    }cout << "\n\n";

    ComputeSimrankMatrix(Graph, noOfVertices, noOfEdges, 1000, 0.9);
    return 0;
}
