#! R

# Simple and Multiple Regression Analysis
## Designed for any .csv file, organized by groups of interest in labelled columns

# INPUT DATA
setwd()

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("file_name.csv", 
                                 header = T, sep = ","))
View(data_full)

# SIMPLE REGRESSIONS
## SIMPLE REGRESSION - OF Y (column_1) ON X (column_2)
reg_output_1 <-lm(column_1 ~ column_2, data = data_full)
summary(reg_output_1)

## SIMPLE REGRESSION - OF Y (column_3) ON X (column_2)
reg_output_2 <-lm(column_3 ~ column_2, data = data_full)
summary(reg_output_2)

### Get Residuals
data_full$reg_output_1_res <- resid(reg_output_1) #getting residuals
data_full$reg_output_1_stanres <- rstandard(reg_output_1) #getting standardized residuals

data_full$reg_output_2_res <- resid(reg_output_2) #getting residuals
data_full$reg_output_2_stanres <- rstandard(reg_output_2) #getting standardized residuals


# MULTIPLE (HIERARCHICAL) REGRESSION
## Model Direction 1

### Step 1: Enter Known Predictor
step1_model <- lm(column_1 ~ column_2, data = data_full)
summary(step1_model)

## Step 2: Enter New Predictors
step2_model <-lm(column_1 ~ column_2 + column_3, data = data_full)
summary(step2_model)

### Calculate R^2 change by subtracting R^2 in step1_model from R^2 in step2_model
R2change <- summary(step2_model)$r.squared - summary(step1_model)$r.squared
R2change
### Compare models in each step to get significance of R^2 change
anova(step1_model,step2_model)

## Model Direction 2
## Step 1: Enter Known Predictor
step1_model <- lm(column_1 ~ column_3, data = data_full)
summary(step1_model)

## Step 2: Enter New Predictors
step2_model <-lm(column_1 ~ column_3 + column_2, data = data_full)
summary(step2_model)

### Calculate R^2 change by subtracting R^2 in step1_model from R^2 in step2_model
R2change <- summary(step2_model)$r.squared - summary(step1_model)$r.squared
R2change
### Compare models in each step to get significance of R^2 change
anova(step1_model,step2_model)

