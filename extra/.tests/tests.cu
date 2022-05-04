#include <stdio.h>
#include <fstream>
#include <iostream>
#include "array_operations.h"
using namespace std;
int** TakeInput (int *V, int *E) {
    ifstream graph ("input.txt");
    graph >> *V;
    graph >> *E;
    int node1, node2;
    int index = 0;
    printf("\nEntered Graph Configuration : \n\tnoOfVertices: %d\n\tnoOfEdges: %d\n", *V, *E);
    
    int n_vert = *V, n_edge = *E;

    int **Graph = new int*[n_vert];
    for(int i = 0; i < n_vert; i++) {
        Graph[i] = new int[n_vert];
    }

    while (index < *E) {
        graph >> node1;
        graph >> node2;
        printf("nodes : %d %d\n", node1, node2);
        Graph[node1][node2] = 1;
        ++index;
    }

    return Graph;
}
int main() {
    int a[4][4];
    memset(a, -1, sizeof(a));

    for(int i = 0; i < 4; i++) {
        for(int j = 0; j < 4; j++) {
            printf("%d ",a[i][j]);
        }
        printf("\n");
    }
    int V, E;
    int **graph = TakeInput(&V, &E);
    for(int i = 0; i < V; i++) {
        for(int j = 0; j < V; j++) {
            printf("%d ", graph[i][j]);
        }
        printf("\n");
    }

    printf("%d\n", sizeof(graph[1]));

    int* neighbors = findInNeighbors(1, graph, V);
    printf("In-Neighbors of 1 : ");
    int size = sizeof(neighbors) / sizeof(int);
    printf("size: %d\n", size);
    for(int i = 0; i < size; i++) {
        printf("%d ", neighbors[i]);
    }printf("\n");

    seeGraph(graph, V);
    return 0;
}
