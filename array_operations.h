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
int* findInNeighbors(int node, int** arr, int n_vertices) {
    std::vector<int> tmp;
    for(int i = 0; i < n_vertices; i++) {
        if(arr[i][node] == 1) {
            tmp.push_back(i);
        }
    }
    int s = tmp.size();
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
