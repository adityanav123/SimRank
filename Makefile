CUDA_FLAGS=-arch=sm_75 -rdc=true
CFLAG= -std=c++17 -Wall -c

all: simrank.o
simrank.o:
	nvcc $(CUDA_FLAGS) SimRank_GPU_new.cu -o SimRank_GPU_new

