#! R

# Descriptive Statistics, Correlation Matrices, and Scatterplot Analysis
## Designed for any .csv file, organized by groups of interest in labelled columns

# INPUT DATA
setwd("/Users/noahwaller/Documents/VISUAL-QST-7cohort PAPER/csv_for-code")

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("all_visqst+clinical_bsl.csv", 
                                 header = T, sep = ","))
View(data_full)

# EXPLORE DATA
## Descriptives
library(psych)

describe(data_full)
describeBy(data_full$fm_score_bsl, data_full$fm_score_6m)


# CORRELATIONS
## Pearson: Multiple Functions 
data_cortable <- cor(data_full[1:10], use = "pairwise", method = "pearson")
View(data_cortable)

## Correlation Testing for Significance
cor.test(data_full$vis_unpl_avg, data_full$fm_score, method = "pearson")
cor.test(data_full$vis_unpl_avg, data_full$pd02, method = "pearson")
cor.test(data_full$vis_unpl_avg, data_full$bpi5, method = "pearson")
cor.test(data_full$vis_unpl_avg, data_full$PROMIS_PI_tscore, method = "pearson")
cor.test(data_full$vis_unpl_avg, data_full$PROMIS_SRI_tscore, method = "pearson")
cor.test(data_full$vis_unpl_avg, data_full$PROMIS_Ftg_Exp_tscore, method = "pearson")
cor.test(data_full$vis_unpl_avg, data_full$PROMIS_Ftg_SI_tscore, method = "pearson")
cor.test(data_full$vis_unpl_avg, data_full$PROMIS_Ftg_CI_tscore, method = "pearson")
cor.test(data_full$vis_unpl_avg, data_full$PROMIS_Ftg_MI_tscore, method = "pearson")
cor.test(data_full$vis_unpl_avg, data_full$PROMIS_Dep_tscore, method = "pearson")
cor.test(data_full$vis_unpl_avg, data_full$PROMIS_Anx_tscore, method = "pearson")

cor.test(data_full$vis_bright_avg, data_full$fm_score, method = "pearson")
cor.test(data_full$vis_bright_avg, data_full$pd02, method = "pearson")
cor.test(data_full$vis_bright_avg, data_full$bpi5, method = "pearson")
cor.test(data_full$vis_bright_avg, data_full$PROMIS_PI_tscore, method = "pearson")
cor.test(data_full$vis_bright_avg, data_full$PROMIS_SRI_tscore, method = "pearson")
cor.test(data_full$vis_bright_avg, data_full$PROMIS_Ftg_Exp_tscore, method = "pearson")
cor.test(data_full$vis_bright_avg, data_full$PROMIS_Ftg_SI_tscore, method = "pearson")
cor.test(data_full$vis_bright_avg, data_full$PROMIS_Ftg_CI_tscore, method = "pearson")
cor.test(data_full$vis_bright_avg, data_full$PROMIS_Ftg_MI_tscore, method = "pearson")
cor.test(data_full$vis_bright_avg, data_full$PROMIS_Dep_tscore, method = "pearson")
cor.test(data_full$vis_bright_avg, data_full$PROMIS_Anx_tscore, method = "pearson")


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
write.csv(data_rcortable$r, "/Users/noahwaller/Documents/VISUAL-QST-7cohort PAPER/csv_for-code/visqst+clinical_all_corr_r.csv")

# Extract p-values
data_rcortable$P
View(data_rcortable$P)
write.csv(data_rcortable$P, "/Users/noahwaller/Documents/VISUAL-QST-7cohort PAPER/csv_for-code/visqst+clinical_all_corr_pval.csv")



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





