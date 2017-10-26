###
###  Reformat the French sentinelles data
###

source('_utils.R')

# Retrieve raw data:
dat <- read.csv(file = 'influenza-france-sentinelles-1985-2017-raw.csv', 
                comment.char = '#', 
                na.strings = '-')
dat$geo_name <- as.character(dat$geo_name)
n <- nrow(dat)

# Change location names according to disctionary:
dic.loc <- read.csv('influenza-france-sentinelles-1985-2017-dictionary-location.csv',
                    stringsAsFactors = F, strip.white = T)
dat <- left_join(dat, dic.loc, by='geo_name') %>%
  mutate(geo_name = ifelse(is.na(location_name),geo_name, location_name))


# Reformat
dat$date <- convert.epiweek(dat$week, format='yyyyww')
info <- df.info.file()
disease.id <- get.disease.id(disease.name = info$val[info$name=='disease_name'])
loc.id     <- get.location.id(country = rep('FR',n), 
                              location_name = dat$geo_name)

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
