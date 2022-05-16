#!/bin/bash

nvprof -o ./profiling/gpu_profiling.nvprof ./gpu-simrank
echo "saved in ./profiling/gpu_profiling.nvprof"
