import networkx as nx 
import matplotlib.pyplot as plt

def draw_graph(graph):
    pltGraph = nx.draw(graph)
    plt.show()


graph = nx.frucht_graph()
draw_graph(graph)