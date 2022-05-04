#include<stdio.h>
#define N 10

__global__ void kernel (double* arr, double* sum) {
    int id = threadIdx.x;
    atomicAdd(&sum[0], arr[id]);
}

int main() {
    double arr[N];
    double* d_arr;
    for(int i = 0; i < N; i++)
        arr[i] = 11.0;

    double sum[1]; sum[0] = 0.0;
    double* d_sum;

    cudaMalloc(&d_sum, sizeof(double));
    cudaMemcpy(d_sum, sum, sizeof(double), cudaMemcpyHostToDevice);

    cudaMalloc(&d_arr, sizeof(double) * N);
    cudaMemcpy(d_arr, arr, sizeof(double) * N, cudaMemcpyHostToDevice);

    kernel<<<1, N>>>(d_arr, d_sum);
    
    cudaMemcpy(sum, d_sum, sizeof(double), cudaMemcpyDeviceToHost);
    cudaMemcpy(arr, d_arr, sizeof(double) * N, cudaMemcpyDeviceToHost);
    
    printf("arr : \n");
    for(int i=0;i<N;i++) {
        printf("%lf ", arr[i]);
    }
    printf("\nsummation : %lf\n", sum[0]);

    return 0; 
}
