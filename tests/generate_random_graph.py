import networkx as nx
import numpy as np

print(nx.moebius_kantor_graph())
rgraph = nx.watts_strogatz_graph(n=800, k=12, p=0.54, seed=24)

print(rgraph)

rgraph_np = np.array(rgraph.edges)


file = open("./datasets/watts_strogatz.txt", 'r+')

file_header = str(len(rgraph.nodes)) + ' ' + str(len(rgraph.edges)) + '\n'
file.write(file_header)
for edge in rgraph_np:
    file_content = str(edge[0]) + ' ' + str(edge[1]) + '\n'
    file.write(file_content)
print("watts strogatz graph generated!\n")
