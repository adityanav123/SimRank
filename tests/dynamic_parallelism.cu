#include <stdio.h>
#define N 5


__global__ void kernel2 (int *a) {
    printf("[blockIdx.x]%d [gridDim.x]%d [threadIdx.x]%d\n",blockIdx.x, gridDim.x, threadIdx.x);
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    printf("[kernel2()]id : %d\n", id);
    __syncthreads();

    a[id] = 24;
}

__global__ void kernel (int *a) {
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    __syncthreads();
    printf("[kernel()]id : %d\n", id);
    a[id] = id + 1; 
    
    dim3 gridDimension (N, N, 1); // x = N , y = N , z = 1

    // cuda dynamic parallelism
    kernel2 <<<gridDimension, 1>>> (a); // 1024 * 23

    //printf("kernel2() executed!\n");   
}

int main() {
    int a[N];
    for(int i = 0; i < N; i++)
        a[i] = i + 1;

    int *device_a;
    cudaMalloc(&device_a, sizeof(int) * N);
    cudaMemcpy(device_a, a, sizeof(int) * N, cudaMemcpyHostToDevice);
    kernel <<< 1, 1 >>> (device_a);
    //cudaDeviceSynchronize();
    cudaMemcpy(a, device_a, sizeof(int) * N, cudaMemcpyDeviceToHost);
    cudaFree(device_a);
    printf("\n");
    for(int i = 0; i < N; i++) {
        printf("%d ", a[i]);
    }
    printf("\n");
    return 0;
}

