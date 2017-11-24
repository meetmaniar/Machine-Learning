# Apriori
# Data Preprocessing
# install.packages('arules')
library(arules)
# Pre-processing
dataset = read.csv('Market_Basket_Optimisation.csv', header = FALSE)
dataset = read.transactions('Market_Basket_Optimisation.csv', sep = ',', rm.duplicates = TRUE)
summary(dataset)
itemFrequencyPlot(dataset, topN = 10)

# Training Apriori on the dataset
apriori_rules = apriori(data = dataset, parameter = list(support = 0.004, confidence = 0.2))
# Table View of Data
apriori_basket <- as(apriori_rules,"data.frame")
View(apriori_basket)
# Visualising the results
inspect(sort(apriori_rules, by = 'lift')[1:10])

###################Eclat############################################
eclat_rules = eclat(data = dataset, parameter = list(support = 0.01))
eclat_basket <- as(eclat_rules,"data.frame")
View(eclat_basket)
inspect(sort(eclat_rules, by = 'lift')[1:10])
