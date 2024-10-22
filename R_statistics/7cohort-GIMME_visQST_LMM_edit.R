#! R

# Descriptive Statistics, Correlation Matrices, and Scatterplot Analysis
## Applied to 7 Cohort GIMME Project - visual QST + clinical measures

# ==============================================================================

# Linear Mixed Model template
## Designed for any .csv file, organized by groups of interest in labelled columns

## Read in and Convert Data (.csv file)
### File has been cleaned of any missing data/outliers (listwise deletion)
### Seperate by rating modality, depending on research question
setwd("/Users/noahwaller/Documents/VISUAL-QST-7cohort PAPER/csv_for-code")

data_lmm <- data.frame(read.csv("visqst_unpl-only_noHCFM_tx-resp_cov-fmscore_outrem_forLMM.csv", # unpleasantness
                                 header = T, sep = ","))

data_lmm <- data.frame(read.csv("visqst_bright-only_noHCFM_tx-resp_cov-fmscore_outrem_forLMM.csv", # brightness
                                 header = T, sep = ","))

data_lmm <- data.frame(read.csv("thumbqst_noHCFM_tx-resp_cov-fmscore_outrem_forLMM.csv", # thumb
                                 header = T, sep = ","))
View(data_lmm)

## Format sex and cohort as a factor
data_lmm$sex_f <- factor(data_lmm$sex, levels=c(1:2), labels=c("Male", "Female"))
data_lmm$cohort_f <- factor(data_lmm$cohort, levels=c(0:6), labels=c("HC", "RA", "CTS", "OA", "CPP", "PSA", "FM"))
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

data_lmm_long <- gather(data_lmm, illuminance_level, rating, vis01_unpl_avg:vis06_unpl_avg, factor_key=TRUE) # unpleasantness

data_lmm_long <- gather(data_lmm, illuminance_level, rating, vis01_bright_avg:vis06_bright_avg, factor_key=TRUE) # brightness

data_lmm_long <- gather(data_lmm, pressure_level, rating, thumb01_avg:thumb06_avg, factor_key=TRUE) # brightness

data_lmm_long = data_lmm_long[order(data_lmm_long$subid),] # sort by subid

View(data_lmm_long)


# INSTALL
#install.packages("lme4", repos='http://cran.us.r-project.org')
#install.packages("merDerive", repos='http://cran.us.r-project.org') #deprecated
#install.packages("ggeffects", repos='http://cran.us.r-project.org')
#install.packages("DescTools", repos='http://cran.us.r-project.org')
#install.packages("effectsize", repos='http://cran.us.r-project.org')
#install.packages("esc", repos='http://cran.us.r-project.org')
library(esc) 
library(lme4) 
#library(merDeriv) #deprecated
library(ggeffects) 
#library(DescTools)
#library(effectsize) 

##########################################################################################################

# LINEAR MIXED EFFECTS MODELS
# Dependent variable: Visual Unpleasantness Rating
# Fixed effects: Cohort, Sex, Age, Illuminance Level
# Random effect: Subject


# data_lmm_long_2group.model = lmer(rating ~ illuminance_level +
                        # (1 + illuminance_level | subid), data=data_lmm_long_2group, REML=FALSE) 
                        # add random slopes for difference in effects of illuminance level between subjects
                        # won't work given number of observations (it's too complicated for the dataset)


#########################################################################################################
# COHORT #
#########################################################################################################

# Full Model (Cohort) (Don't Include interaction Term for Mult Comp)
full_model = lmer(rating ~ sex + age + cohort_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)
summary(full_model)
anova(full_model)
coef(full_model)
confint(full_model, level=0.95)
EtaSq(full_model)

# Test for Significance of Main Effects/Interaction Effects (NOT Multi Comp)
# Cohort (Main Effect)
data_lmm_long.null = lmer(rating ~ sex + age + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + cohort_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)
esc_chisq(chisq = 24.068, totaln = 238, es.type = "d") # calculate effect size for model comparison - set at Cohen's d

# Illuminance (Main Effect)
data_lmm_long.null = lmer(rating ~ sex + age + cohort_f +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + cohort_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)
esc_chisq(chisq = 300, totaln = 239, es.type = "d")

# Interaction (Cohort X Illuminance)
data_lmm_long.null = lmer(rating ~ sex+  age + cohort_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + cohort_f * illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)
esc_chisq(chisq = 74.946, totaln = 238, es.type = "d")


# Multiple Pairwise Comparisons
#install.packages("multcomp", repos='http://cran.us.r-project.org')
#install.packages("emmeans", repos='http://cran.us.r-project.org')
library(multcomp)
library(emmeans)

# running glht()
post.hoc <- glht(full_model, linfct = mcp(cohort_f = 'Tukey'))
summary(post.hoc)

# running emmeans
emmeans(full_model, list(pairwise ~ cohort_f), adjust = "tukey")
emmeans(full_model, list(pairwise ~ illuminance_level), adjust = "tukey")
emmeans(full_model, list(pairwise ~ cohort_f * illuminance_level), adjust = "tukey")


#########################################################################################################
# TX RESPONSE #
#########################################################################################################

# Full Model (Tx Response)
full_model = lmer(rating ~ sex + age + responder_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)
anova(full_model)
coef(full_model)
confint(full_model, level=0.95)


# Test for Significance of Main Effects/Interaction Effects (NOT Multi Comp)
# Cohort (Main Effect)
data_lmm_long.null = lmer(rating ~ sex + age + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + responder_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)

# Illuminance (Main Effect)
data_lmm_long.null = lmer(rating ~ sex + age + responder_f +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + responder_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)

# Interaction (Cohort X Illuminance)
data_lmm_long.null = lmer(rating ~ sex+  age + responder_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + responder_f * illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)


# Multiple Pairwise Comparisons
#install.packages("multcomp", repos='http://cran.us.r-project.org')
#install.packages("emmeans", repos='http://cran.us.r-project.org')
library(multcomp)
library(emmeans)

# running glht()
post.hoc <- glht(full_model, linfct = mcp(responder_f = 'Tukey'))
summary(post.hoc)

# running emmeans
emmeans(full_model, list(pairwise ~ responder_f), adjust = "tukey")
emmeans(full_model, list(pairwise ~ illuminance_level), adjust = "tukey")
emmeans(full_model, list(pairwise ~ responder_f * illuminance_level), adjust = "tukey")





#########################################################################################################
# TX RESPONSE - INCLUDING FM SCORE #
#########################################################################################################

# Full Model (Tx Response)
full_model = lmer(rating ~ sex + age + fm_score_bsl + responder_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)
anova(full_model)
coef(full_model)
confint(full_model, level=0.95)


# Test for Significance of Main Effects/Interaction Effects (NOT Multi Comp)
# Cohort (Main Effect)
data_lmm_long.null = lmer(rating ~ sex + age + fm_score_bsl + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + fm_score_bsl + responder_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)
esc_chisq(chisq = 8.2115, totaln = 113, es.type = "d") # calculate effect size for model comparison - set at Cohen's d

# FM Score (Main Effect)
data_lmm_long.null = lmer(rating ~ sex + age + responder_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + fm_score_bsl + responder_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)

# Illuminance (Main Effect)
data_lmm_long.null = lmer(rating ~ sex + age + fm_score_bsl + responder_f +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + fm_score_bsl + responder_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)

# Interaction (Cohort X Illuminance)
data_lmm_long.null = lmer(rating ~ sex+  age + fm_score_bsl + responder_f + illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + fm_score_bsl + responder_f * illuminance_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)


# Multiple Pairwise Comparisons
#install.packages("multcomp", repos='http://cran.us.r-project.org')
#install.packages("emmeans", repos='http://cran.us.r-project.org')
library(multcomp)
library(emmeans)

# running glht()
post.hoc <- glht(full_model, linfct = mcp(responder_f = 'Tukey'))
summary(post.hoc)

# running emmeans
emmeans(full_model, list(pairwise ~ responder_f), adjust = "tukey")
emmeans(full_model, list(pairwise ~ illuminance_level), adjust = "tukey")
emmeans(full_model, list(pairwise ~ responder_f * illuminance_level), adjust = "tukey")





#########################################################################################################
# TX RESPONSE - INCLUDING FM SCORE # FOR THUMB #
#########################################################################################################

# Full Model (Tx Response)
full_model = lmer(rating ~ sex + age + fm_score_bsl + responder_f + pressure_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)
anova(full_model)
coef(full_model)
confint(full_model, level=0.95)


# Test for Significance of Main Effects/Interaction Effects (NOT Multi Comp)
# Cohort (Main Effect)
data_lmm_long.null = lmer(rating ~ sex + age + fm_score_bsl + pressure_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + fm_score_bsl + responder_f + pressure_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)

# FM Score (Main Effect)
data_lmm_long.null = lmer(rating ~ sex + age + responder_f + pressure_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + fm_score_bsl + responder_f + pressure_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)

# Illuminance (Main Effect)
data_lmm_long.null = lmer(rating ~ sex + age + fm_score_bsl + responder_f +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + fm_score_bsl + responder_f + pressure_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)

# Interaction (Cohort X Illuminance)
data_lmm_long.null = lmer(rating ~ sex+  age + fm_score_bsl + responder_f + pressure_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model = lmer(rating ~ sex + age + fm_score_bsl + responder_f * pressure_level +
                         (1|subid), data=data_lmm_long, REML=FALSE)

data_lmm_long.model
anova(data_lmm_long.null,data_lmm_long.model)


# Multiple Pairwise Comparisons
#install.packages("multcomp", repos='http://cran.us.r-project.org')
#install.packages("emmeans", repos='http://cran.us.r-project.org')
library(multcomp)
library(emmeans)

# running glht()
post.hoc <- glht(full_model, linfct = mcp(responder_f = 'Tukey'))
summary(post.hoc)

# running emmeans
emmeans(full_model, list(pairwise ~ responder_f), adjust = "tukey")
emmeans(full_model, list(pairwise ~ illuminance_level), adjust = "tukey")
emmeans(full_model, list(pairwise ~ responder_f * illuminance_level), adjust = "tukey")