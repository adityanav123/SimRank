import networkx as nx
import numpy as np

print("create bipartite graph m X n")

m = int(input('m : '))
n = int(input('n : '))

print("m : ", m, " n : ", n)

graph_generated = nx.complete_bipartite_graph(m, n)

print('\n',graph_generated)

dataset = np.array(graph_generated.edges)
print("no. of nodes : ", len(graph_generated.nodes))

n_nodes = len(graph_generated.nodes)
n_edges = len(graph_generated.edges)

file = open("./datasets/bipartite_.txt", 'r+')
file_header = str(n_nodes) + ' ' + str(n_edges) + '\n'
file.write(file_header)
for edge in dataset:
    content = str(edge[0]) + ' ' + str(edge[1]) + '\n'
    file.write(content)
file.close()

