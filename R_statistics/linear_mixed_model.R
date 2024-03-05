#! R

# Linear Mixed Model template
## Designed for any .csv file, organized by groups of interest in labelled columns

# ============================================================================== 

install.packages("lme4")
install.packages("merDerive")
install.packages("ggeffects")

library(lme4) 
library(merDeriv) 
library(ggeffects) 

setwd()

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("file_name.csv", 
                                 header = T, sep = ","))
View(data_full)

cohortf <- factor(data_full$cohort, levels = c(1:5), labels = c("HC", "CTS", "RA", "OA", "FM"))
illuminance_levelf <- factor(data_full$illuminance_level, levels = c(1:6), labels = c("1", "2", "3", "4", "5", "6"))

#cohort effect
data_full.null = lmer(bright_rating ~ sex + age + illuminance_level +
                         (1|subid), data=data_full, REML=FALSE)

data_full.model = lmer(bright_rating ~ sex + age + cohortf + illuminance_level +
                         (1|subid), data=data_full, REML=FALSE)
data_full.model

anova(data_full.null,data_full.model) #compare the two models (effect of cohort)

coef(data_full.model)

#illuminance effect
data_full.null = lmer(bright_rating ~ sex + age + cohortf +
                        (1|subid), data=data_full, REML=FALSE)

data_full.model = lmer(bright_rating ~ sex + age + cohortf + illuminance_level +
                         (1|subid), data=data_full, REML=FALSE)
data_full.model

anova(data_full.null,data_full.model) #compare the two models (effect of illuminance)



#interaction effect of illuminance x group
data_full.null = lmer(bright_rating ~ sex + age + cohortf + illuminance_level +
                        (1|subid), data=data_full, REML=FALSE)

data_full.model = lmer(bright_rating ~ sex + age + cohortf * illuminance_level +
                         (1|subid), data=data_full, REML=FALSE)
data_full.model

anova(data_full.null,data_full.model) #compare the two models (effect of illuminance)


#full, all-in-one model
data_full.model = lmer(bright_rating ~ sex + age + cohortf + cohortf * illuminance_levelf +
                         (1|subid), data=data_full, REML=FALSE)

data_full.model
coef(data_full.model)

library(emmeans)
options(max.print = 999999999)
emmeans(data_full.model, list(pairwise ~ cohortf), adjust = "tukey")
emmeans(data_full.model, list(pairwise ~ illuminance_levelf), adjust = "tukey")
emmeans(data_full.model, list(pairwise ~ cohortf * illuminance_levelf), adjust = "tukey")


