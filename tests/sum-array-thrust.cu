#include <stdio.h>
#include <thrust/scan.h>

int main() {
    int arr[] = {5, 1, 6, 2};
    int size = sizeof(arr) / sizeof(int);
    printf("size :%d\n", size);

    int *device_arr;
    cudaMalloc(&device_arr, 
}
