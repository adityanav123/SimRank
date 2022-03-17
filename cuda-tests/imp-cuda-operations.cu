#ifndef CUDA_OPS_SIMRANK_H
#define CUDA_OPS_SIMRANK_H
#include <stdio.h>
#define input(a) scanf("%d", &a)
#define output_(a) printf("%d ", a);
#define nl printf("\n")
void see(int *graph, int n) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            output_(graph[i * n + j]);
        }nl;
    }
}

int main() {
    #ifndef ONLINE_JUDGE
        freopen("input.txt", "r", stdin);
    #endif
    int n, e;
    scanf ("%d%d", &n, &e);
    int *graph;
    cudaMallocManaged(&graph, sizeof(int) * n * n);
    for (int i = 0; i < e; i++) {
        int from, to;
        input(from);
        input(to);
        graph[from * n + to] = 1;
    }
    

    see(graph, n);

}

#endif