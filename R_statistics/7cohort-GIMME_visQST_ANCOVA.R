#! R

# ANCOVA for controlling for sex, age, and baseline pain in comparisons between cohorts and responder-status
## Applied to 7 Cohort GIMME Project - visual QST + clinical measures

## ANCOVA is simply an ANOVA that includes at least one covariate 
## DV is a continuous variable (visual unpleasantness), at least one categorical grouping variable (responder or cohort)
## and at least one continuous covariate (age and baseline PD02)
## likely, this covariate of interest relates to the DV... if it's unrelated, an ANOVA would suffice

# INPUT DATA
setwd("/Users/noahwaller/Documents/VISUAL-QST-7cohort PAPER/csv_for-code")

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("all_visqst+clinical_bsl.csv", 
                                 header = T, sep = ","))
View(data_full)

## Format sex and cohort as a factor
data_full$sex_f <- factor(data_full$sex, levels=c(0:1), labels=c("Male", "Female"))
data_full$cohort_f <- factor(data_full$cohort, levels=c(0:6), labels=c("HC", "RA", "CTS", "OA", "CPP", "PSA", "FM"))
data_full$responder_f <- factor(data_full$responder_bin, levels=c(0:1), labels=c("Non-responder", "Responder"))

## Create subframe based on baseline PDQ02 of 3 or greater
data_bslpd02_subset = data_full[data_full$pd02_bsl>=3,]

# ASSUMPTIONS (BY GROUP)
## Normality
#####install.packages("pastecs", repos='http://cran.us.r-project.org')
#####install.packages("httpgd", repos='http://cran.us.r-project.org')

## Basic check to see if the covariate and DV are related at all 
#cor.test(data_bslpd02_subset$fm_score_bsl, data_bslpd02_subset$pd02_bsl, method = "pearson")
cor.test(data_full$sex, data_full$vis_unpl_avg, method = "pearson")
cor.test(data_full$age, data_full$vis_unpl_avg, method = "pearson") # age is related to avg vis unpl

cor.test(data_full$sex, data_full$vis_bright_avg, method = "pearson")
cor.test(data_full$age, data_full$vis_bright_avg, method = "pearson") # not the case for brightness

cor.test(data_full$sex, data_full$fm_score, method = "pearson")
cor.test(data_full$age, data_full$fm_score, method = "pearson") 

library(pastecs)
### For IV
by(data_full$vis_unpl_avg, data_full$responder_f, stat.desc, norm = TRUE)
### For covariate
stat.desc(data_full$pd02_bsl)

## Homogeneity of Variance
boxplot(data_bslpd02_subset$fm_score_bsl~data_bslpd02_subset$responder_f)

## Covariate-IV Independence
### Test for significant IV differences in covariate
assump_ind <- aov(pd02_bsl ~ responder_f, data = data_bslpd02_subset)
summary(assump_ind)

## Homogeneity of Slopes
### Preview ANCOVA with IV*covariate interaction term
assump_slope <- aov(fm_score_bsl ~ responder_f * pd02_bsl, data = data_full)
summary(assump_slope)

## Alternate
m1 <- lm(fm_score_bsl ~ pd02_bsl + responder_f, data = data_bslpd02_subset)
m2 <- lm(fm_score_bsl ~ pd02_bsl * responder_f, data = data_bslpd02_subset)
anova(m1, m2)


# RUNNING ANCOVA

#####install.packages("tidyverse", repos='http://cran.us.r-project.org')
#####install.packages("ggpubr", repos='http://cran.us.r-project.org')
#####install.packages("rstatix", repos='http://cran.us.r-project.org')
#####install.packages("broom", repos='http://cran.us.r-project.org')
library(tidyverse)
library(ggpubr)
library(rstatix)
library(broom)

## ANCOVA Function
res.aov <- data_full %>% anova_test(vis_unpl_avg ~ age + cohort_f)
get_anova_table(res.aov)

# Pairwise comparisons
#####install.packages("emmeans", repos='http://cran.us.r-project.org')
library(emmeans)

pwc <- data_full %>% 
  emmeans_test(
    vis_unpl_avg ~ cohort_f, covariate = age,
    p.adjust.method = "tukey"
    )
pwc 
print(pwc, n = 21)

################################################################################################

## Alternate ANOVA vs ANCOVA Workflow (LMs) (allows for comparison of R2, etc)

summary(lm(fm_score_bsl ~ responder_f, data=data_bslpd02_subset)) # ANOVA

summary(lm(fm_score_bsl ~ pd02_bsl + responder_f, data=data_bslpd02_subset)) # ANCOVA


#####install.packages("car", repos='http://cran.us.r-project.org')
library(car)

# getting the sums squared for each effect using the ANOVA function from the car package
sstable <- car::Anova(lm(fm_score_bsl ~ pd02_bsl + responder_f, data=data_bslpd02_subset), type = 3)
# partial eta squared:
sstable$pes <- c(sstable$'Sum Sq'[-nrow(sstable)], NA)/(sstable$'Sum Sq' + sstable$'Sum Sq'[nrow(sstable)]) # SS for each effect divided by the last SS (SS_residual)
sstable

# Useful for determining the impact that each component has on the DV - PES size depends on the field, but .15 is pretty good



################################################################################################

## Alternate ANCOVA Workflow

# ANCOVA (Type I SS is the default)
## Without Covariate for Comparison
anova_comp <- aov(vis_unpl_avg ~ responder_f, data = data_full)
summary(anova_comp) # no group difference - so what if we control for baseline pain

## Order Matters & No Interaction
ancova1 <- aov(vis_unpl_avg ~ pd02_bsl + responder_f, data = data_full)
summary(ancova1) #can calculate partial eta squared here
summary.lm(ancova1) #uses orthogonal contrasts; covariate significance changes

## Use Type III SS 
library(car)
Anova(ancova1, type = "III")

## Post-hoc Tests & Adjusted Means
#####install.packages("rstatix")
library(rstatix)
?emmeans_test

### Conduct post hoc tests with Bonferoni adjustment
posthoc <- emmeans_test(vis_unpl_avg ~ responder_f, covariate = pd02_bsl,
                        p.adjust.method = "bonferroni", data=data_full)
posthoc
### Request estimated marginal (i.e., covariate-adjusted) means
attr(posthoc, "emmeans")  
