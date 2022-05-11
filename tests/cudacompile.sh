#!/bin/bash

file_=$1
nvcc -arch=sm_75 -rdc=true -D__CDPRT_SUPPRESS_SYNC_DEPRECATION_WARNING $file_
./a.out
