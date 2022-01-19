#include <stdio.h>

__global__ void kernel () {
    if(threadIdx.x % 2 == 0)
        return;
    printf("thread : %d\n", threadIdx.x);
}

int main() {
    kernel <<< 1, 4 >>> ();
    cudaDeviceSynchronize();
    return 0;
}
