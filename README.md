# GPU implementation of Simrank

SimRank is a general similarity measure, that says "two objects are considered to be similar if they are referenced by similar objects. In this project we are calculating SimRank
over a static graph and is defined as - "two objects are similar, if they reference to similar objects". This project Aims to improve SimRank's performance using CUDA, and using CUDA constructs
using parallel programming abstractions to improve computation time of the program with some other optimisations to improve the time complexity of the program.



# Compilation Instructions

## Compilation
    // if compute capability 'xx' (70 for 7.0, 65 for 6.5..etc)
    nvcc -arch=sm_xx SimRankGPU.cu -o SimRankGPU

## Execution
    /* to visualize convergence graphs */
    Un-comment the last line of the code.
        system("python numpy_test.py");

    /* To Execute */
    ./SimRankGPU

# Results & Analysis
    [Below graphs are Strogatz Graphs, generated randomly in python, code of which can be found in tests/ folder]
// All the timings are averaged over 10 executions and is in seconds.

##1 : For a graph having 17 Vertices and 26 Edges
    
    - CPU Time : 0.0493
    
    - GPU Time : 0.0024
    
    - Speed Up : 21.5

##2 : For a graph having 150 Vertices and 900 Edges
    
    - CPU Time : 1.0885
    
    - GPU Time : 0.1207
    
    - Speed Up : 9.018

##3 : For a graph having 400 Vertices and 2400 Edges
    
    - CPU Time : 18.6888
    
    - GPU Time : 0.3473
    
    - Speed Up : 51.03


The above given results are the averaged time of the SimRank CPU and GPU bounded implementation 
over a given graph. As we can see, using parallel computations in GPU, we can get a considerable
Speed Up even in smaller graph, given that there are sufficient large number of parallel computations
in the given graph.

# Places of Improvement
No code is perfect, here also there are places of improvement, like, optimisations in sending very precise 
data to the GPU, i.e. sending only that data which is extremely needed, as GPU memory allocation time 
is one of the most time consuming operations in a GPU bound program. Other optimisations could be 
rather than using static graphs, we could modify the algorithm for Dynamic Graphs.


