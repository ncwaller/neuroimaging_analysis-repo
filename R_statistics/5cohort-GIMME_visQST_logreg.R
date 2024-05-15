#! R

# Logistice Regression (Non-Machine Learning Approach)
## Applied to 5 Cohort GIMME Project - visual QST + clinical measures - to predict responders to treatment

# INPUT DATA
setwd("/Users/noahwaller/Documents/3cohort-GIMME PAPER/csv_for-code")

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("7cohort_visQST_allmetrics_outrem.csv", 
                                 header = T, sep = ","))
View(data_full)