source('_utils.R')

dat     <- read.csv('ebola-west-africa-2014-USCDC-raw.csv')
dat$var <- as.character(dat$var)

# Retrieve database tables:
tab.dis <- get.disease.table() 
tab.loc <- get.location.table() %>% create.location.key()

idx.dis <- which(tab.dis$disease_name=='ebola')
disease_id <- tab.dis$disease_id[idx.dis]

# Retrieve country names:
sep = '--'
tmp <- strsplit(x = dat$var, split = sep)
dat$cntry <- trimws(sapply(tmp, '[[',2))

# Link to location id:
uc <- unique(dat$cntry)
idx.loc <- vector()
for(i in 1:length(uc)){
    idx.loc[i] <- which(grepl(paste0('__',uc[i]),tab.loc$key))
}
link.loc <- data.frame(cntry = uc, location_id=tab.loc$location_id[idx.loc])
dat <- dat %>%left_join(link.loc, by='cntry')

# Event type
dat$ev <- 'incidence'
dat$ev[grepl('Death', dat$var)] <- 'death'


# Create data frame for epievent table
df <- create.empty.epievent.df(n=nrow(dat))

df$disease_id <- dat$disease_id
df$location_id<- dat$location_id
df$reportdate <- as.Date(dat$WHO.report.date)
df$count      <- dat$val
df$eventtype  <- dat$ev
df$synthetic  <- 0 
df$source     <- 'US CDC'

# Save csv for database import
fname <- fname.csv.reformated()
write.csv(x = df, file = fname, quote = F, row.names = F)
message(paste('Data saved to',fname))

