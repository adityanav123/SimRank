#include <stdio.h>
#define N 50
#define SIZE sizeof(int) * N
#define print(a) printf("%d ", a)
#define nl printf("\n")

__global__ void kernel3 (int *a) {
    int id = threadIdx.x;
    a[id] = id * 10;

    printf("kernel3()! \t a[%d] : %d\n", id, a[id]);

}

__global__ void kernel2 (int *a) {
    int id = threadIdx.x;
    a[id] = id + 1;

    printf("kernel2()! \t a[%d] : %d\n", id, a[id]);
}

__global__ void kernel1 (int *a, int M) {
    __syncthreads(); // block level synchronization
    int id = threadIdx.x;
    if (id == 0) {
        // printf ("current thread : %d\n", id);
        kernel2 <<< 1, M >>> (a);
        cudaDeviceSynchronize();
        // printf("\n===================\n");
    }
    __syncthreads();
    if (id == 1) {
        // printf("current thread : %d\n", id);
        kernel3 <<< 1, M >>> (a);
        cudaDeviceSynchronize();
    }
    __syncthreads();
}

int main() {
    int *a;
    cudaMallocManaged(&a, SIZE); // stored in unified.
    // printf("original : ");
    // for (int i = 0; i < N; i++) {
    //     print(a[i]);
    // }nl;
    kernel1 <<< 1 , N >>> (a, N);
    cudaDeviceSynchronize();
    // printf("after kernel call! : ");
    // for(int i = 0; i < N; i++) {
    //     print(a[i]);
    // }nl;
    return 0;
}