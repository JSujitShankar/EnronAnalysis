import matplotlib.pyplot as plt
accuracy = (97.3265073948, 98.4072810011, 97.8953356086)
training_time = (1.218, 222.582, 50.37)
import numpy as np
index = np.arange(3)
bar_width = 0.5
opacity = 0.4
rects = plt.bar(index, accuracy, bar_width, alpha=opacity, color='b', label="Accuracy")
plt.xlabel("Algorithms")
plt.ylabel("Accuarcy(in %)")
plt.xticks(index, ('Naive Bayes', 'SVM', 'Decision Tree'))
plt.legend()
plt.show()

rects = plt.bar(index, training_time, bar_width, alpha=opacity, color='b', label="Training Time")
plt.xlabel("Algorithms")
plt.ylabel("Training Time(in s)")
plt.xticks(index, ('Naive Bayes', 'SVM', 'Decision Tree'))
plt.legend()
plt.show()