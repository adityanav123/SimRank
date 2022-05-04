import numpy as np
import matplotlib.pyplot as plt

normfile="../data/l1Norm.txt"

y_coordinates=np.loadtxt(normFile)
x_coordinates=[i for i in range(y_coordinates.shape[0])]

plt.plot(y_coordinates, x_coordinates)
plt.xlabel("Matrix Score[norm] --> ")
plt.ylabel("no. of iterations --> ")
plt.suptitle("plot of convergence of simrank algorithm")
plt.savefig("./convergence.jpg")
#plt.show()
