#include <stdio.h>

__global__ void kernel2(int a) {
    printf("%d\n",a);
}

__global__ void kernel () {
    int a = 2;
    kernel2 <<< 1, 1 >>> (a);
}

int main(){
    kernel <<< 1, 1 >>> ();
    cudaDeviceSynchronize();
    return 0;
}
