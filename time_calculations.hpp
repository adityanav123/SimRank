#ifndef STORE_TIME_H
#define STORE_TIME_H
#include "include_files.h"
using namespace std;

template <typename T>
void storeCPUTime (T time_, string mode) {
    fstream filePtr;
    if (mode == "CPU")
        filePtr.open (TIME_STORE_FOLDER + "CPU_TIMES.txt");
    else
        filePtr.open (TIME_STORE_FOLDER + "GPU_TIMES.txt");
    filePtr << time_;
    filePtr.close();
}

#endif