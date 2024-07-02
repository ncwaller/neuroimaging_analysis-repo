#! R

# Regressing Sex and Age
## Designed for any .csv file, organized by groups of interest in labelled columns

# INPUT DATA
## Set Working Directory
setwd("/Users/noahwaller/Documents/VISUAL-QST-7cohort PAPER/csv_for-code")

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("visqst_bright-only_outrem.csv", 
                                 header = T, sep = ","))
View(data_full)

##### MULTIPLE REGRESSION ######
## Unpl
## Enter Both Predictors (Sex & Age) for Measure of Interest (ex. QST response, imaging contrast)
step1_model <-lm(vis01_unpl_avg ~ sex + age, data = data_full)
summary(step1_model)

step2_model <-lm(vis02_unpl_avg ~ sex + age, data = data_full)
summary(step2_model)

step3_model <-lm(vis03_unpl_avg ~ sex + age, data = data_full)
summary(step3_model)

step4_model <-lm(vis04_unpl_avg ~ sex + age, data = data_full)
summary(step4_model)

step5_model <-lm(vis05_unpl_avg ~ sex + age, data = data_full)
summary(step5_model)

step6_model <-lm(vis06_unpl_avg ~ sex + age, data = data_full)
summary(step6_model)

step7_model <-lm(vis_unpl_avg ~ sex + age, data = data_full)
summary(step7_model)


### Residual Work
## Unpl
data_full$vis01_unpl_avg_res <- resid(step1_model) #getting residuals
data_full$vis01_unpl_avg_mean <- mean(data_full$vis01_unpl_avg)
data_full$vis01_unpl_avg_corrected <- data_full$vis01_unpl_avg_mean+data_full$vis01_unpl_avg_res

data_full$vis02_unpl_avg_res <- resid(step2_model) #getting residuals
data_full$vis02_unpl_avg_mean <- mean(data_full$vis02_unpl_avg)
data_full$vis02_unpl_avg_corrected <- data_full$vis02_unpl_avg_mean+data_full$vis02_unpl_avg_res

data_full$vis03_unpl_avg_res <- resid(step3_model) #getting residuals
data_full$vis03_unpl_avg_mean <- mean(data_full$vis03_unpl_avg)
data_full$vis03_unpl_avg_corrected <- data_full$vis03_unpl_avg_mean+data_full$vis03_unpl_avg_res

data_full$vis04_unpl_avg_res <- resid(step4_model) #getting residuals
data_full$vis04_unpl_avg_mean <- mean(data_full$vis04_unpl_avg)
data_full$vis04_unpl_avg_corrected <- data_full$vis04_unpl_avg_mean+data_full$vis04_unpl_avg_res

data_full$vis05_unpl_avg_res <- resid(step5_model) #getting residuals
data_full$vis05_unpl_avg_mean <- mean(data_full$vis05_unpl_avg)
data_full$vis05_unpl_avg_corrected <- data_full$vis05_unpl_avg_mean+data_full$vis05_unpl_avg_res

data_full$vis06_unpl_avg_res <- resid(step6_model) #getting residuals
data_full$vis06_unpl_avg_mean <- mean(data_full$vis06_unpl_avg)
data_full$vis06_unpl_avg_corrected <- data_full$vis06_unpl_avg_mean+data_full$vis06_unpl_avg_res

data_full$vis_unpl_avg_res <- resid(step7_model) #getting residuals
data_full$vis_unpl_avg_mean <- mean(data_full$vis_unpl_avg)
data_full$vis_unpl_avg_corrected <- data_full$vis_unpl_avg_mean+data_full$vis_unpl_avg_res

write.csv(data_full, "/Users/noahwaller/Documents/VISUAL-QST-7cohort PAPER/csv_for-code/visqst_unpl-only_outrem_SAcorr.csv")

## Bright
## Enter Both Predictors (Sex & Age) for Measure of Interest (ex. QST response, imaging contrast)
step1_model <-lm(vis01_bright_avg ~ sex + age, data = data_full)
summary(step1_model)

step2_model <-lm(vis02_bright_avg ~ sex + age, data = data_full)
summary(step2_model)

step3_model <-lm(vis03_bright_avg ~ sex + age, data = data_full)
summary(step3_model)

step4_model <-lm(vis04_bright_avg ~ sex + age, data = data_full)
summary(step4_model)

step5_model <-lm(vis05_bright_avg ~ sex + age, data = data_full)
summary(step5_model)

step6_model <-lm(vis06_bright_avg ~ sex + age, data = data_full)
summary(step6_model)

step7_model <-lm(vis_bright_avg ~ sex + age, data = data_full)
summary(step7_model)

## Bright
data_full$vis01_bright_avg_res <- resid(step1_model) #getting residuals
data_full$vis01_bright_avg_mean <- mean(data_full$vis01_bright_avg)
data_full$vis01_bright_avg_corrected <- data_full$vis01_bright_avg_mean+data_full$vis01_bright_avg_res

data_full$vis02_bright_avg_res <- resid(step2_model) #getting residuals
data_full$vis02_bright_avg_mean <- mean(data_full$vis02_bright_avg)
data_full$vis02_bright_avg_corrected <- data_full$vis02_bright_avg_mean+data_full$vis02_bright_avg_res

data_full$vis03_bright_avg_res <- resid(step3_model) #getting residuals
data_full$vis03_bright_avg_mean <- mean(data_full$vis03_bright_avg)
data_full$vis03_bright_avg_corrected <- data_full$vis03_bright_avg_mean+data_full$vis03_bright_avg_res

data_full$vis04_bright_avg_res <- resid(step4_model) #getting residuals
data_full$vis04_bright_avg_mean <- mean(data_full$vis04_bright_avg)
data_full$vis04_bright_avg_corrected <- data_full$vis04_bright_avg_mean+data_full$vis04_bright_avg_res

data_full$vis05_bright_avg_res <- resid(step5_model) #getting residuals
data_full$vis05_bright_avg_mean <- mean(data_full$vis05_bright_avg)
data_full$vis05_bright_avg_corrected <- data_full$vis05_bright_avg_mean+data_full$vis05_bright_avg_res

data_full$vis06_bright_avg_res <- resid(step6_model) #getting residuals
data_full$vis06_bright_avg_mean <- mean(data_full$vis06_bright_avg)
data_full$vis06_bright_avg_corrected <- data_full$vis06_bright_avg_mean+data_full$vis06_bright_avg_res

data_full$vis_bright_avg_res <- resid(step7_model) #getting residuals
data_full$vis_bright_avg_mean <- mean(data_full$vis_bright_avg)
data_full$vis_bright_avg_corrected <- data_full$vis_bright_avg_mean+data_full$vis_bright_avg_res

write.csv(data_full, "/Users/noahwaller/Documents/VISUAL-QST-7cohort PAPER/csv_for-code/visqst_bright-only_outrem_SAcorr.csv")
