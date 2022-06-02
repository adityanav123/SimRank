#ifndef INCLUDE_FILES

#define INCLUDE_FILES

#include <iostream>
#include <vector>
#include <unordered_map>
#include <algorithm>

#include <fstream>

#include <math.h>
#include <cassert>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <climits>
//#include "../extra/logs.cpp"
#include "./array_operations.hpp"
#include "./cuda_operations.cuh"

using namespace std;


const string DATA_FOLDER = "./data/";
const string DATASET_FOLDER= DATA_FOLDER + "datasets/";
const string STORE_TIME_IN = "./";



// CUDA PARAMETERS
int deviceId;
int noOfSMs;

void _fileIO(int ip, int op) {
	if (ip==1) {
		freopen ("./data/input.txt", "r", stdin);
	}
	if (op==1) {
		freopen ("./data/output.txt", "w", stdout);
	}
}



#endif
