source('_utils.R')

load('influenza-Australia-DptHealth.RData')

# Retrieve database tables:
tab.dis <- get.disease.table() %>% 
    create.disease.key()
tab.loc <- get.location.table()  %>%
    create.location.key()

dic.dis <- read.csv('influenza-Australia-DptHealth-dictionary-disease.csv', 
                    stringsAsFactors=F, strip.white = T)

#CHANGE NAME FILE!
dic.loc <- read.csv('influenza-Australia-DptHealth-dictionary-location.csv', 
                    stringsAsFactors=F, strip.white = T)

# Check for duplicates in dictionaries:
check.dis <- sum(duplicated(dic.dis))
check.loc <- sum(duplicated(dic.loc))
if(check.dis>0 | check.loc>0){
    message(paste('There are duplicated entries in at least one dictionary. Fix this.'))
    stop()
}


# Identify location and disease IDs:
df.tmp <- left_join(dat, dic.dis, by='type_subtype') %>%
    create.disease.key() %>%
    left_join(tab.dis, by='key') %>%
    # location:
    left_join(dic.loc, by='State') %>%
    create.location.key() %>%
    left_join(tab.loc, by='key')

# Age groups:

df.tmp$age[df.tmp$age=='Unknown'] <- 'NA-NA'
df.tmp$age[df.tmp$age=='85+'] <- '85-130'
a <- df.tmp$age %>% 
    strsplit(split = '-') %>%
    unlist() %>%
    as.character() %>%
    as.numeric() %>%
    matrix(ncol = 2, byrow = TRUE) 

# Create data frame for epievent table
df <- create.empty.epievent.df(nrow = nrow(dat))

df$disease_id <- df.tmp$disease_id
df$location_id<- df.tmp$location_id
df$reportdate <- df.tmp$date
df$count      <- df.tmp$count
df$eventtype  <- df.tmp$eventtype
df$synthetic  <- 0 
df$source     <- 'Australian Department of Health'
df$gender     <- df.tmp$Sex
df$agemin     <- a[,1]
df$agemax     <- a[,2]

fname <- fname.csv.reformated()
write.csv(x = df, file = fname, quote = F, row.names = F)
message(paste('Data saved to',fname))

