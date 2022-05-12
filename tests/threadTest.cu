#include <stdio.h>

__managed__ int store;

__global__
void kernel (int *a) {
    int id = threadIdx.x + (blockIdx.x * blockDim.x);
    a[0] += id;
    __syncthreads();
    printf("current thread : %d\ta[0]=%d\n",id,a[0]);
}

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
