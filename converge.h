#include <bits/stdc++.h>
using namespace std;
#define matrix_INT vector<vector<int>>
#define matrix_DOUBLE vector<vector<double>>
#define ROW_INT vector<int>
#define ROW_DOUBLE vector<double>

double l2Norm(matrix_DOUBLE mtx) {
   double sum = 0.0;
   for(auto x : mtx) {
        for(auto y : x) {
            sum += pow(y, 2);
        }
   }
    
   return sqrt(sum);
}

inline bool checkConvergence(vector<matrix_DOUBLE> SimRank, double confidence_value, int iterations) {
    int N = SimRank.size();
    if(N <= 15) return false;
    //cout << "iterations completed : " << N << "\n";
   // matrix_DOUBLE t1(SimRank[N-1]), t2(SimRank[N-2]);
    double t1_l1Norm = l2Norm(SimRank[N-1]);
    double t2_l1Norm = l2Norm(SimRank[N-2]);
    //cout << "Norms Calculated \n";
    //cout << "t1: " << t1_l1Norm << " & t2: " << t2_l1Norm << "\n";
    double thresholdValue = (double)pow(confidence_value, 1000);
    //cout << "Threshold Value: " << thresholdValue << "\n";
    if(t1_l1Norm == t2_l1Norm) {
       return true;
    }
    return false;
}
