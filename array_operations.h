#include <stdio.h>
#include <vector>

double* createArray_D(int size_m, double value=0.0) {
    double* tmp = (double*) malloc(sizeof(double) * size_m * size_m);
    for(int i=0;i<size_m;i++) {
        tmp[i] = value;
    }
    return tmp;
}

/* SimRank Computations */
int* findInNeighbors(int node, int** arr, int n_vertices, int* endVertices) {
    std::vector<int> tmp;
    for(int i = 0; i < n_vertices; i++) {
        if(arr[i][node] == 1) {
            tmp.push_back(i);
        }
    }
    int s = tmp.size();
    *endVertices = s;
    //printf("In-Neighbor size: %d\n", s);
    int *ans = (int*) malloc(sizeof(int) * s);
    int i=0;
    for(auto x : tmp) {
        ans[i++] = x;
    }
    return ans;
}

void seeGraph(int** graph, int size) {
    for(int i = 0; i < size; i++) {
        for(int j = 0; j < size; j++) {
            printf("%d ", graph[i][j]);
        }printf("\n");
    }
}
void printInNeighbours (int* in_neighbours, int n_vertices) {
    for (int i = 0; i < n_vertices; i++) {
        for (int j = 0; j <= n_vertices; j++) {
            printf("%d ", in_neighbours[i * (n_vertices + 1) + j]);
        }
        printf("\n");
    }
}
    
int *findInNeighbours_ (int *Graph, int n_vertices) {
    int *returnArray;
    returnArray = (int*) malloc(sizeof(int) * n_vertices * (n_vertices + 1));
    
    // calculations
    for (int node = 0; node < n_vertices; ++node) {
        // calculate in-neighbour for the current node;
        int count=0;
        for (int vertex = 0; vertex < n_vertices; vertex++) {
            returnArray[node * (n_vertices + 1) + vertex] = (Graph[vertex * n_vertices + node] == 1) ? 1 : 0; 
            count += (Graph[vertex * n_vertices + node] == 1) ? 1 : 0;
        } 
        returnArray[node * (n_vertices+1) + n_vertices] = count; // last position stores the count.
    }
    return returnArray;
}
