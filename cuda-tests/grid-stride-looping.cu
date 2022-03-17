#include <stdio.h>
#define N 100
#define SIZE_INT sizeof(int)
#define SIZE (SIZE_INT * N)


__global__
void kernel (int *a, int *b, int size) {
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    int gridStride = gridDim.x * blockDim.x;
    for (int i = id; i < size; i+=gridStride) {
        b[i] = a[i];
    }
    // __syncthreads();
}


int main() {
    #ifndef ONLINE_JUDGE
        freopen("input.txt", "r", stdin);
    #endif
    int *a;
    int *b;
    cudaMallocManaged(&a, SIZE);
    cudaMallocManaged(&b, SIZE);

    for (int i = 0; i < N; i++) {
        a[i] = N - i + 1;
    }

    int device;
    cudaGetDevice(&device);

    int noOfSMs;
    cudaDeviceGetAttribute(&noOfSMs, cudaDevAttrMultiProcessorCount, device);

    printf("no of sm : %d\n", noOfSMs);

    kernel <<< 32 * noOfSMs, 1 >>> (a, b, N);
    cudaDeviceSynchronize();

    printf("a : ");
    for (int i = 0; i < N; i++)
        printf("%d ", a[i]);
    printf("\n\nb : ");
    for (int i = 0; i < N; i++) {
        printf("%d ", b[i]);
    }

    return 0;
}