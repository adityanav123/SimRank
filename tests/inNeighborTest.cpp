#include<bits/stdc++.h>
#include"array_operations.h"
using namespace std;
#define matrix_INT int**

int** TakeInput(int *V, int *E) {
    ifstream file("../data/datasets/graph_input.txt");
    file >> *V;
    file >> *E;
    
    int n_vertices = *V, n_edges = *E;
    int from, to;
    int idx = 0;
    
    printf("\nEntered Graph Configuration : \n");
    printf("\tnoOfVertices: %d\n\tnoOfEdges: %d\n",*V,*E);  
    int** Graph = new int*[n_vertices];
    for(int i = 0; i < n_vertices; i++) {
        Graph[i] = new int[n_vertices];
    }
   // matrix_INT Graph(*V, ROW_INT(*V, 0));
    while(idx < n_edges) {
        file >> from;
        file >> to;
        Graph[from][to] = 1;
        idx++; 
    }
    return Graph;
}

int main() {
    int n = 5;
    int **arr;
    int v, e;
    arr = TakeInput(&v,&e);
    seeGraph(arr, v);
    int node = 0;
    int* arr1;
    int finalSize;
    arr1 = findInNeighbors(node, arr, v, &finalSize);
    printf("\nfinal size : %d\n", finalSize);
    cout << "\nin neighbors of > " << node << " : ";
    for(int i = 0; i < finalSize; i++) {
        printf("%d ", arr1[i]);
    } 
    return 0;
}
