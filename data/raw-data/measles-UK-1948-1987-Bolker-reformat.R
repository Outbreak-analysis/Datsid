source('_utils.R')

load('measles-UK-1948-1987-Bolker.RData')
dat <- dat2

# Retrieve database tables:
tab.dis <- get.disease.table()
tab.loc <- get.location.table()  %>%
    create.location.key()

dic.loc <- read.csv('measles-UK-1948-1987-Bolker-dictionary-location.csv', 
                    stringsAsFactors=F, strip.white = T)

dat$disease_name = 'measles'

# Identify location and disease IDs:
df.tmp <- dat %>%
    left_join(tab.dis, by='disease_name') %>%
    # location:
    # location:
    left_join(dic.loc, by='city') %>%
    create.location.key() %>%
    left_join(tab.loc, by='key')

# Create data frame for epievent table
n <- nrow(dat)
df <- create.empty.epievent.df(n)

df$disease_id <- df.tmp$disease_id
df$location_id<- df.tmp$location_id
df$reportdate <- df.tmp$date
df$count      <- df.tmp$count
df$eventtype  <- df.tmp$eventtype
df$synthetic  <- 0 
df$source     <- 'Bolker webpage'

fname <- fname.csv.reformated()
write.csv(x = df, file = fname, quote = F, row.names = F)
message(paste('Data saved to',fname))


