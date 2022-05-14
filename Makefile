CUDA_FLAGS=-arch=sm_75 -rdc=true -D__CDPRT_SUPPRESS_SYNC_DEPRECATION_WARNING
CFLAG= -std=c++17 -Wall

all: simrank.o
simrank.o:
	nvcc $(CUDA_FLAGS) SimRank_GPU_new.cu -o gpu-simrank
