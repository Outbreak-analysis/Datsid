library(DBI)
library(RSQLite)


args <- commandArgs(trailingOnly = TRUE)

csvfile <- args[1]

# Connect to the database
db = dbConnect(SQLite(), dbname="IDDB.db")

## Import new data in existing database:
if (length(args)>0){ 
	newdat <- read.csv(paste0("./data/",csvfile), header = F)
	dbWriteTable(db,"table_epievent", newdat, append=TRUE)
}

message(paste0("Data in ",
			  csvfile,
			  " successfuly added to database. (",
			  nrow(newdat),
			  "new rows)"))

