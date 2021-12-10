import networkx as nx
import numpy as np


graph = nx.pappus_graph()
print(graph)

file = open("./datasets/pappus_.txt", 'r+')

graph_np = np.array(graph.edges)

file_header = str(len(graph.nodes)) + ' ' + str(len(graph.edges)) + '\n'
file.write(file_header)
for edge in graph_np:
    file_content = str(edge[0]) + ' ' + str(edge[1]) + '\n'
    file.write(file_content)

print("graph writtent to file pappus_.txt!")
