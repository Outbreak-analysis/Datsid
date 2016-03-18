library(DBI)
library(RSQLite)


args <- commandArgs(trailingOnly = TRUE)
if (length(args)<1) stop("Not enough arguments!")
db.name <- args[1]
 # db.name <- "a.db"

csvlist <- system("ls ./data/*.csv",intern = TRUE)

# Connect to the database
db = dbConnect(SQLite(), dbname=db.name)

# Tables setup: location, disease 
table.location <- read.csv("tables/table_location.csv")
table.disease <- read.csv("tables/table_disease.csv")
dbWriteTable(db,"table_location", table.location, append=TRUE)
dbWriteTable(db,"table_disease", table.disease, append=TRUE)

## Import new data in existing database:
for(i in 1:length(csvlist)){
	newdat <- read.csv(file = csvlist[i], header = F)
	dbWriteTable(db,"tmp_epievent", newdat, append=TRUE)
	
	message(paste0("Data in ",
				   csvlist[i],
				   " successfuly added to database (",
				   nrow(newdat),
				   " new rows)."))
}
field.names <- dbListFields(db, "tmp_epievent")
field.names2 <- paste(field.names,collapse = ",")
q <- paste0("INSERT INTO table_epievent(",
			field.names2,
			") SELECT * FROM tmp_epievent;")

dbSendQuery(db,q)
# Disconnect when finish querying the database:
dbDisconnect(db)


