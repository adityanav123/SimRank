#include <stdio.h>
#include <stdlib.h>
#define N 5

__global__ void kernel(int *arr, int *pos1, int *pos2, int* summation) {
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    atomicAdd(&summation[0], arr[pos1[id] * N + pos2[id]]);
}

int main(){
    int a[N*N];
    for(int i = 0; i < N;i++) {
        for(int j = 0; j < N; j++) {
            a[i*N+j] = rand() % N;
        }
    }

    printf("array generated : \n");
    for(int i = 0; i < N; i++) {
        for(int j = 0; j < N; j++) {
            printf("%d ", a[i*N+j]);
        }printf("\n");
    }

    int pos1[4], pos2[4];
    for(int i = 0; i < 4; i++) {
        pos1[i] = rand() % N;
        pos2[i] = rand() % N;
    }

    printf(" new points : \n");
    for(int i = 0; i < 4; i++) {
        printf("%d\t%d\n", pos1[i], pos2[i]);
    }
    
    int* d_a, *d_pos1, *d_pos2;
    cudaMalloc(&d_a, sizeof(int) * N * N);
    cudaMalloc(&d_pos1, sizeof(int) * 4);
    cudaMalloc(&d_pos2, sizeof(int) * 4);

    cudaMemcpy(d_a, a, sizeof(int) * N * N, cudaMemcpyHostToDevice);
    cudaMemcpy(d_pos1, pos1, sizeof(int) * 4, cudaMemcpyHostToDevice);
    cudaMemcpy(d_pos2, pos2, sizeof(int) * 4, cudaMemcpyHostToDevice);
    
    int sum[1]; sum[0]=0;
    int* d_sum;
    cudaMalloc(&d_sum, sizeof(int));
    cudaMemcpy(d_sum, sum, sizeof(int), cudaMemcpyHostToDevice);

    kernel<<<4,4>>>(d_a, d_pos1, d_pos2, d_sum);

    cudaMemcpy(sum, d_sum, sizeof(int), cudaMemcpyDeviceToHost);

    printf("\nsummation : %d\n", sum[0]);
    
    return 0;
}
