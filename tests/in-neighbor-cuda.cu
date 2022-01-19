#include <stdio.h>

void see(int *a, int size) {
    for(int i = 0; i < size; i++) {
        for(int j = 0; j < size; j++) {
            printf("%d ", a[i * size + j]); 
        }
        printf("\n");
    }
}

__global__ void kernel (int *graph, int *in_neighbours, int *node, int* index, int *vertex) {
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    printf("thread id : %d\n", id); 
    __syncthreads();
    in_neighbours[id] = (graph[id * vertex[0] + node[0]] == 1);
}

int main() {
    int edges, vertices;
    scanf("%d%d", &vertices, &edges);
    
    int graphSize = vertices * vertices;
    printf("edges : %d \t vertices : %d\n",edges, vertices);
    printf("graph size : %d\n", graphSize);
    int Graph[graphSize] = {0};
    
    for(int i = 0; i < edges; i++) {
        int a, b;
        scanf("%d%d", &a, &b);
        Graph[a * vertices + b] = 1;
    }

    printf("graph : \n");
    see(Graph, vertices);
    
    int *device_graph;
    cudaMalloc(&device_graph, sizeof(int) * graphSize);
    cudaMemcpy(device_graph, Graph, sizeof(int) * graphSize, cudaMemcpyHostToDevice);
        
    int *device_vertices;
    int v[1] = {vertices};
    cudaMalloc(&device_vertices, sizeof(int));
    cudaMemcpy(device_vertices, v, sizeof(int), cudaMemcpyHostToDevice); 

    int in_neighbours[vertices] = {0};
    int *device_in_neighbours;
    cudaMalloc(&device_in_neighbours, sizeof(int) * vertices);
    cudaMemcpy(device_in_neighbours, in_neighbours, sizeof(int) * vertices, cudaMemcpyHostToDevice);

    int index[1] = {0};
    int *device_index;
    cudaMalloc(&device_index, sizeof(int));
    cudaMemcpy(device_index, index, sizeof(int), cudaMemcpyHostToDevice);
        
    int node[1];
    printf("enter the node for which to calculate in-neighbours: ");
    scanf("%d",&node[0]);
    printf("node entered : %d\n", node[0]);
    int *device_node;
    cudaMalloc(&device_node, sizeof(int));
    cudaMemcpy(device_node, node, sizeof(int), cudaMemcpyHostToDevice);
    
    int n_threads = vertices;
    printf("kernel call\n");
    kernel <<<1, n_threads>>> (device_graph, device_in_neighbours, device_node, device_index, device_vertices);
    cudaMemcpy(in_neighbours, device_in_neighbours, sizeof(int) * vertices, cudaMemcpyDeviceToHost);
    
    for(int i = 0; i < sizeof(in_neighbours)/sizeof(int); i++) {
        printf("%d ",in_neighbours[i]); 
    }printf("\n"); 
    return 0;
}
