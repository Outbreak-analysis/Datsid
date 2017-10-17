source('_utils.R')

# Retrieve raw data:
dat <- read.csv(file = 'respiratory-canada-phac-raw.csv')
n <- nrow(dat)

dat$date <- as.Date(dat$date)
#info <- df.info.file()
info <- read.csv('respiratory-canada-phac-info.csv')

unique(dat$type)
get.disease.id.icd('B34.0')


df <- create.empty.epievent.df(n)
loc.id <- get.location.id(country = rep('CANADA',n), adminDiv1 = '')
