from cProfile import label
from fileinput import filename
import networkx as nx
import matplotlib.pyplot as plt
import os
import numpy as np

def DrawGraph(Graph, filePath):
    pltsh = nx.draw_random(Graph,with_labels=True)
    fileName = filePath + 'randomGraph.png'
    plt.savefig(fileName)
    # plt.show() # for showing the graph

def StoreGraph(Graph, fileName):
    command='touch ' + fileName
    os.system(command)

    file=open(fileName, "r+")
    Graph_Numpy = np.array(Graph.edges)
    
    file_header=str(len(Graph.nodes)) + ' ' + str(len(Graph.edges)) + '\n'
    file.write(file_header)
    
    for edge in Graph_Numpy:
        file_content = str(edge[0]) + ' ' + str(edge[1]) + '\n'
        file.write(file_content)
    DrawGraph(Graph, "../data/datasets/")
    print("Graph Stored!! @", fileName)


# deleting old dataset
command = 'rm -rf ./data/datasets/graph_input.txt'
os.system(command)

# n nodes and m edges
print("Generating Gnm Random Graph.")

print("enter no. of vertices : ")
vertex_count = int(input())
print("enter no. of edges : ")
edge_count = int(input())

graph = nx.gnm_random_graph(n=vertex_count, m=edge_count, seed=24, directed=True)

StoreGraph (graph, "./datasets/graph_input.txt")
