import numpy as np
import matplotlib.pyplot as plt

filename = "l2_norms_values.txt"
filename1 = "l1_norms_values.txt"

y_coord_l1 = np.loadtxt(filename1)
y_coord_l2 = np.loadtxt(filename)

x_coord_l1 = [i for i in range(y_coord_l1.shape[0])]

x_coord_l2 = [i for i in range(y_coord_l2.shape[0])]
#print("l1 shape : ",y_coord_l1.shape)
#print("l2 shape : ", y_coord_l2.shape)

plt.subplot(211)
plt.plot(y_coord_l1, x_coord_l1)
plt.xlabel('Forbeius Norm (L-F) ')
plt.ylabel('# of Iterations')
plt.subplot(212)
plt.plot(y_coord_l2, x_coord_l2)
plt.xlabel('L2 norm ')
plt.ylabel('# of Iterations')
plt.suptitle('Plot of Convergence of LF and L2 norms for SimRank')
plt.savefig("convergence.jpg")
plt.show()


