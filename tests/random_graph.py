import numpy as np
import random


e = int(input("no. of edges: "))
v = int(input("no. of vertices : "))

file = open("random_g.txt", 'r+')
file_header = str(v) + ' ' + str(e) + '\n'
file.write(file_header)
print(random.randint(0, v), " ", random.randint(0, v))
for i in range(e):
    node1 = random.randint(0, v-1)
    node2 = random.randint(0, v-1)
    file_content = str(node1) + ' ' + str(node2) + '\n'
    #print("edge: ", node1, " ", node2)
    file.write(file_content)
file.close()

