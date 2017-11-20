library(DBI)
library(RSQLite)

args <- commandArgs(trailingOnly = TRUE)
if (length(args)<1) stop("Not enough arguments!")
db.name <- args[1]
 # db.name <- "datsid.db"

csvlist <- system("ls ./data/*-db.csv",intern = TRUE)

# Connect to the database
db = dbConnect(SQLite(), dbname=db.name)

# Tables setup: location, disease 
table.location <- read.csv("tables/table_location.csv", stringsAsFactors = F)
table.disease <- read.csv("tables/table_disease.csv", stringsAsFactors = F)

check.loc <- dbWriteTable(db,"table_location", table.location, append=TRUE)
check.dis <- dbWriteTable(db,"table_disease", table.disease, append=TRUE)

success <- (check.loc & check.dis)

if(success){
  message(paste('\n ==> table_location and table_disease successfully added to database\n ',
                db.name))
}
if(!success){
  message('Cannot add tables to database... ABORTING!')
  stop()
}

## Import new data in existing database:
for(i in 1:length(csvlist)){
	
    message(paste('Reading',csvlist[i],'...'))
    newdat <- read.csv(file = csvlist[i], header = TRUE)
	
	# print(head(newdat))
    stopifnot(length(names(newdat)) == 13)
	
	dbWriteTable(db,"tmp_epievent", newdat, append=TRUE)
	
	message(paste0("Data in ",
				   csvlist[i],
				   " successfuly added to database (",
				   nrow(newdat),
				   " new rows)."))
}

# write data in final table:
field.names <- paste( dbListFields(db, "tmp_epievent"), 
                      collapse = ",")
q <- paste0("INSERT INTO table_epievent(",
			field.names,
			") SELECT * FROM tmp_epievent;")
dbSendQuery(db,q)

check.epievent <- dbGetQuery(db,'SELECT * FROM table_epievent')
nc <- nrow(check.epievent)
if(nc==0) {
  message(' ERROR: something went wrong: table_epievent is empty...')
  stop()
}
if(nc>0){
  message(paste('\n ===> table_epievent added to',db.name,'\n'))
}

# Disconnect when finish querying the database:
dbDisconnect(db)


