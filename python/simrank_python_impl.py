import networkx as nx
import numpy as np
import os

G = nx.DiGraph() 
edges=[]

os.system("truncate -s 0 ./simrank_python_output.txt")

edge_lst_ = np.loadtxt("../data/datasets/graph_input.txt")

for i in range (1, edge_lst_.shape[0]):
	from_,to_ = edge_lst_[i][0], edge_lst_[i][1]
	G.add_edge(from_, to_)

no_of_edges = edge_lst_.shape[0] - 1
no_of_vertices = edge_lst_[0][0]

print (G)

print ("confidence value : 0.9")
print ("max iterations : 1000")

simrank_ = nx.simrank_similarity (G, importance_factor=0.9, max_iterations=1000)

print("simrank matrix :\n", simrank_)

write_on_ = "simrank_python_output.txt"
#command = "touch " + write_on_
os.system(write_on_)

_file_ = open (write_on_, "w+")
for i in range(1, int(no_of_vertices)):
	A = simrank_[i]
	_file_.write (str(i) + ": ")
	for j in range(1, int(no_of_vertices)):
		store_ = str(A[j])
		_file_.write (store_ + " ")
	_file_.write("\n")
_file_.close()

print("see graph @ simrank_python_output.txt")
