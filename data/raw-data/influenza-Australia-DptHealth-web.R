library(readxl)
library(tidyr)
library(dplyr)
library(ggplot2)

# Download from US CDC website:

url <- 'http://www9.health.gov.au/cda/source/display_doc.cfm?DocID=1'
xls.name <- 'influenza-Australia-DptHealth.xlsx'
download.file(url = url, destfile = xls.name)
dat <- read_excel(xls.name, 
                  sheet = 'Flu Public Dataset', 
                  na = 'not available',
                  skip = 1)
dat$date <- dat$`Week Ending (Friday)`
dat$age <- dat$`Age  group`
dat$indigenous <- dat$`Indigenous status`
dat$type_subtype <- dat$`Type/Subtype`
dat$dummy <- rep(1,nrow(dat))

# Create the '-raw.csv' file
dat <- dat %>%
    group_by(date, State, age, Sex, indigenous, type_subtype) %>%
    summarise(count = sum(dummy))

do.plot<-FALSE
if(do.plot){
    dat %>%
        group_by(date, State) %>%
        summarise(count2 = sum(count)) %>%
        ggplot() + 
        geom_line(aes(x=date, y=count2)) +
        facet_wrap(~State, scales='free')
}

write.csv(dat,file = 'influenza-Australia-DptHealth-raw.csv' )
save(list = 'dat',file = 'influenza-Australia-DptHealth.RData')

