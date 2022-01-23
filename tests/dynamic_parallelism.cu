#include <stdio.h>
#define N 5
#define nl printf("\n")

__global__ void kernel2 (int *a) {
    printf("child kernel!\n");
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    printf("[child]blockId : %d\n", blockIdx.x);
    a[id] = 24;
}

__global__ void kernel (int *a) {
    nl;
    printf("parent kernel!\n");
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    
    a[id] = id + 245;

    // current array 
    printf("current array : ");
    for (int i = 0; i < N; i++) {
        printf("%d ", a[i]);
    }nl;

    //dim3 gridDimension (N, N, 1); // x = N , y = N , z = 1

    // cuda dynamic parallelism
    kernel2 <<< N, 1 >>> (a); // 1024 * 23

    //printf("kernel2() executed!\n");   
}

void print (int *a, int n) {
    for (int i = 0; i < n; i++) {
        printf("%d ", a[i]);
    }
    nl;
}

int main() {
    int *a;
    int size = sizeof(int) * N;
    cudaMallocManaged (&a, size);
    for (int i = 0; i < N; i++) {
        a[i] = i + 1;
    }

    printf("original : ");
    print(a, N);

    int deviceId;
    cudaGetDevice(&deviceId);
    
    cudaMemPrefetchAsync(a, size, deviceId);

    /* KERNEL CALL */
    kernel <<< 1, 1 >>> (a);
    cudaDeviceSynchronize();
    nl;
    printf("converted array : ");   print(a, N);


    cudaFree(a);
    return 0;
}

