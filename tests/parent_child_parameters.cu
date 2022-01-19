#include <stdio.h>
#define N 10
#define newline printf("\n")

__global__ void kernel2 (int *device_a) {
   int id = threadIdx.x;
   device_a[id] = 10; 
}

__global__ void kernel (int *device_a) {
    int id = threadIdx.x;
    printf("original : ");
    for (int i = 0; i < N; i++) {
        printf("%d ", device_a[i]);
    }newline;

    printf("kernel2()\n");
    kernel2 <<< 1, N >>> (device_a); // child kernel
    cudaDeviceSynchronize();

    printf("after updating: ");
    for (int i = 0; i < N; i++) {
        printf("%d ", device_a[i]);
    }newline;

}

int main() {
    int a[N];
    for (int i = 0; i < N; i++) a[i] = -1; 
    int *device_a;
    cudaMalloc(&device_a, sizeof(int) * N);
    cudaMemcpy(device_a, a, sizeof(int) * N, cudaMemcpyHostToDevice);
     
    kernel <<< 1, 1 >>> (device_a);
    cudaMemcpy (a, device_a, sizeof(int) * N, cudaMemcpyDeviceToHost);

    return 0;
}
