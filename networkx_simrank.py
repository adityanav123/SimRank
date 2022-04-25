import networkx as nx
import numpy as np
import os

os.system ('rm -rf ./networkx_simrank_output.txt')

G = nx.DiGraph()

edges=[]
fileInput = np.loadtxt("./tests/datasets/graph_input.txt")
for i in range (1, fileInput.shape[0]):
    # print (i, "->", fileInput[i])
    fromNode, toNode=fileInput[i][0], fileInput[i][1]
    G.add_edge(fromNode, toNode)


noOfEdges=fileInput.shape[0]-1


noOfVertices = fileInput[0][0]

print(G)
print ("no of vertices : ", noOfVertices)

# print('nodes - ', list(G));

# print('edges - ', list(G.edges));

print("confidence value: 0.9")
print("max iterations set at : 1000")

simrank_mtx = nx.simrank_similarity(G, importance_factor=0.9, max_iterations=1000);

# print (simrank_mtx[0])

toWrite = "networkx_simrank_output.txt"
command = "touch " + toWrite
os.system(command)

# print (simrank_mtx[0][2])

file = open (toWrite, "w+")
for i in range (1,int(noOfVertices)):
    a = simrank_mtx[i]
    file.write (str(i) + ": ")
    for i in range (1, int(noOfVertices)):
        toStore_ = str(a[i])
        file.write(toStore_ + " ")
    file.write("\n")
file.close()
print("graph")

# A = np.array(nx.adjacency_matrix(G).todense())

# print(A)
