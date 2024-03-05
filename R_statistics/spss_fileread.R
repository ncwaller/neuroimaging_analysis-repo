#! R

# Read SPSS .SAV Files without SPSS
## Designed for any .sav file

# INSTALL RELEVANT PACKAGES
## Haven
#install.packages("haven")
library(haven)

# INPUT DATA
## Set Working Directory
setwd()

## Read in and Convert Data (.sav file)
data_full <- data.frame(read_sav("file_name.sav"))
View(data_full)

## Export the Data Frame to a .csv file
write.csv(data_full, "/path/file_exported.csv", row.names=FALSE)

