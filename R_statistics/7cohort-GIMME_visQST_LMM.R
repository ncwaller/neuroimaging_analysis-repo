#! R

# Descriptive Statistics, Correlation Matrices, and Scatterplot Analysis
## Applied to 3 Cohort GIMME Project - visual QST + clinical measures

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


#cohort effect
data_lmm_long.null = lmer(rating ~ sex + age + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

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