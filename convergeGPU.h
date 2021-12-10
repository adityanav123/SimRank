#include <bits/stdc++.h>
using namespace std;
/*
#define matrix_INT vector<vector<int>>
#define matrix_DOUBLE vector<vector<double>>
#define ROW_INT vector<int>
#define ROW_DOUBLE vector<double>
*/

double l2Norm(double* mtx, int V) {
   double sum = 0.0;
   for(int i = 0; i < V; i++) {
      for(int j = 0; j < V; j++) {
          sum += pow(mtx[i*V+j],2);
      } 
   }
    //return sqrt(sum);
    return sqrt(sum);
}

double l1Norm(double* mtx, int V) {
    double l1norm=0.00;
    for(int i = 0; i < V; i++) {
        for(int j = 0; j < V; j++) {
            l1norm += mtx[i * V + j];
        }
    }
    return l1norm; 
    // compare these values for convergence ; precision to 10e-5.
}

void storeL2Norm(double* mtx, int V) {
    ofstream saveNorm;
    saveNorm.open("l2_norms_values.txt", ios::app);
    double normValue = l2Norm(mtx, V);
    saveNorm << normValue << " ";
    saveNorm.close();
}

void storel1Norm(double* mtx, int V) {
    ofstream saveNorm;
    saveNorm.open("l1_norms_values.txt", ios::app);
    double normValue = l1Norm(mtx,V);
    saveNorm << normValue << " ";
    saveNorm.close();
}

bool checkConvergence(double* mtx, int V, double *previousNormValue) {
    double currentNormValue = l1Norm(mtx, V);
    double T = *previousNormValue;

    *previousNormValue = currentNormValue;

    if (double(currentNormValue - T) < 0.0001)
        return true;
    else return false;

}
