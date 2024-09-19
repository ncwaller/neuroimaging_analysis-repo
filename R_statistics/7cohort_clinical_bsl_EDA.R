#! R

# Descriptive Statistics, Correlation Matrices, and Scatterplot Analysis
## Applied to 7 Cohort - clinical measures

# INPUT DATA
setwd("/Users/noahwaller/Documents/VISUAL-QST-7cohort PAPER/csv_for-code")

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("all_clinical.csv", 
                                 header = T, sep = ","))
View(data_full)

## Format sex and cohort as a factor
data_full$sex_f <- factor(data_full$sex, levels=c(1:2), labels=c("Male", "Female"))
data_full$cohort_f <- factor(data_full$cohort, levels=c(0:6), labels=c("HC", "RA", "CTS", "OA", "CPP", "PSA", "FM"))


# EXPLORE DATA
## Descriptives
library(psych)

describe(data_full) # full
describeBy(data_full$bpi3, data_full$cohort_f) # by grouping variable and output


# SCATTERPLOTS
## Scatterplot Matrix is useful first-pass for checking distributions and possible outliers
library(car)
scatterplotMatrix(~ pd02 + wpi + sss + fm_score, data = data_full, smooth=FALSE)

## Single scatterplots for in-depth investigating
scatterplot(fm_score ~ pd02, data=data_full,
            ylab="FM Score", xlab="PDQ 02",
            main="PDQ vs FM Score", col="dark blue")

# Adjust Plot View in VS Code
# install.packages("httpgd", repos='http://cran.us.r-project.org')

# Adjust VS Code settings in Command Pallette for User Setting JSON View
# "r.plot.useHttpgd": true


# TESTING FOR OUTLIERS
## Import Relevant R Packages
#install.packages("EnvStats", repos='http://cran.us.r-project.org')
#install.packages("outliers", repos='http://cran.us.r-project.org')

?grubbs.test
?rosnerTest # iterative Grubbs Test - preferred option for QST data
library(EnvStats)
library(outliers)

## Run Rosner's ESD Test by Column
### Group 1
rosnerTest(data_full$pd02, k = 3, alpha = 0.05)
### Group 2
rosnerTest(data_full$wpi, k = 3, alpha = 0.05)
### Group 3
rosnerTest(data_full$sss, k = 3, alpha = 0.05)
### Group 4
rosnerTest(data_full$fm_score, k = 3, alpha = 0.05)

### Group HC
rosnerTest(data_full$fm_score[data_full$cohort_f=="HC"], k = 3, alpha = 0.05)
### Group RA
rosnerTest(data_full$fm_score[data_full$cohort_f=="RA"], k = 3, alpha = 0.05)
### Group CTS
rosnerTest(data_full$fm_score[data_full$cohort_f=="CTS"], k = 3, alpha = 0.05)
### Group OA
rosnerTest(data_full$fm_score[data_full$cohort_f=="OA"], k = 3, alpha = 0.05)
### Group CPP
rosnerTest(data_full$fm_score[data_full$cohort_f=="CPP"], k = 3, alpha = 0.05)
### Group PSA
rosnerTest(data_full$fm_score[data_full$cohort_f=="PSA"], k = 3, alpha = 0.05)
### Group FM
rosnerTest(data_full$fm_score[data_full$cohort_f=="FM"], k = 3, alpha = 0.05)

### Group HC
rosnerTest(data_full$sss[data_full$cohort_f=="HC"], k = 3, alpha = 0.05)
### Group RA
rosnerTest(data_full$sss[data_full$cohort_f=="RA"], k = 3, alpha = 0.05)
### Group CTS
rosnerTest(data_full$sss[data_full$cohort_f=="CTS"], k = 3, alpha = 0.05)
### Group OA
rosnerTest(data_full$sss[data_full$cohort_f=="OA"], k = 3, alpha = 0.05)
### Group CPP
rosnerTest(data_full$sss[data_full$cohort_f=="CPP"], k = 3, alpha = 0.05)
### Group PSA
rosnerTest(data_full$sss[data_full$cohort_f=="PSA"], k = 3, alpha = 0.05)
### Group FM
rosnerTest(data_full$sss[data_full$cohort_f=="FM"], k = 3, alpha = 0.05)

### Group HC
rosnerTest(data_full$wpi[data_full$cohort_f=="HC"], k = 3, alpha = 0.05)
### Group RA
rosnerTest(data_full$wpi[data_full$cohort_f=="RA"], k = 3, alpha = 0.05)
### Group CTS
rosnerTest(data_full$wpi[data_full$cohort_f=="CTS"], k = 3, alpha = 0.05)
### Group OA
rosnerTest(data_full$wpi[data_full$cohort_f=="OA"], k = 3, alpha = 0.05)
### Group CPP
rosnerTest(data_full$wpi[data_full$cohort_f=="CPP"], k = 3, alpha = 0.05)
### Group PSA
rosnerTest(data_full$wpi[data_full$cohort_f=="PSA"], k = 3, alpha = 0.05)
### Group FM
rosnerTest(data_full$wpi[data_full$cohort_f=="FM"], k = 3, alpha = 0.05)

# UPDATE ORIGINAL FILE PATH TO "OUTREM" FILE ONCE VALUES ARE REMOVED MANUALLY



# VISUALIZE
## Histograms
hist(data_full$fm_score)
hist(data_full$fm_score, freq=FALSE) # Density function
hist(data_full$fm_score, breaks=2) # Change bin size
hist(data_full$fm_score, breaks=10)
hist(data_full$fm_score[data_full$sex_f=="Female"],   # Advanced formatting
     main = "FM Score Histogram - Females",       
     xlab = "FM Score",   
     breaks=5,   
     xlim = range(0:30),                        
     col = "orange")                           

hist(data_full$wpi)
hist(data_full$sss)
hist(data_full$pd02)

## Normality
#install.packages("dplyr")
library(dplyr)

shapiro.test(data_full$fm_score) # Remain cautious with statistical tests for normality


## Boxplots
boxplot(data_full$fm_score)
boxplot(data_full$fm_score~data_full$sex_f)
boxplot(data_full$fm_score~data_full$sex_f, # Advanced formatting
        col = "orange", 
        boxwex = .3,                              #make boxes narrower
        ylab = "FM Score",     
        xlab = "Sex",    
        ylim = c(0,30))   


data_full$cohort_f <- factor(data_full$cohort_f , levels=c("HC", "CTS", "OA", "RA", "CPP", "PSA", "FM")) # reorder
boxplot(data_full$fm_score~data_full$cohort_f,
        col = c("red", "darkgreen", "blue", "orange", "cyan", "springgreen", "purple"), 
        boxwex = .5,                              
        ylab = "FM Score",     
        xlab = "Cohort",    
        ylim = c(0,30))     


# CORRELATIONS
## Pearson: Multiple Functions 
data_cortable <- cor(data_full[5:8], use = "pairwise", method = "pearson")
View(data_cortable)

## Correlation Testing for Significance
cor.test(data_full$fm_score, data_full$pd02, method = "pearson")
cor.test(data_full$fm_score, data_full$pd02, method = "spearman")

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


# ANOVA
## One-Way
results1 <- aov(fm_score ~ cohort_f, data = data_full)   #aov is a wrapper for lm()

## View Results in ANOVA Style
results1
summary(results1)

## Adjustments for Heterogeneity of Variance
### There is an na.action option
oneway.test(fm_score ~ cohort_f, data = data_full, var.equal = TRUE)   #same as aov()
oneway.test(fm_score ~ cohort_f, data = data_full, var.equal = FALSE)  #Welch's F-test

### Tukey Multcomp
post_tuk1 <- TukeyHSD(results1, which = "cohort_f")
post_tuk1

### Better
#install.packages("multcomp", repos='http://cran.us.r-project.org')
library(multcomp)
post_tuk2 <- glht(results1, linfct = mcp(cohort_f = "Tukey"))
summary(post_tuk2)
