#include <ctime>
#include <stdio.h>
#include <fstream>

int* readGraph(int *v, int *e) {
    std::ifstream file ("./input.txt");
    file >> *v;
    file >> *e;
    
    int *graph, vert = *v;
    cudaMallocManaged(&graph, sizeof(int) * (vert * vert));
    int cnt = *e;
    while (cnt--) {
        int from, to;
        file >> from;
        file >> to;
        graph[from * vert + to] = 1;
    }
    return graph;
}

void see(int *graph, int n) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            printf("%d ", graph[i * n + j]);
        }printf("\n");
    }
}

__device__ int countIn_A, countIn_B;

__global__ 
void calculateInNeighbours (int *graph, int size, int *in_neighbours, int node, int* count) {
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    for (int i = id; i < size; i += (gridDim.x * blockDim.x)) {
        in_neighbours[i] = graph[i * size + node];
        countIn_A += (in_neighbours[i] == 1);
    }
    // __syncthreads();

}

void CPUInNeighbour (int *graph, int size, int node, int *in_neighbours) {
    for (int i = 0; i < size; i++) {
        in_neighbours[i] = graph[i * size + node];
    }
}

int main() {
    int vert,edges;
    int *graph = readGraph(&vert, &edges);
    // printf("graph : \n");
    // see(graph, vert);
    printf("nodes ranges from 0 to %d\n", vert);
    // int node;
    // printf("calculating in-neighbours for node : ");
    // scanf("%d", &node);

    int node;
    std::ifstream fileptr("./test.txt");
    fileptr >> node;
    printf("node choosen : %d\n", node);
    int *in_neighbours;
    cudaMallocManaged(&in_neighbours, sizeof(int) * vert);

    int deviceId;
    cudaGetDevice(&deviceId);
    int noOfSms;
    cudaDeviceGetAttribute(&noOfSms, cudaDevAttrMultiProcessorCount, deviceId);
    int *count;
    cudaMallocManaged(&count, sizeof(int));

    float start, end;
    start = clock();
    calculateInNeighbours <<< 32 * noOfSms, 1023 >>> (graph, vert, in_neighbours, node, count);
    end = clock();
    cudaDeviceSynchronize();
    // end = clock();

    int *in_neigh2;
    cudaMallocManaged(&in_neigh2, sizeof(int) *vert);

    float start2, end2;
    start2 = clock();
    CPUInNeighbour(graph, vert, node, in_neigh2);
    end2 = clock();

    float time_ = (float)(end2 - start2) / CLOCKS_PER_SEC;
    float gputime_ = (float)(end - start) / CLOCKS_PER_SEC;

    // printf("in-Neighbours [GPU] : ");
    // for (int i = 0; i <vert; i++) {
    //     printf("%d ", in_neighbours[i]);
    // }printf("\n");

    // printf("in-Neighbours [CPU] : ");
    // for (int i = 0; i <vert; i++) {
    //     printf("%d ", in_neigh2[i]);
    // }printf("\n");

    std::ofstream cputime ("./CPU_Time.txt", std::ios::app);
    std::ofstream gputime ("./GPU_Time.txt", std::ios::app);



    // printf("time [GPU] : %lf\n",(float)(end - start) / CLOCKS_PER_SEC);
    // printf( "time [CPU] : %lf\n", time_);

    cputime << time_ << " ";
    gputime << gputime_ << " ";



    return 0;
}