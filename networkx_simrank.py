import networkx as nx
import numpy as np

G = nx.DiGraph()

G.add_edge(0, 3);
G.add_edge(0, 4);
G.add_edge(1, 0);
G.add_edge(1, 2);
G.add_edge(3, 4);
G.add_edge(3, 0);



# print(G)

# print('nodes - ', list(G));

# print('edges - ', list(G.edges));

print("confidence value: 0.9")
print("max iterations set at : 1000")

simrank_mtx = nx.simrank_similarity(G, importance_factor=0.9, max_iterations=1000);

print("\nfor 0 : ", simrank_mtx[0]);
print("\nfor 1 : ", simrank_mtx[1]);
print("\nfor 2 : ", simrank_mtx[2]);
print("\nfor 3 : ", simrank_mtx[3]);
print("\nfor 4 : ", simrank_mtx[4]);



print("graph")

A = np.array(nx.adjacency_matrix(G).todense())

print(A)
