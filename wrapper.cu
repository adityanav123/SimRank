#include <stdio.h>
__global__
void kernel () {
    printf("Thread[%d] Run.\n", threadIdx.x);
}


void callKernel (int n) {
    kernel <<< 1, n >>> ();
    cudaDeviceSynchronize();
}
