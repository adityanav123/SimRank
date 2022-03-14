import filecmp
from logging.config import fileConfig
import networkx as nx
import numpy as np
import matplotlib.pyplot as plt
import os

def DrawGraph(Graph, filePath):
    graph=nx.draw_random(Graph)
    fileName = filePath + 'randomGraph.png'
    plt.savefig(fileName)
    plt.show()

def GenerateGraph(noOfVertices):
    Graph = nx.watts_strogatz_graph(n=no_of_vertices, k=12, p=0.54, seed=24)
    return Graph

def StoreGraph(Graph, fileName):
    if os.path.exists (fileName) == False:
        command='touch ' + fileName
        os.system(command)
    file=open(fileName, "r+")
    Graph_Numpy = np.array(Graph.edges)
    
    file_header=str(len(Graph.nodes)) + ' ' + str(len(Graph.edges)) + '\n'
    file.write(file_header)
    
    for edge in Graph_Numpy:
        file_content = str(edge[0]) + ' ' + str(edge[1]) + '\n'
        file.write(file_content)
    DrawGraph(Graph, "../")
    print("Graph Stored!! @", fileName)


#print(nx.moebius_kantor_graph())
no_of_vertices = int(input("enter no. of vertices to the graph: "))

Graph = GenerateGraph(no_of_vertices)
StoreGraph (Graph, "./datasets/graph_input.txt")
