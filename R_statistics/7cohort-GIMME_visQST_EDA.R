#! R

# Descriptive Statistics, Correlation Matrices, and Scatterplot Analysis
## Applied to 3 Cohort GIMME Project - visual QST + clinical measures

# INPUT DATA
setwd("/Users/noahwaller/Documents/3cohort-GIMME PAPER/csv_for-code")

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("7cohort_visqst_allmetrics_outrem_sacorr.csv", 
                                 header = T, sep = ","))
View(data_full)

## Format sex and cohort as a factor
data_full$sex_f <- factor(data_full$sex, levels=c(0:1), labels=c("Male", "Female"))
data_full$cohort_f <- factor(data_full$cohort, levels=c(0:6), labels=c("HC", "RA", "CTS", "OA", "FM", "PSA", "CPP"))
data_full$responder_f <- factor(data_full$responder_bin, levels=c(0:1), labels=c("Non-responder", "Responder"))

## Create subframe based on baseline PDQ 02 of 3 or greater
data_bslpd02_subset = data_full[data_full$pd02_bsl>=3,]

View(data_bslpd02_subset)

# EXPLORE DATA
## Descriptives
library(psych)

describe(data_full) # full
describeBy(data_full$fm_score_bsl, data_full$responder_f) # by grouping variable and output


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
scatterplot(vis06_unpl_avg ~ fm_score_bsl, data=data_full,
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
### Group 7
rosnerTest(data_full$vis_unpl_avg, k = 3, alpha = 0.05)

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
### Group 7
rosnerTest(data_full$vis_bright_avg, k = 3, alpha = 0.05)

### PDQ, WPI, SSS, FM Score
# Can screen here, but might want to screen on the clinical BSL sheet for more N
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

### Group 1
rosnerTest(data_full$pd02, k = 3, alpha = 0.05)
### Group 2
rosnerTest(data_full$wpi, k = 3, alpha = 0.05)
### Group 3
rosnerTest(data_full$sss, k = 3, alpha = 0.05)
### Group 4
rosnerTest(data_full$fm_score, k = 3, alpha = 0.05)

# UPDATE ORIGINAL FILE PATH TO "OUTREM" FILE ONCE VALUES ARE REMOVED MANUALLY


# VISUALIZE
## Histograms
hist(data_full$fm_score_bsl)
hist(data_full$fm_score_bsl, freq=FALSE) # Density function
hist(data_full$fm_score_bsl, breaks=2) # Change bin size
hist(data_full$fm_score_bsl, breaks=10)
hist(data_full$fm_score_bsl[data_full$sex_f=="Female"],   # Advanced formatting
     main = "FM Score Histogram - Females",       
     xlab = "FM Score",   
     breaks=5,   
     xlim = range(0:30),                        
     col = "orange")                           

hist(data_full$wpi_bsl, breaks=20)
hist(data_full$sss_bsl)
hist(data_full$pd02_bsl)
hist(data_full$fm_score_6m)
hist(data_full$wpi_6m)
hist(data_full$sss_6m)
hist(data_full$pd02_6m)

hist(data_full$vis01_unpl_avg)
hist(data_full$vis02_unpl_avg)
hist(data_full$vis03_unpl_avg)
hist(data_full$vis04_unpl_avg)
hist(data_full$vis05_unpl_avg)
hist(data_full$vis06_unpl_avg)
hist(data_full$vis_unpl_avg)

hist(data_full$vis01_bright_avg)
hist(data_full$vis02_bright_avg)
hist(data_full$vis03_bright_avg)
hist(data_full$vis04_bright_avg)
hist(data_full$vis05_bright_avg)
hist(data_full$vis06_bright_avg)
hist(data_full$vis_bright_avg)

## Normality
#install.packages("dplyr")
library(dplyr)

shapiro.test(data_full$fm_score_bsl) # Remain cautious with statistical tests for normality


## Boxplots
boxplot(data_full$fm_score_bsl)
boxplot(data_full$fm_score_bsl~data_full$sex_f)
boxplot(data_full$fm_score_bsl~data_full$sex_f, # Advanced formatting
        col = "orange", 
        boxwex = .3,                              #make boxes narrower
        ylab = "FM Score",     
        xlab = "Sex",    
        ylim = c(0,30))   
boxplot(data_full$fm_score_bsl~data_full$cohort_f,
        col = "orange", 
        boxwex = .3,                              #make boxes narrower
        ylab = "FM Score",     
        xlab = "Cohort",    
        ylim = c(0,30))     

#data_full$cohort_f <- factor(data_full$cohort_f , levels=c("HC", "CTS", "OA", "RA", "CPP", "PSA", "FM")) # reorder
boxplot(data_full$fm_score_bsl~data_full$responder_f,
        col = c("red", "darkgreen"), 
        boxwex = .5,                              
        ylab = "FM Score",     
        xlab = "Responder",    
        ylim = c(0,30)) 


boxplot(data_full$vis_bright_avg~data_full$responder_f,
        col = c("red", "darkgreen"), 
        boxwex = .5,                              
        ylab = "Vis Metric",     
        xlab = "Responder",    
        ylim = c(0,100)) 

# T Tests
t.test(vis_bright_avg ~ responder_f, data = data_full)
t.test(fm_score_bsl ~ responder_f, data = data_full)

# CORRELATIONS
## Pearson: Multiple Functions 
data_cortable <- cor(data_full[1:10], use = "pairwise", method = "pearson")
View(data_cortable)

## Correlation Testing for Significance
cor.test(data_full$sss_bsl, data_full$vis_bright_avg, method = "pearson")

cor.test(data_full$fm_score_bsl, data_full$vis_unpl_avg, method = "spearman")

## Modified Correlation Tables (automaticaly tests for significance, reports p-values)
#install.packages("Hmisc")
library(Hmisc)
data_rcortable <- rcorr(as.matrix(data_full)) # IMPORTANT: data_full cannot include non-numerical columns (ex. factorized, cohort)
data_rcortable
View(data_rcortable) #3 different tables

# Extract the correlation coefficients
data_rcortable$r
View(data_rcortable$r)
# Extract p-values
data_rcortable$P
View(data_rcortable$P)
