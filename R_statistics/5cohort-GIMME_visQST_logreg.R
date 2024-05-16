#! R

# Logistic Regression (Non-Machine Learning Approach)
## Applied to 5 Cohort GIMME Project - visual QST + clinical measures - to predict responders to treatment

# INPUT DATA
setwd("/Users/noahwaller/Documents/3cohort-GIMME PAPER/csv_for-code")

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("7cohort_visQST_allmetrics_outrem.csv", 
                                 header = T, sep = ","))
View(data_full)

## Check Variable Types (Factor) and Levels
data_full$sex_f <- factor(data_full$sex, levels=c(0:1), labels=c("Male", "Female"))
data_full$cohort_f <- factor(data_full$cohort, levels=c(0:6), labels=c("HC", "RA", "CTS", "OA", "FM", "PSA", "CPP"))
data_full$responder_f <- factor(data_full$responder_bin, levels=c(0:1), labels=c("Non-responder", "Responder"))

### R assigns factor levels alphabetically, but we want to determine baseline (0 group)
levels(data_full$responder_f) # Non-responder is first and will be baseline
#data_full$responder_f <- relevel(data_full$responder_f, "Responder") #made responder baseline (if we want this)


# ASSUMPTIONS
## Incomplete Information for Categorical Predictor 
### Examine expected frequencies
library(gmodels)
CrossTable(data_full$insert_categorical_predictor, data_full$responder_f, expected = TRUE) #if I have categorical predictor

## Complete Separation for Continuous Predictor 
### Examine plot
plot(data_full$vis_unpl_avg, data_full$responder_f) # we don't want complete seperation, we want some overlap.. or else a different, simple model would fit better
plot(data_full$vis_bright_avg, data_full$responder_f)
plot(data_full$fm_score_bsl, data_full$responder_f)
plot(data_full$pd02_bsl, data_full$responder_f)


# LOGISTIC REGRESSION
## Model 0 with Intercepts Only
### Use constant as predictor
?glm
model0 <- glm(responder_f ~ 1, data = data_full, family = binomial()) #binomial for logistic
summary(model0)

## Model 1 with Continuous Predictor (vis_unpl_avg)
model1 <- glm(responder_f ~ vis_unpl_avg, data = data_full, family = binomial()) 
summary(model1)

### Calculate odds ratios
exp(model1$coefficients)

## Does visual unpleasantness model differ from intercepts-only model?
model01 <- anova(model0, model1)
model01
?pchisq
1 - pchisq(2.43, 1) #no, according to chi-squre distribution. input deviance difference.

## Model 2 with 2 continuous predictors (vis_unpl and fm_score) 
model2 <- glm(responder_f ~ vis_unpl_avg + fm_score_bsl + pd02_bsl, data = data_full, family = binomial())
summary(model2)

### Calculate odds ratios
exp(model2$coefficients)

## Does multuiple continuous predictors model differ from intercepts-only model?
model02 <- anova(model0, model2)
model02
1 - pchisq(6.77, 2) #not quite sure how to manage this one

## Does Intervention + Duration model differ from Intervention model?
model12 <- anova(model1, model2)
model12
1 - pchisq(.0019835, 1) #no, so select Intervention model


# More assumption need to be checked, but this model is not performing in any case. Yet.
# Check Beltz code for more detail as needed.