#include <bits/stdc++.h>
#define N 10000

__global__ void prefixSum (int *arr, int *st) {
    int id = threadIdx.x;
    if(id > 0) {
        arr[id] += arr[id-st[0]];
    }
}

__global__ void atomicSummation (int *arr, int* sum) {
    int id = threadIdx.x;
    atomicAdd(&sum[0], arr[id]);
}

int main() {
    int arr[N];
    for(int i = 0; i < N; i++) arr[i] = i + 1;
    int *d_arr;
    printf("original array : ");
    for(int i = 0; i < N; i++) printf("%d ", arr[i]);
    printf("\n");
    cudaMalloc(&d_arr, sizeof(int)*N);
    cudaMemcpy(d_arr, arr, sizeof(int)*N, cudaMemcpyHostToDevice);
   
    clock_t start, end;
    double totalTime = 0.0;
    /* Method - 1 : prefix sum */
   /* printf("prefix sum: ");
    int limit = ceil(log(N) / log(2));
    //printf("log of %d: %d\n", N, limit);
    for(int i = 0; i < limit; i++) {
        int step = pow(2, i);
        int st[1]; st[0] = step;
        int *d_st;
        cudaMalloc(&d_st, sizeof(int));
        cudaMemcpy(d_st, st, sizeof(int), cudaMemcpyHostToDevice);
        //printf("step : %d\n", step);
        start = clock();
        prefixSum<<<1,N>>>(d_arr, d_st);
        end = clock();
        totalTime += (double) (end - start) / CLOCKS_PER_SEC;
        cudaDeviceSynchronize(); 
    }
    cudaMemcpy(arr, d_arr, sizeof(int)*N, cudaMemcpyDeviceToHost);
   // printf("prefix sum:\n");
    for(int i = 0; i < N; i++) printf("%d ", arr[i]);
    printf("\nSummation : %d\n",arr[N-1]);

    printf("Total Time : %lf\n",totalTime);
   */ 
    totalTime = 0.0;
    printf("\natomic operations\n");
    int sum[1]; sum[0] = 0;
    int* d_sum;
    cudaMalloc(&d_sum, sizeof(int));
    cudaMemcpy(d_sum, sum, sizeof(int), cudaMemcpyHostToDevice);
    start = clock();
    atomicSummation<<<1, N>>>(d_arr, d_sum);
    end = clock();
    totalTime += (double)(end - start) / CLOCKS_PER_SEC;
    cudaMemcpy(arr, d_arr, sizeof(int) * N, cudaMemcpyDeviceToHost);
    cudaMemcpy(sum, d_sum, sizeof(int), cudaMemcpyDeviceToHost);
   // printf("final array :");
    //for(int i = 0; i < N; i++) printf("%d ", arr[i]);
    printf("\nTotal Time %lf\n", totalTime);

    printf("\nFinal Summation : %d\n", sum[0]);
   return 0;
}
