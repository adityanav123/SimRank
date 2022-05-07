#include <bits/stdc++.h>

using namespace std;

int main() {
    int n;
    cout << "enter count of vertices : ";
    cin >> n;

    int noOfPairs = n * n;

    int *arr;
    arr = (int*) calloc(2 * noOfPairs, sizeof(int));

    for (int i = 0; i < noOfPairs; i++) {
        int from = i / n;
        int to = i % n;
        arr[i * 2 + 0] = from;
        arr[i * 2 + 1] = to;
    }

    printf("pairs : \n");
    for (int i = 0; i < noOfPairs; i++) {
        printf("%d %d\n", arr[i * 2 + 0], arr[i * 2 + 1]);
    }
    printf("\n");

    return 0;
}
