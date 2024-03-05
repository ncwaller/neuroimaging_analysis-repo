#! R

# Area Under Curve (AUC) Analysis
## Designed for any .csv file, organized by groups of interest in labelled columns

# INPUT DATA
## Set Working Directory
setwd()

## Read in and Convert Data (.csv file)
data_full <- data.frame(read.csv("file_name.csv", 
                                 header = T, sep = ","))
View(data_full)

# INSTALL PACKAGES
#install.packages("DescTools")
library(DescTools)

# AUC LOOP
auc_range <- 1:146 #specify data range
auc_results <- c() #create empty AUC results vector

## Loop through rows, calculate AUC by subject, and assign AUC to AUC results vector
for(i in auc_range) {
  print(i)
  vis_unpl_AUC = AUC(x=c(0.1, 0.2, 0.4, 0.6, 0.8, 1.0), y=c(data_full[i,5], data_full[i,6], data_full[i,7],
                                                            data_full[i,8], data_full[i,9], data_full[i,10]))
  auc_results <- append(auc_results, vis_unpl_AUC)
}

data_full$auc_results <- auc_results #append AUC results to existing data frame
  

### Other Examples of AUC Parameter Changes ###
AUC(x=c(1,3), y=c(1,1))

AUC(x=c(1,2,3), y=c(1,2,4), method="trapezoid")
AUC(x=c(1,2,3), y=c(1,2,4), method="step")

plot(x=c(1,2,2.5), y=c(1,2,4), type="l", col="blue", ylim=c(0,4))
lines(x=c(1,2,2.5), y=c(1,2,4), type="s", col="red")

x <- seq(0, pi, length.out=200)
AUC(x=x, y=sin(x)) 
AUC(x=x, y=sin(x), method="spline") 
