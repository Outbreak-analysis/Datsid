###
###  Reformat the French sentinelles data
###

source('_utils.R')

# Retrieve raw data:
dat <- read.csv(file = 'influenza-france-sentinelles-1985-2017-raw.csv', 
                comment.char = '#', 
                na.strings = '-')
n <- nrow(dat)

# Reformat
dat$date <- convert.epiweek(dat$week, format='yyyyww')
info <- df.info.file()
disease.id <- get.disease.id(disease.name = info$val[info$name=='disease_name'])
loc.id     <- get.location.id(country = rep('FRANCE',n), 
                              adminDiv1 = dat$geo_name)

# Create data frame for epievent table
df <- create.empty.epievent.df(n)
df$location_id <-loc.id
df$disease_id <- disease.id
df$reportdate <- dat$date
df$count      <- dat$inc
df$eventtype  <- 'incidence'
df$synthetic  <- 0 
df$source     <- 'French sentinelles network - www.sentiweb.fr'

fname <- fname.csv.reformated()
write.csv(x = df, file = fname, quote = F, row.names = F)
message(paste('Data saved to',fname))

if(FALSE){
    ur <- unique(dat$geo_name)
    ur <- paste0('FRANCE,',ur)
    ur <- paste0(120+1:length(ur),',',ur)
    write.table(x = ur,
                file='tmp.csv',
                quote = F, row.names = F)
}
