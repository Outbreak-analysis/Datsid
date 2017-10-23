library(DBI)
library(RSQLite)

args <- commandArgs(trailingOnly = TRUE)
if (length(args)<1) stop("Not enough arguments!")
db.name <- args[1]
 # db.name <- "abc.db"

csvlist <- system("ls ./data/*.csv",intern = TRUE)

# Connect to the database
db = dbConnect(SQLite(), dbname=db.name)

# Tables setup: location, disease 
table.location <- read.csv("tables/table_location.csv", stringsAsFactors = F)
table.disease <- read.csv("tables/table_disease.csv", stringsAsFactors = F)

check.loc <- dbWriteTable(db,"table_location", table.location, append=TRUE)
check.dis <- dbWriteTable(db,"table_disease", table.disease, append=TRUE)

success <- (check.loc & check.dis)

if(success){
  message('Tables for location and diseases successfully added to database')
}
if(!success){
  message('Cannot add tables to database... ABORTING!')
  stop()
}

## Import new data in existing database:
for(i in 1:length(csvlist)){
	newdat <- read.csv(file = csvlist[i], header = TRUE)
	dbWriteTable(db,"tmp_epievent", newdat, append=TRUE)
	
	message(paste0("Data in ",
				   csvlist[i],
				   " successfuly added to database (",
				   nrow(newdat),
				   " new rows)."))
}

# write data in final table:
field.names <- dbListFields(db, "tmp_epievent")
field.names2 <- paste(field.names,collapse = ",")
q <- paste0("INSERT INTO table_epievent(",
			field.names2,
			") SELECT * FROM tmp_epievent;")
dbSendQuery(db,q)

# Disconnect when finish querying the database:
dbDisconnect(db)


