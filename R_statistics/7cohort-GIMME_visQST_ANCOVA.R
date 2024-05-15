#! R

# ANCOVA for controlling for sex, age, and baseline pain in comparisons between cohorts and responder-status
## Applied to 7 Cohort GIMME Project - visual QST + clinical measures

## ANCOVA is simply an ANOVA that includes at least one covariate 
## DV is a continuous variable (visual unpleasantness), at least one categorical grouping variable (responder or cohort)
## and at least one continuous covariate (age and baseline PD02)
## likely, this covariate of interest relates to the DV... if it's unrelated, an ANOVA would suffice

# INPUT DATA
setwd("/Users/noahwaller/Documents/3cohort-GIMME PAPER/csv_for-code")

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("7cohort_visQST_allmetrics_outrem.csv", 
                                 header = T, sep = ","))
View(data_full)

## Format sex and cohort as a factor
data_full$sex_f <- factor(data_full$sex, levels=c(0:1), labels=c("Male", "Female"))
data_full$cohort_f <- factor(data_full$cohort, levels=c(0:6), labels=c("HC", "RA", "CTS", "OA", "FM", "PSA", "CPP"))
data_full$responder_f <- factor(data_full$responder_bin, levels=c(0:1), labels=c("Non-responder", "Responder"))


# ASSUMPTIONS (BY GROUP)
## Normality
library(pastecs)
### For IV
by(data_full$vis_unpl_avg, data_full$responder_f, stat.desc, norm = TRUE)
### For covariate
stat.desc(data_full$pd02_bsl)

## Homogeneity of Variance
boxplot(data_full$vis_unpl_avg~data_full$responder_f)

## Covariate-IV Independence
### Test for significant IV differences in covariate
assump_ind <- aov(pd02_bsl ~ responder_f, data = data_full)
summary(assump_ind)

## Homogeneity of Slopes
### Preview ANCOVA with IV*covariate interaction term
assump_slope <- aov(vis_unpl_avg ~ responder_f * pd02_bsl, data = data_full)
summary(assump_slope)


# CONTRASTS
## Prioritize Orthogonality
contrasts(data_full$responder_f) <- cbind(-1, 1) # tough to understand
data_full$responder_f


# ANCOVA (remember Type I SS is the default)
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
