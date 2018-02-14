library(DBI)
library(RSQLite)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)	
db.path <- args[1]
# DEBUG
db.path = 'datsid.db'  #'abc.db'

db = DBI::dbConnect(RSQLite::SQLite(), dbname = db.path)
q.epi <- DBI::dbGetQuery(db,'SELECT * FROM table_epievent')
q.loc <- DBI::dbGetQuery(db,'SELECT * FROM table_location')
q.dis <- DBI::dbGetQuery(db,'SELECT * FROM table_disease')
DBI::dbDisconnect(conn = db)


dat <- q.epi %>%
    left_join(q.loc, by='location_id') %>%
    left_join(q.dis, by='disease_id')

dat$reportdate <- as.Date(dat$reportdate)

epi <- dat %>%
    group_by(country, 
             location_name, 
             source,
             disease_name,
             disease_type,
             disease_subtype,
             disease_subtype2,
             eventtype,
             eventtype2) %>%
    summarize(n = length(epievent_id),
              date1 = min(reportdate),
              date2 = max(reportdate))


