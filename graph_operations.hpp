#ifndef GRAPH_OP_H

#define GRAPH_OP_H
#include <fstream>
#include <iostream>
#include <vector>
#include <unordered_map>
#include <unordered_set>
#include <string>
using namespace std;

template <typename T>
inline void seeGraph(T *graph, int size) {
    for (int i = 0; i < size; ++i) {
        for (int j = 0; j < size; j++) {
            cout << graph[i * size + j] << " ";
        }cout << "\n";
    }
}
template <typename T>
inline void initGraph (T *graph, int size, T initval) {
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            graph[i * size + j] = initval;
        }
    }
}

inline void TakeSimRankConfigurationInput (int &maxIterations, double &c_value) {
    cout << "Enter max no of iterations to be run. [for default(1000), enter -1] : \n";
    scanf("%d", &maxIterations);
    cout << "Enter Confidence Value to be used : [for default(0.9), enter -1] : \n";
    scanf ("%lf", &c_value);
    if(maxIterations == -1) maxIterations = 1000;
    if(c_value == -1) c_value = 0.9;

    cout << "\nSimRank Configuration : \n\tIterations : " << maxIterations 
        << "\n\tConfidence Value : " << c_value << "\n";
}



#endif
