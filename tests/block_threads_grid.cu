#include <stdio.h>

__global__ void kernel () {
   int  
}

int main(){
    dim3 blockSize = (2, 2, 2);
    dim3 gridSize = (1, 1, 2);
    kernel <<< gridSize, blockSize >>> ();
    cudaDeviceSynchronize();

    return 0;
}
