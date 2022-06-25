from cProfile import label
from fileinput import filename
import networkx as nx
import matplotlib.pyplot as plt
import os
import numpy as np

def DrawGraph(Graph, filePath):
    #pltsh = nx.draw_random(Graph,with_labels=True)
    nx.draw_random (Graph, with_labels=True)
    fileName = filePath + 'randomGraph.png'
    plt.savefig(fileName)
    plt.show() # for showing the graph

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
    
    print("Graph Stored!! @", fileName)
    
    show_graph = input('Print Graph? y/N : ')
    if show_graph.lower() == 'y':
        DrawGraph (Graph, "../")



# deleting old dataset
command = 'rm -rf ../data/datasets/graph_input.txt'
os.system(command)


node_cnt = int(input('no. of nodes in the graph : '))

graph = nx.paley_graph(node_cnt)

StoreGraph (graph, "../data/datasets/graph_input.txt")
