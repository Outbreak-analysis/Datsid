source('_utils.R')

# Retrieve raw data:
# dat <- read.csv(file = 'respiratory-canada-phac-raw.csv')
load(file = 'resp-canada.RData')
n <- nrow(dat)

info <- read.csv('respiratory-canada-phac-info.csv', 
                     stringsAsFactors = F,strip.white = T)

# Disease id from ICD:
tmp.dis <- info[info$db_name=='disease_ICD',]
tmp.dis$disease_id <- sapply(tmp.dis$db_val, get.disease.id.icd)
tmp.dis$type <- tmp.dis$name
disease_id_icd <- unlist(left_join(dat,tmp.dis,by='type')$disease_id)

# Disease id from name:
tmp.dis <- info[info$db_name=='disease_name',]
tmp.dis$disease_id <- sapply(tmp.dis$db_val, get.disease.id)
tmp.dis$type <- tmp.dis$name
disease_id_name <- unlist(left_join(dat,tmp.dis,by='type')$disease_id)

z <- rep(NA,n)
idx <- !is.na(disease_id_icd)
z[idx] <- disease_id_icd[idx]
idx <- !is.na(disease_id_name)
z[idx] <- disease_id_name[idx]

# Location ids:
loc.id <- get.location.id(country = rep('CANADA',n), adminDiv1 = '')

# Event type:
tmp.ev <- info[info$db_name=='eventtype',]
tmp.ev$type <- tmp.ev$name
evt <- unlist(left_join(dat, tmp.ev, by='type')$db_val)

# Create data frame for epievent table
df <- create.empty.epievent.df(n)

df$disease_id <- disease_id
df$location_id <- loc.id
df$reportdate <- dat$date
df$count      <- dat$count
df$eventtype  <- evt
df$synthetic  <- 0 
df$source     <- 'PHAC web'

str(df)

fname <- fname.csv.reformated()
write.csv(x = df, file = fname, quote = F, row.names = F)
message(paste('Data saved to',fname))
