library(DBI)
library(RSQLite)

get.epi.ts <- function(db.path, 
					   country,
					   disease,
					   synthetic = NULL) {
	### Retrieve epidemic time series
	### given country and disease
	###
	db = dbConnect(SQLite(), dbname = db.path)
	
	sqlcmd <- paste0("SELECT DISTINCT *
					FROM table_epievent,table_disease,table_location 
					WHERE (
					table_disease.disease_name='",disease,"'
					AND table_epievent.disease_id=table_disease.disease_id
					AND table_location.location_id=table_epievent.location_id
					AND table_location.country='",country,"')")

	q <- dbGetQuery(db,sqlcmd)
	dbDisconnect(db)
	return(q)
}

