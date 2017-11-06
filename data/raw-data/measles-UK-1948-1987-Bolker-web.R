
#http://ms.mcmaster.ca/~bolker/measdata.html


library(lubridate)
library(dplyr)
library(tidyr)
library(snowfall)
library(ggplot2)
library(RCurl)
# library(XML)

# Import from web:
url_root <- 'http://ms.mcmaster.ca/~bolker/measdata/ewcitmeas.dat'
a   <- getURL(url_root)
dat <- read.table(textConnection(a), sep = '')
h   <- unlist(strsplit(readLines(url_root)[1],split = ' '))
names(dat) <- h


# Clean up:
# dat[dat=='*'] <- NA
for(i in 1:ncol(dat)) {
    dat[,i] <- as.integer(as.character(dat[,i]))
}

# Convert to date:
dat$date <- as.Date(paste0('19',dat$YY,'-',dat$MM,'-',dat[,'#DD']))

# Tall skiny format:
dat2 <- dat %>% 
    gather(key = 'city', value = 'count', 4:10) %>%
    select(date,city,count)

do.plot <- FALSE
if(do.plot){
    plot(
        ggplot(dat2)+
            geom_line(aes(x=date, y=count)) + 
            facet_wrap(~city, scales = 'free')
    )
}

write.csv(x = dat2, file = 'measles-UK-1948-1987-Bolker-raw.csv')
save( list = 'dat2', file = 'measles-UK-1948-1987-Bolker.RData')

