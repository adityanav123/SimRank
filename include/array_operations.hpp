#ifndef ARRAY_OPS_HPP
#define ARRAY_OPS_HPP
#include <fstream>
#include <iostream>
#include <vector>
#include <cctype>
using namespace std;
#define log(a) printf(a)
#define _lp_(i, a) for(i=0;i<a;i++)
#define _nl printf("\n")

const int defaultMaxIterations=1000;
const double defaultConfidenceValue=0.9;

template <typename t>
t* createArray(int size_m, t value=0) {
    t* tmp = (t*) malloc(sizeof(t) * size_m * size_m);
    for(int i=0;i<size_m;i++) {
        tmp[i] = value;
    }
    return tmp;
}

template <typename t>
void seeMatrix (t *graph, int size) {
	for (int i = 0; i < size; i++) {
		for (int j = 0; j < size; j++) {
			cout << graph[i * size + j] << " ";
		}_nl;
	}
}




// INT : INPUT GRAPH
// double : SIMRANK MATRIX


double L1Norm (double *matrix, int mtxSize) {
	double l1norm=0.0;
	for (int i = 0; i < mtxSize; i++) {
		for (int j = 0; j < mtxSize; j++) {
			l1norm += matrix[i * mtxSize + j];
		}
	}
	return l1norm;
}


void storeSimrankScore (double *matrix, int mtxSize) {
	ofstream saveNorm;
	saveNorm.open("./data/l1Norm.txt", ios::app);
	double normValue=0.0;
	
	normValue = L1Norm (matrix, mtxSize);
	saveNorm << normValue << " ";
	saveNorm.close();
}

inline bool converge (double *matrix, int mtxSize, double *previousNormValue) {
	double currNormValue = 0.0;
	currNormValue = L1Norm (matrix, mtxSize);
	
	*previousNormValue = currNormValue;

	double threshold = 0.00001;
	double diff = currNormValue - (*previousNormValue);
	return (diff < threshold);
}

void simrankConfigInput (int &maxIterations, double &confidence) {
	log("Enter max no. of iterations for simrank [for default (1000), enter -1] : \n");
	scanf ("%d", &maxIterations);
	log("Enter confidence value [for default(0.90), enter -1] : \n");
	scanf ("%lf",&confidence);
	
	// boundary check
	bool maxcheck, confcheck;
	maxcheck = ((maxIterations < 1000 && maxIterations > 1) | maxIterations == -1);
	confcheck = ((confidence < 1.0 && confidence > 0.0) | confidence == -1);
	assert (maxcheck & confcheck);
	
	if (maxIterations == -1) maxIterations = defaultMaxIterations;
	if (confidence == -1) confidence = defaultConfidenceValue;
	
	log ("\nSimRank Configuration Choosen : \n\tMaximum No. of Iterations : ");
	printf ("%d", maxIterations);
	log ("\n\tConfidence Value : ");
	printf ("%lf\n",confidence);
}



void debugInNeighbours (int *inNeighbours, int size) {
	int takeAnyNode = rand() % size;
	cout << "inneighbours for " << takeAnyNode << " : ";
	for (int i = 0; i < size; i++) {
		printf ("%d ", inNeighbours[takeAnyNode * (size + 1) + i]);
	}
	printf ("\n");
}

#endif



