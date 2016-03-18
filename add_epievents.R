library(DBI)
library(RSQLite)

# Command line arguments:
args <- commandArgs(trailingOnly = TRUE)
db.name <- args[1]
csvfile <- args[2]

warning("Location and Disease IDs are not check during importation!")

## Import new data in existing database:
if (length(args)>0){
	# The csv file should be generated with 
	# the Excel template macro.
	newdat <- read.csv(paste0("./data/",csvfile), header = F)
	
	# Connect to the database
	db = dbConnect(SQLite(), dbname=db.name)
	
	# Import first in a temporary database:
	dbWriteTable(db,"tmp_epievent", newdat, append=TRUE)
	# Copy to final table,
	# with the correct, auto-incremented, unique IDs:
	field.names <- dbListFields(db, "tmp_epievent")
	field.names2 <- paste(field.names,collapse = ",")
	q <- paste0("INSERT INTO table_epievent(",
				field.names2,
				") SELECT * FROM tmp_epievent;")
	dbSendQuery(db,q)
	
	# Disconnect when finish querying the database:
	dbDisconnect(db)
}


message(paste0("Data in ",
			  csvfile,
			  " successfuly added to database (",
			  nrow(newdat),
			  " new rows)."))

