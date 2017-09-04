# -*- coding: utf-8 -*-
"""
Created on Mon Sep  4 00:18:18 2017

@author: Meet-69
"""

# Data Preprocessing Template

# Importing the libraries
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import os
os.getcwd()
os.chdir('C:/Users/Meet-69/Desktop/Machine-Learning-A-Z/Machine Learning A-Z Template Folder/Part 2 - Regression/Section 4 - Simple Linear Regression/Simple_Linear_Regression/Simple_Linear_Regression')

# Importing the dataset
dataset = pd.read_csv('Salary_Data.csv')
X = dataset.iloc[:, :-1].values
y = dataset.iloc[:, 1].values

# Splitting the dataset into the Training set and Test set
from sklearn.cross_validation import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 1/3, random_state = 0)

# No Feature Scaling is required as all the values of all the columns are numeric


# Applying simple linear regression to the test set
from sklearn.linear_model import LinearRegression
regressor = LinearRegression()
regressor.fit(X_train, y_train)

# Predicting the salaries from the experience
y_pred = regressor.predict(X_test)

# Visualising the training set results
plt.scatter(X_train, y_train, color = 'red')
plt.plot(X_train, regressor.predict(X_train), color = 'blue')
plt.title('Salary vs Experience for training set')
plt.xlabel('Experience')
plt.ylabel('Salary')
plt.show()

# Visualising the test set results
plt.scatter(X_test, y_test, color = 'red')
plt.plot(X_train, regressor.predict(X_train), color = 'blue')
plt.title('Salary vs Experience for test set')
plt.xlabel('Experience')
plt.ylabel('Salary')
plt.show()