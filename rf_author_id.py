#!/usr/bin/python

""" 
    Use a Random Forest Classifier to identify emails by their authors
    
    authors and labels:
    Sara has label 0
    Chris has label 1
"""
    
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

## Random Forest Algorithm
print "\nRandom Forest Algorithm\n"

# import RandomForestClassifier from sklearn.ensemble
from sklearn.ensemble import RandomForestClassifier
# also import time
from time import time

# create a classifier
clf_RF = RandomForestClassifier(n_estimators=15, min_samples_split=50)
# note the start of training time
t0 = time()
# train the classifier
clf_RF.fit(features_train, labels_train)
# print the training time
print "training time:", round(time() - t0, 3), "s"

# note the start of testing time
t0 = time()
# predict the labels of features_test
predicted = clf_RF.predict(features_test)
# print the testing time
print "testing time:", round(time() - t0, 3), "s"

# import accuracy_score from sklearn.metrics to calculate accuracy
from sklearn.metrics import accuracy_score
# calculate accuracy
acc = accuracy_score(labels_test, predicted)
# print the accuracy
print "accuracy:", acc
print "\n"

#########################################################


