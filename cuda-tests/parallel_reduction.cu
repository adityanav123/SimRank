#include <ctime>
#include <stdio.h>
// #include <math.h>
#include <fstream>
using namespace std;
#define ll long long
#define ull unsigned long long
__global__ 
void kernel (ull *a, int n) {
    int fid = threadIdx.x + blockDim.x * blockIdx.x, tid = threadIdx.x;
    // printf ("current thread[%d]\n", tid);
    for (ull s = blockDim.x / 2; s > 0; s >>= 1) {
        if (tid < s) {
            a[fid] += a[fid + s];
        }
        __syncthreads();
    }

    if (tid == 0) {
        a[blockIdx.x] = a[fid];
    }

}

ull cpukernel (ull *a, int n) {
    ull sum = 0;
    for (ull i = 0; i < n; i++)
        sum += a[i];
    return sum;
}


int main() {
   #ifndef ONLINE_JUDGE
    freopen("test.txt", "r", stdin); 
   #endif

    ull n;
    scanf ("%llu", &n);
    ull *a;
    cudaMallocManaged (&a, sizeof(ull) * n);
    // int size = sizeof(a) / sizeof(int);
    for (ull i = 0; i < n; ++i) {
        a[i] = i + 1;
    }
    // printf("original : ");
    // for (int i = 0; i < n; i++) printf("%d ", a[i]);
    
    // 32 blocks of 32 threads.

    float start,end;
    // cpu call
    start = clock();
    ull result = cpukernel(a, n);
    end = clock();
    
    float timeCPU = (float) (end - start) / CLOCKS_PER_SEC;

    start = clock();
    kernel <<< 1024, 1024 >>> (a, n);
    kernel <<< 1, 1024 >>> (a, n);
    end = clock();
    cudaDeviceSynchronize();

    float timeGPU = (float) (end - start) / CLOCKS_PER_SEC;    

    // printf("after reduction : ");
    // for (int i = 0; i < n; i++) printf("%d ", a[i]);


    ofstream filePtr("./CPU_Time.txt", std::ios::app);
    ofstream filePtr_ ("./GPU_Time.txt", std::ios::app);

    printf("\nTime elapsed[CPU] : %lf\n", timeCPU);
    printf("\nTime elapsed[GPU] : %lf\n", timeGPU);
    printf("%llu\n", a[0]);

    filePtr << timeCPU << " ";
    filePtr_ << timeGPU << " ";

    filePtr.close();
    filePtr_.close();
    return 0;
}