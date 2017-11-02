###
###    DOWNLOAD CUMULATIVE INCIDENCE OF WEST AFRICA EBOLA EPIDEMIC FROM US CDC
###

library(readxl)
library(tidyr)
library(dplyr)

# Download from US CDC website:

url <- 'https://www.cdc.gov/vhf/ebola/csv/graph1-cumulative-reported-cases-all.xlsx'
xls.name <- 'ebola-west-africa-2014-USCDC.xlsx'
download.file(url = url, destfile = xls.name)
dat <- read_excel(xls.name)

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
save(list='dat', file='ebola-west-africa.RData')
write.csv(x = dat, 
          file = 'ebola-west-africa-2014-USCDC-raw.csv', 
          quote = FALSE, row.names = FALSE)

message(paste('Ebola data downloaded from',url))


