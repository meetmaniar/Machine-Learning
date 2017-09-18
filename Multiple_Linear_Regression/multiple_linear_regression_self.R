# Importing the dataset
dataset = read.csv('50_Startups.csv')

# Splitting the dataset into the Training set and Test set

# Encoding categorical data
dataset$State = factor(dataset$State,
                         levels = c('New York', 'California', 'Florida'),
                         labels = c(1, 2, 3))

# install.packages('caTools')
library(caTools)
set.seed(123)
split = sample.split(dataset$Profit, SplitRatio = 0.8)
training_set = subset(dataset, split == TRUE)
test_set = subset(dataset, split == FALSE)

# Feature Scaling
# training_set = scale(training_set)
# test_set = scale(test_set)

# Fitting multiple linear regression to the training set
regressor = lm(formula = Profit ~ R.D.Spend,
               data = training_set)  #Profit is the dependent variable & . is all the independent variable on which Profit is dependent on.
summary(regressor)
y_pred = predict(regressor, newdata = test_set)