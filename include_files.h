#include <iostream>
#include <vector>
#include <unordered_map>
#include <algorithm>
#include "convergeGPU.h"
#include <fstream>

#include <cstdlib>
#include <cstdio>

#include "array_operations.h"

#define d_ for(int i = 0; i < 1000000; i++)
#define matrix_INT vector<vector<int>>
#define matrix_DOUBLE vector<vector<double>>
#define ROW_INT vector<int>
#define ROW_DOUBLE vector<double>


const string DATASET_FOLDER = "./tests/datasets/";