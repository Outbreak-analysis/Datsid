library(DBI)
library(RSQLite)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)	
db.path <- args[1]
# db.path = 'datsid.db'  'abc.db'

db = DBI::dbConnect(RSQLite::SQLite(), dbname = db.path)
q.epi <- DBI::dbGetQuery(db,'SELECT * FROM table_epievent')
q.loc <- DBI::dbGetQuery(db,'SELECT * FROM table_location')
q.dis <- DBI::dbGetQuery(db,'SELECT * FROM table_disease')
DBI::dbDisconnect(conn = db)


dat <- q.epi %>%
  left_join(q.loc, by='location_id') %>%
  left_join(q.dis, by='disease_id')

print(dat %>%
          group_by(disease_name) %>%
          summarize(n_datapoints = length(epievent_id),
                    n_sources = length(unique(source))) 
)
x <- dat %>%
          group_by(country, disease_name, source) %>%
          summarize(n_datapoints = length(epievent_id)) %>%
          mutate(source = substr(source,1,16))
print(x)
print(paste(db.path, 'has a total of',prettyNum(sum(x$n_datapoints),big.mark=","),'data points.'))

message('\n [glimpse end] \n')

