library(DBI)
library(RSQLite)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)	
db.path <- args[1]
# db.path = 'abc.db'

db = dbConnect(SQLite(), dbname = db.path)

q.epi <- dbGetQuery(db,'SELECT * FROM table_epievent')
q.loc <- dbGetQuery(db,'SELECT * FROM table_location')
q.dis <- dbGetQuery(db,'SELECT * FROM table_disease')

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

