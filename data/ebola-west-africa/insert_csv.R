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
dbName <- args[1]
csvName <- args[2]

# read in CSV file
tableCsv = read_csv(csvName)

# Connect to the database
db = dbConnect(SQLite(), dbname = dbName)

# Start a transaction
dbBegin(db)

# Get the disease ID
diseaseId <- getDiseaseId(db, 'ebola')

# Parse out the country names from the var column
tmp <- strsplit(x = tableCsv$var, split = '--')
tableCsv$country <- trimws(sapply(tmp, '[[',2))

# Incidence or death?
tableCsv$ev <- 'incidence'
tableCsv$ev[grepl('Death', tableCsv$var)] <- 'death'

# Get source id
sourceId <- getSourceId(db, "US CDC")

# Add each row to the database
insertSql <- "
INSERT INTO epievents (disease_id, location_id, report_date, cases, eventtype_id, source_id)
               VALUES (         ?,           ?,           ?,     ?,            ?,         ?)"

for (i in 1:nrow(tableCsv)) {
    locationId <- getLocationId(db, tableCsv[[i,'country']])
    reportDate <- as.character(pull(tableCsv[i, "WHO report date"]))
    reportCases <- as.numeric(tableCsv[[i, 'val']])
    reportEv <- tableCsv[[i, 'ev']]
    eventId <- getEventId(db, reportEv)
    
    insertRs <- dbSendStatement(db, insertSql)
    dbBind(insertRs, list(diseaseId, locationId, reportDate, reportCases, eventId, sourceId))
    dbHasCompleted(insertRs)
    dbGetRowsAffected(insertRs)
    dbClearResult(insertRs)
}

# Commit the transaction
dbCommit(db)
