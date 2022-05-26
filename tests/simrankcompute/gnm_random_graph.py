import networkx as nx
from networkx.generators import directed
import numpy as np
import matplotlib.pyplot as plt
import os

print('g-nm random graph')

g = nx.gnm_random_graph(5, 9, seed=23,directed=True)
#print('graph generated : ', g)

#print (g.edges)

file = open('./graph.txt', 'r+')

os.system('truncate -s 0 ./graph.txt')

#plt_ = nx.draw_planar(g, with_labels=True)
#plt.show()

#print (len(g.nodes), ' ', len(g.edges))

file.write(str(len(g.nodes)) + " " + str(len(g.edges)) + '\n')

graphnp = np.array(g.edges)

for i in range(len(g.edges)):
    edge=str(graphnp[i][0]) + " " + str(graphnp[i][1]) + '\n'
    file.write(edge)

file.close()


