#include <iostream>

extern void callKernel (int N_THREADS);

int main() {
    callKernel(2);
    return 0;
}