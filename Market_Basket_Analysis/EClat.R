library(arules)
dataset = read.csv('Market_Basket_Optimisation.csv', header = FALSE)
dataset = read.transactions('Market_Basket_Optimisation.csv', sep = ',', rm.duplicates = TRUE)
summary(dataset)
itemFrequencyPlot(dataset, topN = 10)
eclat_rules = eclat(data = dataset, parameter = list(support = 0.01))
eclat_basket <- as(eclat_rules,"data.frame")
View(eclat_basket)
inspect(sort(eclat_rules, by = 'lift')[1:10])