import networkx as nx
import numpy as np

#print("hello world")
#K_5=nx.complete_graph(5)
#
#a = np.array(K_5.edges)
#
#print(a)


#file = open('graph.txt', 'r+')
#print("\n\nfile contents:")
#for each in file:
#    print (each)
#print("file.read(): ", file.read())
#file.write("anshul navphule")


# creating complete graph.
n_vertex = 250
#complete_graph = nx.complete_graph(n_vertex)
complete_bipartite_graph =nx.complete_bipartite_graph(18,55)

print(complete_bipartite_graph.edges)
#print(complete_graph)

graph_to_numpy = np.array(complete_graph.edges)
n_edges = len(complete_graph.edges)
file = open("complete_graph.txt", "r+")
#print(len(complete_graph.edges))
st = str(n_vertex) + ' ' + str(n_edges) + '\n'
file.write(st)
#print(graph_to_numpy)
for edge in graph_to_numpy:
    edge_c = str(edge[0]) + ' ' + str(edge[1]) + '\n'
    file.write(edge_c)

file.close()


