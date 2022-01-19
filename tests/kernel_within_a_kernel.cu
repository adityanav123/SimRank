#include <stdio.h>

__global__ void kernel2 () {
    printf("kernel2() called!\n");
}

__global__ void kernel1 () {
    printf("kernel1() called!\n");
    kernel2 <<< 1, 2 >>> ();
    printf("kernel2() returned!\n");
}

int main() {
    kernel1 <<< 1, 1 >>> ();
    cudaDeviceSynchronize();
    return 0;    
}
