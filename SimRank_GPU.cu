#include<bits/stdc++.h>
using namespace std;

int main() {
    kernel<<<1, 32>>>();
    cudaDeviceSynchronize();
    return 0; 
}
