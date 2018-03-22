###
### Insert data from CSV file into database
###

library(tidyr)
library(dplyr)
library(readr)
source('_dbutil.R')

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2)
    stop("usage: load_diseases.R dbfile cvsfile")
db.name <- args[1]
csv.name <- args[2]

# read in CSV file
table.csv = read_csv(csv.name)

# Connect to the database
db = dbConnect(SQLite(), dbname = db.name)

# Start a transaction
dbBegin(db)

# Get the disease ID
diseaseId <- getDiseaseId(db, 'ebola')

# Parse out the country names from the var column
tmp <- strsplit(x = table.csv$var, split = '--')
table.csv$country <- trimws(sapply(tmp, '[[',2))

# Incidence or death?
table.csv$ev <- 'incidence'
table.csv$ev[grepl('Death', table.csv$var)] <- 'death'

# Get source id
sourceId <- getSourceId(db, "US CDC")

# Add each row to the database
insertSql <- "
INSERT INTO epievents (disease_id, location_id, report_date, cases, eventtype_id, source_id)
               VALUES (         ?,           ?,           ?,     ?,            ?,         ?)"

for (i in 1:nrow(table.csv)) {
    locationId <- getLocationId(db, table.csv[[i,'country']])
    reportDate <- as.character(pull(table.csv[i, "WHO report date"]))
    reportCases <- as.numeric(table.csv[[i, 'val']])
    reportEv <- table.csv[[i, 'ev']]
    eventId <- getEventId(db, reportEv)
    
    insert.rs <- dbSendStatement(db, insertSql)
    dbBind(insert.rs, list(diseaseId, locationId, reportDate, reportCases, eventId, sourceId))
    dbHasCompleted(insert.rs)
    dbGetRowsAffected(insert.rs)
    dbClearResult(insert.rs)
}

# Commit the transaction
dbCommit(db)
