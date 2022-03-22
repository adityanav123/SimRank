#ifndef INCLUDE_FILES_H
#define INCLUDE_FILES_H


#include <iostream>
#include <vector>
#include <unordered_map>
#include <algorithm>
#include "convergeGPU.h"
#include <fstream>
#include <math.h>

#include <cstdlib>
#include <cstdio>

#include "array_operations.h"
#include "graph_operations.hpp"

#define dly(a) for(int i = 0; i < a; i++)
#define matrix_INT vector<vector<int>>
#define matrix_DOUBLE vector<vector<double>>
#define ROW_INT vector<int>
#define ROW_DOUBLE vector<double>


const string DATASET_FOLDER = "./tests/datasets/";
const string TIME_STORE_FOLDER = "./";
const int defaultMaxIterations = 1000;
const double defaultConfidenceValue = 0.9;

using namespace std;

#endif