#include <stdio.h>



__global__ void sum (int *arr, int *sum, int *size){
    int id = threadIdx.x;
    int result = 0;
    kernel2 <<< 1, size[0] >>> (arr, result);
    __syncthreads();
    sum[0] = result;
}

int main() {
    int arr[] = {0, 1, 1, 0};
    int size = sizeof(arr) / sizeof(int);

    int *device_arr;
    cudaMalloc(&device_arr, sizeof(int) * size);
    cudaMemcpy(device_arr, arr, sizeof(int) * size, cudaMemcpyHostToDevice);
    
    int *device_size;
    int s[1] = {size};
    cudaMalloc(&device_size, sizeof(int)); 
    cudaMemcpy(device_size, s, sizeof(int), cudaMemcpyHostToDevice);

    int v[1] = {0};
    int *device_v;
    cudaMalloc(&device_v, sizeof(int));
    cudaMemcpy(device_v, v, sizeof(int), cudaMemcpyHostToDevice);

    sum <<< 1, 1 >>> (device_arr, device_v, device_size);
    cudaMemcpy(v, device_v, sizeof(int), cudaMemcpyDeviceToHost);
        
    printf("sum : %d \n", v[0]);

    return 0;
}
