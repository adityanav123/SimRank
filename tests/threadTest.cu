#include <stdio.h>

__managed__ int store;

__global__
void kernel (int *a) {
    int id = threadIdx.x + (blockIdx.x * blockDim.x);
    a[0] += id;
    __syncthreads();
    printf("current thread : %d\ta[0]=%d\n",id,a[0]);
}

__global__
void blockReduction (int *a, int *ans) {
    int id = threadIdx.x + (blockIdx.x * blockDim.x);
    int tid = threadIdx.x;

    extern __shared__ int s[];
    s[tid] = a[id];
    __syncthreads();



}


// Thrust :: reduce.

int main() {

    int s[1] = {0};
    int *d_s;

    cudaMalloc(&d_s, sizeof(int) * 1);
    cudaMemcpy(d_s, s, sizeof(int) * 1, cudaMemcpyHostToDevice);

    kernel <<< 2, 3 >>> (d_s);
    cudaDeviceSynchronize();

    cudaMemcpy(s, d_s, sizeof(int) * 1, cudaMemcpyDeviceToHost);

    printf("%d\n", s[0]);
    return 0;
}
