###
### Convert Excel file to CSV
###

library(readxl)
library(tidyr)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2)
    stop("usage: Rscript raw_csv.R xlsFile csvFile")
xlsFile <- args[1]
csvFile <- args[2]

dat <- read_excel(xlsFile)

# Create the '-raw.csv' file
nm <- names(dat)
nc <- ncol(dat)

for(k in 2:nc){
  tmp <- c(0,diff(unlist(dat[,k])))
  dat <- cbind(dat,tmp)
  names(dat)[ncol(dat)] <- gsub('Total','incidence',names(dat)[k])
}

dat <- dat %>%
  gather('var','val',2:ncol(dat)) %>%
  filter(grepl('incidence',var))
# Get rid of the comma, as it confuses with a new column in csv format:
dat$var <- gsub(',','--',x = dat$var, fixed = TRUE)

# Save for downstream use:  
write.csv(x = dat, 
          file = csvFile,
          quote = FALSE, row.names = FALSE)
