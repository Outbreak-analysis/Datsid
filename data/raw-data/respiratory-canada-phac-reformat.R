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


# Create data frame for epievent table
df <- create.empty.epievent.df(n)

df$disease_id <- df.tmp$disease_id
df$location_id<- df.tmp$location_id
df$reportdate <- df.tmp$date
df$count      <- df.tmp$count
df$eventtype  <- df.tmp$eventtype
df$synthetic  <- 0 
df$source     <- 'PHAC web'

str(df)

fname <- fname.csv.reformated()
write.csv(x = df, file = fname, quote = F, row.names = F)
message(paste('Data saved to',fname))



# 
# 
# stop()
# 
# # -----
# info <- read.csv('respiratory-canada-phac-info.csv', 
#                      stringsAsFactors = F,strip.white = T)
# 
# # Disease id from ICD:
# tmp.dis <- info[info$db_name=='disease_ICD',]
# tmp.dis$disease_id <- sapply(tmp.dis$db_val, get.disease.id.icd)
# tmp.dis$type <- tmp.dis$name
# disease_id_icd <- unlist(left_join(dat,tmp.dis,by='type')$disease_id)
# 
# # Disease id from name:
# tmp.dis <- info[info$db_name=='disease_name',]
# tmp.dis$disease_id <- sapply(tmp.dis$db_val, get.disease.id)
# tmp.dis$type <- tmp.dis$name
# disease_id_name <- unlist(left_join(dat,tmp.dis,by='type')$disease_id)
# 
# z <- rep(NA,n)
# idx <- !is.na(disease_id_icd)
# z[idx] <- disease_id_icd[idx]
# idx <- !is.na(disease_id_name)
# z[idx] <- disease_id_name[idx]
# 
# # Location ids:
# loc.id <- get.location.id(country = rep('CANADA',n), adminDiv1 = '')
# 
# # Event type:
# tmp.ev <- info[info$db_name=='eventtype',]
# tmp.ev$type <- tmp.ev$name
# evt <- unlist(left_join(dat, tmp.ev, by='type')$db_val)
# 
# 
