#! R

# Descriptive Statistics, Correlation Matrices, and Scatterplot Analysis
## Designed for any .csv file, organized by groups of interest in labelled columns

# INPUT DATA
setwd()

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("metric_ofinterest.csv", 
                                 header = T, sep = ","))
View(data_full)

# EXPLORE DATA
## Descriptives
library(psych)

describe(data_full)
describeBy(data_full$column_1, data_full$column_2)


# CORRELATIONS
## Pearson: Multiple Functions 
data_cortable <- cor(data_full[1:10], use = "pairwise", method = "pearson")
View(data_cortable)

## Correlation Testing for Significance
cor.test(data_full$column_1, data_full$column_2, method = "pearson")

## Correlation Testing for Significance (Spearman)
cor.test(data_full$high_unpl_corrected, data_full$WPI, method = "spearman")

## Modified Correlation Tables
#install.packages("Hmisc")
library(Hmisc)
data_rcortable <- rcorr(as.matrix(data_full))
data_rcortable
View(data_rcortable) #3 different tables

## View Tables
# Extract the correlation coefficients
data_rcortable$r
View(data_rcortable$r)
# Extract p-values
data_rcortable$P
View(data_rcortable$P)


# SCATTERPLOTS
library(car)
scatterplotMatrix(~ WPI + SSS + FM_Score + bpi5 + bpi3, data = data_full, smooth=FALSE)

scatterplot(column_1 ~ column_2, data=data_full,
            xlab="X Axis", ylab="Y Axis",
            main="Title", col="dark blue")

# Normality
install.packages("dplyr")
library(dplyr)

shapiro.test(data_full$age)
shapiro.test(data_full$high_unpl_corrected)

## Visualize
hist(data_full$FM_Score)
hist(data_full$WPI)
hist(data_full$SSS)
hist(data_full$bpi5)
hist(data_full$bpi3)
hist(data_full$high_unpl_corrected)
hist(data_full$high_bright_corrected)
hist(data_full$avg_unpl_corrected)
hist(data_full$avg_bright_corrected)

hist(data_full$vis_0.1_unpl_avg)
hist(data_full$vis_0.2_unpl_avg)
hist(data_full$vis_0.4_unpl_avg)
hist(data_full$vis_0.6_unpl_avg)
hist(data_full$vis_0.8_unpl_avg)
hist(data_full$vis_1.0_unpl_avg)





