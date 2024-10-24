#! R

# Logistic Regression (Non-Machine Learning Approach)
## Applied to 5 Cohort GIMME Project - visual QST + clinical measures - to predict responders to treatment

# INPUT DATA
setwd("/Users/noahwaller/Documents/VISUAL-QST-7cohort PAPER/csv_for-code")

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("visqst_unpl-only_noHCFM_tx-resp_cov-fmscore_outrem_forLogReg.csv", 
                                 header = T, sep = ","))
View(data_full)

## Check Variable Types (Factor) and Levels
data_full$sex_f <- factor(data_full$sex, levels=c(1:2), labels=c("Male", "Female"))
data_full$cohort_f <- factor(data_full$cohort, levels=c(0:6), labels=c("HC", "RA", "CTS", "OA", "CPP", "PSA", "FM"))
data_full$responder_f <- factor(data_full$responder_bin, levels=c(0:1), labels=c("Non-responder", "Responder"))

## Create subframe based on baseline PDQ02 of 3 or greater
#data_bslpd02_subset = data_full[data_full$pd02_bsl>=3,]

#View(data_bslpd02_subset)

################################################################################################

#####install.packages("aod", repos='http://cran.us.r-project.org')
library(aod)

mylogit <- glm(responder_f ~ vis_unpl_avg + pd02_bsl + age + sex_f, data = data_full, family = "binomial")
summary(mylogit)

exp(cbind(OR = coef(mylogit), confint(mylogit)))





################################################################################################


### R assigns factor levels alphabetically, but we want to determine baseline (0 group)
levels(data_full$responder_f) # Non-responder is first and will be baseline
#data_full$responder_f <- relevel(data_full$responder_f, "Responder") #made responder baseline (if we want this)


# ASSUMPTIONS
## Incomplete Information for Categorical Predictor 
### Examine expected frequencies
#install.packages("esc", repos='http://cran.us.r-project.org')
library(esc) 
library(gmodels)
CrossTable(data_full$insert_categorical_predictor, data_full$responder_f, expected = TRUE) #if I have categorical predictor

## Complete Separation for Continuous Predictor 
### Examine plot
plot(data_full$vis_unpl_avg, data_full$responder_f) # we don't want complete seperation, we want some overlap.. or else a different, simple model would fit better
plot(data_full$vis_bright_avg, data_full$responder_f)
plot(data_full$fm_score_bsl, data_full$responder_f)
plot(data_full$pd02_bsl, data_full$responder_f)


# LOGISTIC REGRESSION
## Model 0 with Intercepts Only (and age + sex)
### Use constant as predictor
?glm
model0 <- glm(responder_f ~ 1 + age + sex_f, data = data_full, family = binomial()) #binomial for logistic
summary(model0)

## Model 1 with Continuous Predictor (fm_score)
model1 <- glm(responder_f ~ fm_score_bsl + age + sex_f, data = data_full, family = binomial()) 
summary(model1)

### Calculate odds ratios
exp(model1$coefficients)

## Does FM score model differ from age/sex-only model?
model01 <- anova(model0, model1)
model01
#?pchisq
1 - pchisq(8.3634, 1) #yes! according to chi-squre distribution. input deviance difference.
esc_chisq(chisq = 8.8954, totaln = 113, es.type = "d") # calculate effect size for model comparison - set at Cohen's d

## Model 2 with 2 continuous predictors (vis_unpl and fm_score) 
model2 <- glm(responder_f ~ vis_bright_avg + fm_score_bsl + age + sex_f, data = data_full, family = binomial())
summary(model2)

### Calculate odds ratios
exp(model2$coefficients)

## Does multuiple continuous predictors model differ from intercepts-only model?
model02 <- anova(model0, model2)
model02
1 - pchisq(13.245, 2) #yes
esc_chisq(chisq = 13.245, totaln = 113, es.type = "d") # calculate effect size for model comparison - set at Cohen's d

## Does Intervention + Duration model differ from Intervention model?
model12 <- anova(model1, model2)
model12
1 - pchisq(8.1197, 1) #yes, so this model is best so far
esc_chisq(chisq = 8.1197, totaln = 113, es.type = "d") # calculate effect size for model comparison - set at Cohen's d
