import networkx as nx
import numpy as np


#print(nx.moebius_kantor_graph())
no_of_vertices = int(input("enter no. of vertices to the graph: "))
rgraph = nx.watts_strogatz_graph(n=no_of_vertices, k=12, p=0.54, seed=24)

print("graph created : ", rgraph)

rgraph_np = np.array(rgraph.edges)

file = open("./datasets/graph_input.txt", 'r+')

file_header = str(len(rgraph.nodes)) + ' ' + str(len(rgraph.edges)) + '\n'
file.write(file_header)
for edge in rgraph_np:
    file_content = str(edge[0]) + ' ' + str(edge[1]) + '\n'
    file.write(file_content)
print("watts strogatz graph generated! & stored in ./datasets/graph_input.txt\n")
