#include <stdio.h>

__managed__ int ThreadCount_, BlockCount_;


__global__ 
void kernel (int *a, int size) {
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    if (id < size * size) {
        int from, to;
        from = id % size;
        to = id / size;
        printf("pair : (%d, %d) -> %d\n", from, to, a[from * size + to]);
    }
}

int main() {
    int size = 3;
    int *a; // 3 x 3 matrix;
    cudaMallocManaged(&a, sizeof(int) * size * size);

    for (int i = 0; i < size * size; i++) a[i] = i + 1;

    ThreadCount_ = 10;
    BlockCount_ = 1;

    kernel <<< BlockCount_, ThreadCount_ >>> (a, size);
    cudaDeviceSynchronize();
    return 0;
}