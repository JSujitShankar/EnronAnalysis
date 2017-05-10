#!/usr/bin/python

""" 
    This is the code to accompany the Lesson 2 (SVM) mini-project.
    Use a SVM to identify emails from the Enron corpus by their authors:    
    Sara has label 0
    Chris has label 1
"""
activate python27
import sys
from time import time
sys.path.append("../tools/")
from email_preprocess import preprocess


### features_train and features_test are the features for the training
### and testing datasets, respectively
### labels_train and labels_test are the corresponding item labels
features_train, features_test, labels_train, labels_test = preprocess()




#########################################################
### your code goes here ###
from sklearn.svm import SVC
clf = SVC(kernel="rbf", C = 10000)

#features_train = features_train[:len(features_train)/100] 
#labels_train = labels_train[:len(labels_train)/100]

t0 = time()
clf.fit(features_train, labels_train)

print "Training time:", round(time()-t0, 3), "s"

t0 = time()
pred = clf.predict(features_test)

print "Prediction time:", round(time()-t0, 3), "s"

from sklearn.metrics import accuracy_score
print "Accuracy:", round(accuracy_score(pred, labels_test), 3)

#print "predictions: 10=", pred[10], " 26=", pred[26], " 50=", pred[50]

print sum(pred)
##################################################################################################################
