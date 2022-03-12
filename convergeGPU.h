#ifndef CONVERGE_GPU_H

#define CONVERGE_GPU_H

#include <fstream>
#include <iostream>
#include <cmath>
#include <vector>
#include <cctype>
using namespace std;

double l2Norm(double* mtx, int V) {
   double sum = 0.0;
   for(int i = 0; i < V; i++) {
      for(int j = 0; j < V; j++) {
          sum += pow(mtx[i*V+j],2);
      } 
   }
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
// stores the L1 and L2 Norm.
void storeNorm(double* mtx, int V, string mode) {
    ofstream saveNorm;
    if(mode == "L2")
        saveNorm.open("l2_norms_values.txt", ios::app);
    else
        saveNorm.open("l1_norms_values.txt", ios::app);
    
    double normValue=0.0;
    
    if(mode == "L1")
        normValue = l1Norm(mtx,V);
    else
        normValue = l2Norm(mtx, V);
    
    saveNorm << normValue << " ";
    saveNorm.close();
}


bool checkConvergence(double* mtx, int V, double *previousNormValue) {
    // CONVERGENCE CRITERIA USED - L1 Norm.
    double currentNormValue = l1Norm(mtx, V);
    double T = *previousNormValue;

    *previousNormValue = currentNormValue;

    if (double(currentNormValue - T) < 0.0001)
        return true;
    else return false;
}


#endif