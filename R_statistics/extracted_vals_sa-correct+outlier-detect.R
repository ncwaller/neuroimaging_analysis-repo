#! R

# Regressing Sex and Age + Outlier Detection - Specifically for Extracted Values from fMRI ROIs
## Designed for .csv file organized into 6 columns: 
## group#_rest, group#_vis, group#_visminrest, sex, age, covariate_ofinterest

# INPUT DATA
## Set Working Directory
setwd()

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("file_name.csv", 
                                 header = T, sep = ","))
View(data_full)


##### GROUP 1 ######

##### MULTIPLE REGRESSION VISMINREST ######
## Enter Both Predictors (Sex & Age) for Visminrest Z-stat
step1_model <-lm(group1_visminrest ~ sex + age, data = data_full)
summary(step1_model)

### Residual Work
data_full$visminrest_res <- resid(step1_model) #getting residuals
data_full$visminrest_mean <- mean(data_full$group1_visminrest)
data_full$visminrest_corrected <- data_full$visminrest_mean+data_full$visminrest_res


##### MULTIPLE REGRESSION VIS+ ######
## Enter Both Predictors (Sex & Age) for Visminrest Z-stat
step2_model <-lm(group1_vis ~ sex + age, data = data_full)
summary(step2_model)

### Residual Work
data_full$vis_res <- resid(step2_model) #getting residuals
data_full$vis_mean <- mean(data_full$group1_vis)
data_full$vis_corrected <- data_full$vis_mean+data_full$vis_res


##### MULTIPLE REGRESSION REST+ ######
## Enter Both Predictors (Sex & Age) for Visminrest Z-stat
step3_model <-lm(group1_rest ~ sex + age, data = data_full)
summary(step3_model)

### Residual Work
data_full$rest_res <- resid(step3_model) #getting residuals
data_full$rest_mean <- mean(data_full$group1_rest)
data_full$rest_corrected <- data_full$rest_mean+data_full$rest_res


##### MULTIPLE REGRESSION COVARIATE OF INTEREST ######
## Enter Both Predictors (Sex & Age) for Covariate of Interest (ex. Vis Unpl Rating, FM Score)
step4_model <-lm(visMRI_unpl ~ sex + age, data = data_full)
summary(step4_model)

### Residual Work
data_full$visMRI_unpl_res <- resid(step4_model) #getting residuals
data_full$visMRI_unpl_mean <- mean(data_full$visMRI_unpl)
data_full$visMRI_unpl_corrected <- data_full$visMRI_unpl_mean+data_full$visMRI_unpl_res


## OUTLIER DETECTION ##

# Import Packages
library(EnvStats)
library(outliers)

## By Column
### Visminrest
rosnerTest(data_full$visminrest_corrected, k = 3, alpha = 0.05)
### Vis+
rosnerTest(data_full$vis_corrected, k = 3, alpha = 0.05)
### Rest+
rosnerTest(data_full$rest_corrected, k = 3, alpha = 0.05)

### Covariate of Interest
rosnerTest(data_full$visMRI_unpl_corrected, k = 3, alpha = 0.05)


############################################################################################
############################################################################################


##### GROUP 2 ######

##### MULTIPLE REGRESSION VISMINREST ######
## Enter Both Predictors (Sex & Age) for Visminrest Z-stat
step1_model <-lm(group2_visminrest ~ sex + age, data = data_full)
summary(step1_model)

### Residual Work
data_full$visminrest_res <- resid(step1_model) #getting residuals
data_full$visminrest_mean <- mean(data_full$group2_visminrest)
data_full$visminrest_corrected <- data_full$visminrest_mean+data_full$visminrest_res


##### MULTIPLE REGRESSION VIS+ ######
## Enter Both Predictors (Sex & Age) for Visminrest Z-stat
step2_model <-lm(group2_vis ~ sex + age, data = data_full)
summary(step2_model)

### Residual Work
data_full$vis_res <- resid(step2_model) #getting residuals
data_full$vis_mean <- mean(data_full$group2_vis)
data_full$vis_corrected <- data_full$vis_mean+data_full$vis_res


##### MULTIPLE REGRESSION REST+ ######
## Enter Both Predictors (Sex & Age) for Visminrest Z-stat
step3_model <-lm(group2_rest ~ sex + age, data = data_full)
summary(step3_model)

### Residual Work
data_full$rest_res <- resid(step3_model) #getting residuals
data_full$rest_mean <- mean(data_full$group2_rest)
data_full$rest_corrected <- data_full$rest_mean+data_full$rest_res


##### MULTIPLE REGRESSION COVARIATE OF INTEREST ######
## Enter Both Predictors (Sex & Age) for Covariate of Interest (ex. Vis Unpl Rating, FM Score)
step4_model <-lm(visMRI_unpl ~ sex + age, data = data_full)
summary(step4_model)

### Residual Work
data_full$visMRI_unpl_res <- resid(step4_model) #getting residuals
data_full$visMRI_unpl_mean <- mean(data_full$visMRI_unpl)
data_full$visMRI_unpl_corrected <- data_full$visMRI_unpl_mean+data_full$visMRI_unpl_res


## OUTLIER DETECTION ##

# Import Packages
library(EnvStats)
library(outliers)

## By Column
### Visminrest
rosnerTest(data_full$visminrest_corrected, k = 3, alpha = 0.05)
### Vis+
rosnerTest(data_full$vis_corrected, k = 3, alpha = 0.05)
### Rest+
rosnerTest(data_full$rest_corrected, k = 3, alpha = 0.05)

### Covariate of Interest
rosnerTest(data_full$visMRI_unpl_corrected, k = 3, alpha = 0.05)

