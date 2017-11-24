#Installing Spark
library(sparklyr)
spark_connect(master = 'local')
spark_available_versions()
spark_install(version = "2.2.0", hadoop_version = "2.7")


#Setting up Environment Variable
if(Sys.getenv("SPARK_HOME") < 1) {
  Sys.setenv(SPARK_HOME = "C:\\Users\\meetr\\AppData\\Local\\spark\\spark-2.2.0-bin-hadoop2.7")
}

#importing the SparkR library
library(SparkR, lib.loc="C:\\Users\\meetr\\AppData\\Local\\spark\\spark-2.2.0-bin-hadoop2.7\\R\\lib")

#Creating Spark Session default at port 4040
sc <- sparkR.session()
sqlContext <- sparkRSQL.init(sc)

dataset <- data.frame(read.csv("Market_Basket_Optimisation.csv", header = FALSE))

#Fitting the model and extracting the freqItemset and associationRules
model = spark.fpGrowth(dataset, 0.3, 0.8)

spark.freqItemsets(model)

spark.associationRules(model)

