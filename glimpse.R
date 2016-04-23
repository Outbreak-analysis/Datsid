library(DBI)
library(RSQLite)
library(plyr)

args <- commandArgs(trailingOnly = TRUE)	
db.path <- args[1]

db = dbConnect(SQLite(), dbname = db.path)
sqlcmd <- "SELECT * FROM table_epievent,table_disease,table_location
WHERE
table_epievent.disease_id=table_disease.disease_id AND
table_location.location_id=table_epievent.location_id"
q <- dbGetQuery(db,sqlcmd)
dbDisconnect(db)

x <- ddply(q,c('country','disease_name','source'),
		   summarize,
		   n = length(epievent_id))
x$source <- substr(x$source,1,16)
x2 <- x[order(x$country),]
print(x2)
