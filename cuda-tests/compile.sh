#!/bin/bash

g++ -o test -L/opt/cuda/lib64 -lcuda -lcudart test.cpp wrapper.o