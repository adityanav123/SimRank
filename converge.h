#include <bits/stdc++.h>
using namespace std;
#define matrix_INT vector<vector<int>>
#define matrix_DOUBLE vector<vector<double>>
#define ROW_INT vector<int>
#define ROW_DOUBLE vector<double>

double l2Norm(ROW_DOUBLE mtx, int V) {
   double sum = 0.0;
   for(int i = 0; i < V; i++) {
      for(int j = 0; j < V; j++) {
          sum += pow(mtx[i*V+j],2);
      } 
   }
    //return sqrt(sum);
    return sqrt(sum);
}

double l1Norm(ROW_DOUBLE mtx, int V) {
    double l1norm=0.00;
    for(int i = 0; i < V; i++) {
        for(int j = 0; j < V; j++) {
            l1norm += mtx[i * V + j];
        }
    }
    return l1norm; 
    // compare these values ; for convergence , precision to 10e-5.
}

void storeL2Norm(ROW_DOUBLE mtx, int V) {
    ofstream saveNorm;
    saveNorm.open("l2_norms_values.txt", ios::app);
    double normValue = l2Norm(mtx, V);
    saveNorm << normValue << " ";
    saveNorm.close();
}

void storel1Norm(ROW_DOUBLE mtx, int V) {
    ofstream saveNorm;
    saveNorm.open("l1_norms_values.txt", ios::app);
    double normValue = l1Norm(mtx,V);
    saveNorm << normValue << " ";
    saveNorm.close();
}

inline bool checkConvergence(ROW_DOUBLE simrankMatrix, int noOfVertices, int iterationValue, double previousIterationL1Norm) {
    // operations
    // 10e-5 --> precision.
    //
    // k - 1 --> l1 norm for k-1 iterations.
    // k --> calculate
    // k and k-1 compare.
    //
    // if equal then return true.
}


/*
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
}*/
