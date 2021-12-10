#include <stdio.h>
#define N 10000
#define intu unsigned int

__global__ void kernel(intu* arr, intu* s) {
    __shared__ intu t;
   if(threadIdx.x == 0) t = 0;
    t += arr[threadIdx.x];
    __syncthreads();
    if(threadIdx.x == N-1)
        s[0] = t;
}

#define blockSize 1
__global__ void sumCommSingleBlock(const intu *a, intu *out) {
    intu idx = threadIdx.x;
    intu sum = 0;
    for (intu i = idx; i < N; i += blockSize)
        sum += a[i];
    __shared__ intu r[blockSize];
    r[idx] = sum;
    __syncthreads();
    for (intu size = blockSize/2; size>0; size/=2) { //uniform
        if (idx<size)
            r[idx] += r[idx+size];
        __syncthreads();
    }
    if (idx == 0)
        *out = r[0];
}
int main() {
    intu a[N];
    for(int i = 0; i < N; i++) a[i] = 1;
    intu* d_a;
    cudaMalloc(&d_a, sizeof(intu)*N);
    cudaMemcpy(d_a,a,sizeof(intu)*N, cudaMemcpyHostToDevice);
    intu sum[1]; sum[0] = 0;
    intu *d_sum;
    cudaMalloc(&d_sum, sizeof(intu));
    cudaMemcpy(d_sum, sum, sizeof(intu), cudaMemcpyHostToDevice);
    //kernel<<<1,N>>>(d_a, d_sum);
    sumCommSingleBlock(d_a, d_sum);
    cudaMemcpy(sum, d_sum, sizeof(int), cudaMemcpyDeviceToHost); 
    printf("summation : %d\n", sum[0]);
    return 0;
}
