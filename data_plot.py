import numpy as np
import matplotlib.pyplot as plt

x_data = [0, -67, -174, -133, -133, -133, -133, -133, -388, 0, 0, -95, -95, 149, 155, 237, 251, 251, 219, 0, 234, 130, 0, 84, 68, 0, 0, 0, -135, 0, -104, 0, 0, 69, 0, 0, 208, 199, 199, 172, 172, 172, 158, 0, 0, 0, 0, 0, -74, 0, -88, -88, -130, -115, -112, -112, -63, 0, -93, -86, 0, -176, -146, 184, 425, 0, 303, 158, 184, 4090, -183, -111, 0, -196, -401, -235, -461, -379, -207, 0, 0, 91, 91, 154, 76, 195, 195, 400, 323, 0, -93, -93, 137, -100, 0, -103, -136, -562, -460, -142]
z_data =[-32, -87, 4089, -187, -187, -187, -187, -187, -319, 64, 49, -14, -14, 120, 274, 373, 316, 316, 25, 347, 12, 36, 3, -35, 83, -40, -64, -95, -119, -44, -77, 64, -86, -21, -33, -59, 166, 281, 281, 30, 30, 30, 224, -13, -64, -87, -103, 6, -52, -48, -22, -22, -73, 4087, -235, -235, 4095, -318, -178, -86, 125, 126, 164, 367, 47, 472, 344, 69, 181, -172, -274, -235, -143, -279, -535, -429, -563, -555, 4090, -221, -73, 124, 124, 217, 308, 551, 551, 506, 367, 43, -217, -217, -13, -170, -51, -159, -140, -695, -751, -376]

for i in range(len(x_data)):
  if x_data[i] > 4000:
    x_data[i] = x_data[i-1] 

  if z_data[i] > 4000:
    z_data[i] = z_data[i-1] 

date_len = len(x_data)
index = [i for i in range(date_len)]

fig, ax = plt.subplots()
plt.xticks(rotation=90)
ax.plot(index, x_data, color='b')

# X軸を共有する双軸
ax2 = ax.twinx()

ax2.plot(index, z_data, color='r')
plt.show()