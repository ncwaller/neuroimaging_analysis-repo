#! R

# Regressing Sex and Age
## Designed for any .csv file, organized by groups of interest in labelled columns

# INPUT DATA
## Set Working Directory
setwd()

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("metric_ofinterest.csv", 
                                 header = T, sep = ","))
View(data_full)

##### MULTIPLE REGRESSION ######
## Enter Both Predictors (Sex & Age) for Measure of Interest (ex. QST response, imaging contrast)
step1_model <-lm(asc_pain50 ~ Sex + Age, data = data_full)
summary(step1_model)

### Residual Work
data_full$measure_res <- resid(step1_model) #getting residuals
data_full$measure_mean <- mean(data_full$asc_pain50)
data_full$measure_corrected <- data_full$measure_mean+data_full$measure_res
