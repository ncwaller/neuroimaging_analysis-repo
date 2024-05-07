#! R

# Descriptive Statistics, Correlation Matrices, and Scatterplot Analysis
## Applied to 3 Cohort GIMME Project - visual QST + clinical measures

# INPUT DATA
setwd("/Users/noahwaller/Documents/3cohort-GIMME PAPER/csv_for-code")

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("3cohort_visQST_allmetrics.csv", 
                                 header = T, sep = ","))
View(data_full)

## Format sex and cohort as a factor
data_full$sex_f <- factor(data_full$sex, levels=c(0:1), labels=c("Male", "Female"))
data_full$cohort_f <- factor(data_full$cohort, levels=c(1:5), labels=c("RA", "CTS", "OA", "CPP", "PSA"))


# EXPLORE DATA
## Descriptives
library(psych)

describe(data_full) # full
describeBy(data_full$fm_score_bsl, data_full$sex_f) # by grouping variable and output


# SCATTERPLOTS
## Scatterplot Matrix is useful first-pass for checking distributions and possible outliers
library(car)
scatterplotMatrix(~ vis01_unpl_avg + vis02_unpl_avg + vis03_unpl_avg + 
                    vis04_unpl_avg + vis05_unpl_avg + vis06_unpl_avg, data = data_full, smooth=FALSE)

scatterplotMatrix(~ vis01_bright_avg + vis02_bright_avg + vis03_bright_avg + 
                    vis04_bright_avg + vis05_bright_avg + vis06_bright_avg, data = data_full, smooth=FALSE)

scatterplotMatrix(~ pd02_bsl + wpi_bsl + sss_bsl + fm_score_bsl +
                    pd02_6m + wpi_6m + sss_6m + fm_score_6m, data = data_full, smooth=FALSE)

## Single scatterplots for in-depth investigating
scatterplot(vis_unpl_avg ~ fm_score_bsl, data=data_full,
            ylab="Visual Unpleasantness", xlab="FM Score",
            main="Visual Unpleasantness vs FM Score", col="dark blue")

# Adjust Plot View in VS Code
# install.packages("httpgd", repos='http://cran.us.r-project.org')

# Adjust VS Code settings in Command Pallette for User Setting JSON View
# "r.plot.useHttpgd": true


# TESTING FOR OUTLIERS
## Import Relevant R Packages
?grubbs.test
?rosnerTest # iterative Grubbs Test - preferred option for QST data
library(EnvStats)
library(outliers)

## Run Rosner's ESD Test by Column
### Visual Unpleasantness
### Group 1
rosnerTest(data_full$vis01_unpl_avg, k = 3, alpha = 0.05)
### Group 2
rosnerTest(data_full$vis02_unpl_avg, k = 3, alpha = 0.05)
### Group 3
rosnerTest(data_full$vis03_unpl_avg, k = 3, alpha = 0.05)
### Group 4
rosnerTest(data_full$vis04_unpl_avg, k = 3, alpha = 0.05)
### Group 5
rosnerTest(data_full$vis05_unpl_avg, k = 3, alpha = 0.05)
### Group 6
rosnerTest(data_full$vis06_unpl_avg, k = 3, alpha = 0.05)

### Visual Brightness
### Group 1
rosnerTest(data_full$vis01_bright_avg, k = 3, alpha = 0.05)
### Group 2
rosnerTest(data_full$vis02_bright_avg, k = 3, alpha = 0.05)
### Group 3
rosnerTest(data_full$vis03_bright_avg, k = 3, alpha = 0.05)
### Group 4
rosnerTest(data_full$vis04_bright_avg, k = 3, alpha = 0.05)
### Group 5
rosnerTest(data_full$vis05_bright_avg, k = 3, alpha = 0.05)
### Group 6
rosnerTest(data_full$vis06_bright_avg, k = 3, alpha = 0.05)

### PDQ, WPI, SSS, FM Score
### Group 1
rosnerTest(data_full$pd02_bsl, k = 3, alpha = 0.05)
### Group 2
rosnerTest(data_full$wpi_bsl, k = 5, alpha = 0.05)
### Group 3
rosnerTest(data_full$sss_bsl, k = 3, alpha = 0.05)
### Group 4
rosnerTest(data_full$fm_score_bsl, k = 5, alpha = 0.05)
### Group 5
rosnerTest(data_full$pd02_6m, k = 3, alpha = 0.05)
### Group 6
rosnerTest(data_full$wpi_6m, k = 3, alpha = 0.05)
### Group 7
rosnerTest(data_full$sss_6m, k = 3, alpha = 0.05)
### Group 8
rosnerTest(data_full$fm_score_6m, k = 3, alpha = 0.05)


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
scatterplotMatrix(~ fm_score_bsl + vis01_unpl_avg + vis06_unpl_avg, data = data_full, smooth=FALSE)

scatterplot(fm_score_bsl ~ vis06_unpl_avg, data=data_full,
            xlab="Visual Unpleasantness", ylab="FM Score",
            main="Vis vs FM Score", col="dark blue")

# Adjust Plot View in VS Code
# install.packages("httpgd", repos='http://cran.us.r-project.org')

# Adjust VS Code settings in Command Pallette for User Setting JSON View
# "r.plot.useHttpgd": true

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





