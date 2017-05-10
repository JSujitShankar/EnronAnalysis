import matplotlib.pyplot as plt
accuracy = (85.722, 89.704, 99.260)
training_time = (5.768, 22.56, 5.75)
import numpy as np
index = np.arange(3)
bar_width = 0.5
opacity = 0.4
rects = plt.bar(index, accuracy, bar_width, alpha=opacity, color='b', label="Accuracy")
plt.xlabel("Algorithms")
plt.ylabel("Accuarcy(in %)")
plt.xticks(index, ('k-Nearest Neighbors', 'AdaBoost', 'Random Forest'))
plt.legend()
plt.show()

rects = plt.bar(index, training_time, bar_width, alpha=opacity, color='b', label="Training Time")
plt.xlabel("Algorithms")
plt.ylabel("Training Time(in s)")
plt.xticks(index, ('k-Nearest Nrighbors', 'AdaBoost', 'Random Forest'))
plt.legend()
plt.show()