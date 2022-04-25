#include <stdio.h>

__global__
void kernel (int n) {
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    int gridStride = blockDim.x * gridDim.x;
    for (int i = id; i < n * n; i+=gridStride) {
        int from, to; 
        from = id % n;
        to = id / n;
        printf ("pair : (%d, %d)\n", from, to);
    }
    
}

int main() {
    freopen64 ("output.txt", "w", stdout);
    int n = 5; // pair of (0 to 5)
    int Block_ = n * n;
    int Thread_ = 1;

    kernel <<< Block_, Thread_ >>> (n);
    cudaDeviceSynchronize();

    return 0;
}