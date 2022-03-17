import numpy as np
import matplotlib.pyplot as plt

filename = "CPU_Time.txt"
filename1 = "GPU_Time.txt"

y_coord1 = np.loadtxt(filename1)
y_coord2 = np.loadtxt(filename)
# print(y_coord1.shape)

x_coord1 = [i for i in range(y_coord1.shape[0])]

plt.plot(x_coord1, y_coord1, color='g', label='gpu time')
plt.plot(x_coord1, y_coord2, color='r', label='cpu time')
plt.title("Time Comparision for in_neighbour calculation (GPU V/S CPU)")
plt.xlabel("iteration number")
plt.ylabel("time for computing in-neighbour (log scale)")
plt.legend()
plt.yscale('log')
plt.savefig("in-neighbour-calculation.png")
plt.show()

