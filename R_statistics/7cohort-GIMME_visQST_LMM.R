#! R

# Descriptive Statistics, Correlation Matrices, and Scatterplot Analysis
## Applied to 7 Cohort GIMME Project - visual QST + clinical measures

# ==============================================================================

# Linear Mixed Model template
## Designed for any .csv file, organized by groups of interest in labelled columns

## Read in and Convert Data (.csv file)
### File has been cleaned of any missing data/outliers (listwise deletion)
### Seperate by rating modality, depending on research question
setwd("/Users/noahwaller/Documents/3cohort-GIMME PAPER/csv_for-code")

data_lmm <- data.frame(read.csv("7cohort_visQST_bright_respvnon_forLMM.csv", 
                                 header = T, sep = ","))
View(data_lmm)

## Format sex and cohort as a factor
data_lmm$sex_f <- factor(data_lmm$sex, levels=c(0:1), labels=c("Male", "Female"))
data_lmm$cohort_f <- factor(data_lmm$cohort, levels=c(0:6), labels=c("HC", "RA", "CTS", "OA", "FM", "PSA", "CPP"))
data_lmm$responder_f <- factor(data_lmm$responder_bin, levels=c(0:3), labels=c("Non-responder", "Responder", "HC", "FM"))

## Convert to Long Format
#install.packages("tidyr", repos='http://cran.us.r-project.org')
library(tidyr)

# The arguments to gather():
# - data: Data object
# - key: Name of new key column (made from names of data columns)
# - value: Name of new value column
# - ...: Names of source columns that contain values
# - factor_key: Treat the new key column as a factor (instead of character vector)
data_lmm_long <- gather(data_lmm, illuminance_level, rating, vis01_bright_avg:vis06_bright_avg, factor_key=TRUE)
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


# Subframe into 2 Cohorts
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="HC" | data_lmm_long$cohort_f=="RA",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="HC" | data_lmm_long$cohort_f=="CTS",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="HC" | data_lmm_long$cohort_f=="OA",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="HC" | data_lmm_long$cohort_f=="FM",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="HC" | data_lmm_long$cohort_f=="PSA",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="HC" | data_lmm_long$cohort_f=="CPP",] #

data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="RA" | data_lmm_long$cohort_f=="CTS",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="RA" | data_lmm_long$cohort_f=="OA",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="RA" | data_lmm_long$cohort_f=="FM",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="RA" | data_lmm_long$cohort_f=="PSA",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="RA" | data_lmm_long$cohort_f=="CPP",] #

data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="CTS" | data_lmm_long$cohort_f=="OA",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="CTS" | data_lmm_long$cohort_f=="FM",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="CTS" | data_lmm_long$cohort_f=="PSA",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="CTS" | data_lmm_long$cohort_f=="CPP",] #

data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="OA" | data_lmm_long$cohort_f=="FM",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="OA" | data_lmm_long$cohort_f=="PSA",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="OA" | data_lmm_long$cohort_f=="CPP",] #

data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="FM" | data_lmm_long$cohort_f=="PSA",] #
data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="FM" | data_lmm_long$cohort_f=="CPP",] #

data_lmm_long_2group = data_lmm_long[data_lmm_long$cohort_f=="PSA" | data_lmm_long$cohort_f=="CPP",] #


View(data_lmm_long_2group)


# Subframe into 2 Cohorts (Responder Splits)
data_lmm_long_2group = data_lmm_long[data_lmm_long$responder_f=="HC" | data_lmm_long$responder_f=="FM",] # Sig. both
data_lmm_long_2group = data_lmm_long[data_lmm_long$responder_f=="HC" | data_lmm_long$responder_f=="Non-responder",] # Sig. group
data_lmm_long_2group = data_lmm_long[data_lmm_long$responder_f=="HC" | data_lmm_long$responder_f=="Responder",] # NS

data_lmm_long_2group = data_lmm_long[data_lmm_long$responder_f=="FM" | data_lmm_long$responder_f=="Non-responder",] # Close group, sig. interaction
data_lmm_long_2group = data_lmm_long[data_lmm_long$responder_f=="FM" | data_lmm_long$responder_f=="Responder",] # Sig. both

data_lmm_long_2group = data_lmm_long[data_lmm_long$responder_f=="Non-responder" | data_lmm_long$responder_f=="Responder",] # p = 0.061 for group


View(data_lmm_long_2group)

# LINEAR MIXED EFFECTS MODELS
# Dependent variable: Visual Unpleasantness Rating
# Fixed effects: Cohort, Sex, Age, Illuminance Level
# Random effect: Subject

# data_lmm_long_2group.model = lmer(rating ~ illuminance_level +
                        # (1 + illuminance_level | subid), data=data_lmm_long_2group, REML=FALSE) 
                        # add random slopes for difference in effects of illuminance level between subjects
                        # won't work given number of observations (it's too complicated for the dataset)

# Effect of Cohort

data_lmm_long_2group.null = lmer(rating ~ sex + age + illuminance_level +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE)
                        # add age and sex as fixed effects, and establish null model
                
data_lmm_long_2group.model = lmer(rating ~ sex + age + illuminance_level + cohort_f +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE)
                        # add cohort fixed effect
                        
data_lmm_long_2group.model # check model
anova(data_lmm_long_2group.null,data_lmm_long_2group.model) #compare the two models (effect of cohort between groups)


# Effect of Interaction Between Cohort and Illuminance Level

data_lmm_long_2group.null = lmer(rating ~ sex + age + illuminance_level + cohort_f +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE) 

data_lmm_long_2group.model = lmer(rating ~ sex + age + illuminance_level * cohort_f +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE) 
                        # add interaction term between illuminance level and cohort
                        # includes a random effect for subjects and fixed effect for illuminance level

data_lmm_long_2group.model # check model
anova(data_lmm_long_2group.null,data_lmm_long_2group.model) #compare the two models (effect of interaction between groups)

coef(data_lmm_long_2group.model) # check coefficients


# Effect of Illuminance

data_lmm_long_2group.null = lmer(rating ~ sex + age + cohort_f +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE)
                        # add age and sex as fixed effects, and establish null model
                
data_lmm_long_2group.model = lmer(rating ~ sex + age + illuminance_level + cohort_f +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE)
                        # add cohort fixed effect
                        
data_lmm_long_2group.model # check model
anova(data_lmm_long_2group.null,data_lmm_long_2group.model) #compare the two models (effect of illuminance between groups)



########################################################################################################


# Effect of Responder Status

data_lmm_long_2group.null = lmer(rating ~ sex + age + illuminance_level +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE)
                        # add age and sex as fixed effects, and establish null model
                
data_lmm_long_2group.model = lmer(rating ~ sex + age + illuminance_level + responder_f +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE)
                        # add cohort fixed effect
                        
data_lmm_long_2group.model # check model
anova(data_lmm_long_2group.null,data_lmm_long_2group.model) #compare the two models (effect of cohort between groups)


# Effect of Interaction Between Responder Status and Illuminance Level

data_lmm_long_2group.null = lmer(rating ~ sex + age + illuminance_level + responder_f +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE) 

data_lmm_long_2group.model = lmer(rating ~ sex + age + illuminance_level * responder_f +
                        (1|subid), data=data_lmm_long_2group, REML=FALSE) 
                        # add interaction term between illuminance level and cohort
                        # includes a random effect for subjects and fixed effect for illuminance level

data_lmm_long_2group.model # check model
anova(data_lmm_long_2group.null,data_lmm_long_2group.model) #compare the two models (effect of interaction between groups)

coef(data_lmm_long_2group.model) # check coefficients



########################################################################################################


#full, all-in-one model
## not as useful for comparisons, but can pull the emmeans for tukey post-hocs averaged across cohort or illuminance
data_lmm_long.model = lmer(rating ~ sex + age + cohort_f + cohort_f * illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
coef(data_lmm_long.model)

library(emmeans)
options(max.print = 999999999)
emmeans(data_lmm_long.model, list(pairwise ~ cohort_f), adjust = "tukey")
emmeans(data_lmm_long.model, list(pairwise ~ illuminance_level), adjust = "tukey")
emmeans(data_lmm_long.model, list(pairwise ~ cohort_f * illuminance_level), adjust = "tukey")