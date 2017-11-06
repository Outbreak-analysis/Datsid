source('_utils.R')

dat <- read.csv('ebola-DRC-1995-Khan-raw.csv', 
                header= FALSE,
                comment.char = '#')
dat[,1] <- as.Date(dat[,1])

# Retrieve database tables:
tab.dis <- get.disease.table()
tab.loc <- get.location.table()

df <- create.empty.epievent.df(nrow = nrow(dat))

df$disease_id <- tab.dis$disease_id[tab.dis$disease_name=='ebola']
df$location_id<- tab.loc$location_id[tab.loc$location_name=='Kikwit']
df$reportdate <- dat[,1]
df$count      <- dat[,2]
df$eventtype  <- 'incidence'
df$synthetic  <- 0 
df$source     <- 'Khan et al. 1999;PMID:9988168;DOI:10.1086/514306'

fname <- fname.csv.reformated()
write.csv(x = df, file = fname, quote = F, row.names = F)
message(paste('Data saved to',fname))


