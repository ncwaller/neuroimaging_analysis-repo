#! R

# Outlier Analysis via Rosners ESD (Grubbs) Test
## Designed for any .csv file, organized by groups of interest in labelled columns

# INPUT DATA
## Set Working Directory
setwd()

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("metric_ofinterest.csv", 
                                 header = T, sep = ","))
View(data_full)

# TESTING FOR OUTLIERS
## Import Relevant R Packages
?grubbs.test
?rosnerTest
library(EnvStats)
library(outliers)

## Run Rosner's ESD Test by Column
### Group 1
rosnerTest(data_full$column_1, k = 3, alpha = 0.05)
### Group 2
rosnerTest(data_full$column_2, k = 3, alpha = 0.05)
### Group 3
rosnerTest(data_full$column_3, k = 3, alpha = 0.05)
### Group 4
rosnerTest(data_full$column_4, k = 3, alpha = 0.05)
### Group 5
rosnerTest(data_full$column_5, k = 3, alpha = 0.05)

