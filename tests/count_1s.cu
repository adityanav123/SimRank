#include <thrust/count.h>
__device__ int hh;
__global__ void print (int *a) {
    int id = threadIdx.x;
    a[id] = id + 1;
    hh += id + 1;

    __syncthreads();
}


__global__ void kernel () {
    int *a;
    //a = new int[5];
    a = (int*) malloc(sizeof(int) * 5);
    hh = 0;
    
    int size = 5;


    printf("array created !\n");
    print <<< 1, size >>> (a);
    for(int i = 0; i < size; i++) {
        printf("%d ", a[i]);
    }
    printf("\nh : %d\n", hh);
    __syncthreads();
}

int main(){ 
    int arr[] = {0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0};
    int size = sizeof(arr) / sizeof(int);
    
    kernel <<< 1, 1 >>> ();
    cudaDeviceSynchronize();
    return 0; 
}
