#include <iostream>

using namespace std;

extern void callKernel (int N_THREADS);

int main() {
    callKernel(4);
    return 0;
}

