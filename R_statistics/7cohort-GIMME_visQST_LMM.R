#! R

# Descriptive Statistics, Correlation Matrices, and Scatterplot Analysis
## Applied to 7 Cohort GIMME Project - visual QST + clinical measures

# ==============================================================================

# Linear Mixed Model template
## Designed for any .csv file, organized by groups of interest in labelled columns

## Read in and Convert Data (.csv file)
### File has been cleaned of any missing data/outliers (listwise deletion)
### Seperate by rating modality, depending on research question
data_lmm <- data.frame(read.csv("7cohort_visQST_unpl_forLMM.csv", 
                                 header = T, sep = ","))
View(data_lmm)

## Format sex and cohort as a factor
data_lmm$sex_f <- factor(data_lmm$sex, levels=c(0:1), labels=c("Male", "Female"))
data_lmm$cohort_f <- factor(data_lmm$cohort, levels=c(0:6), labels=c("HC", "RA", "CTS", "OA", "FM", "PSA", "CPP"))

## Convert to Long Format
#install.packages("tidyr", repos='http://cran.us.r-project.org')
library(tidyr)

# The arguments to gather():
# - data: Data object
# - key: Name of new key column (made from names of data columns)
# - value: Name of new value column
# - ...: Names of source columns that contain values
# - factor_key: Treat the new key column as a factor (instead of character vector)
data_lmm_long <- gather(data_lmm, illuminance_level, rating, vis01_unpl_avg:vis06_unpl_avg, factor_key=TRUE)
data_lmm_long = data_lmm_long[order(data_lmm_long$subid),] # sort by subid

View(data_lmm_long)

# Remove CTS (causing problems with such low N)
data_lmm_long = data_lmm_long[!data_lmm_long$cohort_f=="CTS",]

# INSTALL
#install.packages("lme4", repos='http://cran.us.r-project.org')
#install.packages("merDerive", repos='http://cran.us.r-project.org')
#install.packages("ggeffects", repos='http://cran.us.r-project.org')

library(lme4) 
library(merDeriv) 
library(ggeffects) 


# Dependent variable: Visual Unpleasantness Rating
# Fixed effects: Cohort, Sex, Age
# Random effect: Subject, Illuminance Level

data_lmm_long.null = lmer(rating ~ sex + age +
                        (1|subid), data=data_lmm_long, REML=FALSE)
data_lmm_long.model = lmer(rating ~ sex + age + cohort_f + (1|illuminance_level) +
                         (1|subid), data=data_lmm_long, REML=FALSE)
data_lmm_long.model

anova(data_lmm_long.null,data_lmm_long.model) #compare the two models (effect of cohort)

# Subframe into 2 Cohorts
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="HC" | data_lmm_long$cohort_f=="RA",]

View(data_lmm_long_2group)

# LMM
data_lmm_long_2group.model = lmer(rating ~ illuminance_level +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE) 
                        # simplest model, not checking cohort differences yet or accounting for age and sex
                        # includes a random effect for subjects and fixed effect for illuminance level
                        # DV is rating

data_lmm_long_2group.model = lmer(rating ~ illuminance_level +
                        (1 + illuminance_level | subid), data=data_lmm_long_2group, REML=FALSE) 
                        # next step, add random slopes for difference in effects of illuminance level between subjects
                        # won't work given number of observations (it's too complicated for the dataset)

# Effect of Cohort

data_lmm_long_2group.null = lmer(rating ~ sex + age + illuminance_level +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE)
                        # add age and sex as fixed effects, and establish null model
                
data_lmm_long_2group.null = lmer(rating ~ sex + age + illuminance_level + cohort_f +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE)
                        # add cohort fixed effect
                        
data_lmm_long_2group.model # check model
anova(data_lmm_long_2group.null,data_lmm_long_2group.model) #compare the two models (effect of cohort between HC and RA)


# Effect of Interaction Between Cohort and Illuminance Level

data_lmm_long_2group.null = lmer(rating ~ sex + age + illuminance_level + cohort_f +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE) 

data_lmm_long_2group.model = lmer(rating ~ sex + age + illuminance_level * cohort_f +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE) 
                        # add interaction term between illuminance level and cohort
                        # includes a random effect for subjects and fixed effect for illuminance level

data_lmm_long_2group.model # check model
coef(data_lmm_long_2group.model) # check coefficients
anova(data_lmm_long_2group.null,data_lmm_long_2group.model) #compare the two models (effect of interaction between HC and RA




data_lmm_long_2group.null = lmer(rating ~ sex + age + illuminance_level +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE)
data_lmm_long_2group.model = lmer(rating ~ sex + age + cohort_f + illuminance_level +
                         (1|subid), data=data_lmm_long_2group, REML=FALSE)
data_lmm_long_2group.model

coef(data_lmm_long_2group.model)

anova(data_lmm_long_2group.null,data_lmm_long_2group.model) #compare the two models (effect of cohort)

# Random Slopes for Subject

data_lmm_long_2group.null = lmer(rating ~ sex + age + illuminance_level +
                        (1 + cohort_f | subid), data=data_lmm_long_2group, REML=FALSE)
data_lmm_long_2group.model = lmer(rating ~ sex + age + cohort_f + illuminance_level +
                         (1 + cohort_f | subid), data=data_lmm_long_2group, REML=FALSE)
data_lmm_long_2group.model

coef(data_lmm_long_2group.model)

anova(data_lmm_long_2group.null,data_lmm_long_2group.model) #compare the two models (effect of cohort)


#######

#cohort effect
data_lmm_long.null = lmer(rating ~ sex + age + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE) # include random effect for participants to avoid psuedoreplication


data_lmm_long.model = lmer(rating ~ sex + age + cohort_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)
data_lmm_long.model

anova(data_lmm_long.null,data_lmm_long.model) #compare the two models (effect of cohort)

coef(data_lmm_long.model)

#illuminance effect
data_lmm_long.null = lmer(rating ~ sex + age + cohort_f +
                        (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + cohort_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)
data_lmm_long.model

anova(data_lmm_long.null,data_lmm_long.model) #compare the two models (effect of illuminance)



#interaction effect of illuminance x group
data_lmm_long.null = lmer(rating ~ sex + age + cohort_f + illuminance_level +
                        (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + cohort_f * illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)
data_lmm_long.model

anova(data_lmm_long.null,data_lmm_long.model) #compare the two models (effect of illuminance)


#full, all-in-one model
data_lmm_long.model = lmer(rating ~ sex + age + cohort_f + cohort_f * illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
coef(data_lmm_long.model)

library(emmeans)
options(max.print = 999999999)
emmeans(data_lmm_long.model, list(pairwise ~ cohort_f), adjust = "tukey")
emmeans(data_lmm_long.model, list(pairwise ~ illuminance_level), adjust = "tukey")
emmeans(data_lmm_long.model, list(pairwise ~ cohort_f * illuminance_level), adjust = "tukey")