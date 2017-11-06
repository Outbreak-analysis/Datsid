source('_utils.R')

# Retrieve raw data:
# dat <- read.csv(file = 'respiratory-canada-phac-raw.csv')
load(file = 'resp-canada.RData')
n <- nrow(dat)

# Load dictionary for this data set:
dic.dis <- read.csv('respiratory-canada-phac-dictionary-disease.csv', 
                stringsAsFactors=F, strip.white = T)

dic.loc <- read.csv('respiratory-canada-phac-dictionary-location.csv', 
                    stringsAsFactors=F, strip.white = T)

# Check for duplicates in dictionaries:
check.dis <- sum(duplicated(dic.dis))
check.loc <- sum(duplicated(dic.loc))
if(check.dis>0 | check.loc>0){
    message(paste('There are duplicated entries in at least one dictionary. Fix this.'))
    stop()
}


# remove French characters:
dat$regions     <- anglicize(dat$regions)
dic.loc$regions <- anglicize(dic.loc$regions)
dic.loc$location_name <- anglicize(dic.loc$location_name)

# Retrieve database tables:
tab.dis <- get.disease.table() %>% 
    create.disease.key()
tab.loc <- get.location.table() %>%
    create.location.key()
tab.loc$regions <- tab.loc$location_name

# Identify location and disease IDs:
df.tmp <- left_join(dat, dic.dis, by='type') %>%
    create.disease.key() %>%
    left_join(tab.dis, by='key') %>%
    # location:
    left_join(dic.loc, by='regions') %>%
    create.location.key() %>%
    left_join(tab.loc, by='key')

# DEBUG:
# a <- df.tmp[is.na(df.tmp$disease_id),]
# unique(a$type)
# write.csv(file = 'toto.csv',x = dat$type[grepl('PIV',dat$type)])

# Create data frame for epievent table
df <- create.empty.epievent.df(n)

df$disease_id <- df.tmp$disease_id
df$location_id<- df.tmp$location_id
df$reportdate <- df.tmp$date
df$count      <- df.tmp$count
df$eventtype  <- df.tmp$eventtype
df$synthetic  <- 0 
df$source     <- 'PHAC web'

fname <- fname.csv.reformated()
write.csv(x = df, file = fname, quote = F, row.names = F)
message(paste('Data saved to',fname))


