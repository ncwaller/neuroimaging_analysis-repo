#! R

# Read SPSS .SAV Files without SPSS
## Designed for any .sav file

# INSTALL RELEVANT PACKAGES
## Haven
#install.packages("haven")
library(haven)

# INPUT DATA
## Set Working Directory
setwd("/Users/noahwaller/Documents/3cohort-GIMME PAPER/raw/mihyst_raw")

## Read in and Convert Data (.sav file)
data_full <- data.frame(read_sav("MiHYST_WPI.sav"))
View(data_full)

## Export the Data Frame to a .csv file
write.csv(data_full, "/Users/noahwaller/Documents/3cohort-GIMME PAPER/raw/mihyst_raw/MiHYST_WPI.csv", row.names=FALSE)

