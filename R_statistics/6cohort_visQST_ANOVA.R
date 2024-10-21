#! R

# ANOVA for comparisons between cohorts and responder-status
## Applied to 6 Cohort visQST Project - visual QST + clinical measures

## Additional script here required for calculating effect sizes of multiple comparisons - not possible in Prism

# INPUT DATA
setwd("/Users/noahwaller/Documents/VISUAL-QST-7cohort PAPER/csv_for-code/anova")

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("promis_anx_noCPP.csv", 
                                 header = T, sep = ","))
View(data_full)

data_full$cohort_f <- factor(data_full$cohort, levels=c(0:4), labels=c("HC", "RA", "OA", "PSA", "FM")) # CHANGED TO REMOVE CPP TRIPLE CHECK ALWAYS

####install.packages("esvis", repos='http://cran.us.r-project.org')
library(esvis)

data_full%>%
  #ungroup(Group)%>% # Include this line if you get grouping error
coh_d(promis_anx ~ cohort_f)
