library(DBI)
library(RSQLite)


get.list.existing <- function(db.path){
	x <- get.epi.ts(db.path,NULL,NULL,NULL)	
	countries <- unique(x$country)
	diseases <- unique(x$disease_name)
	synthetics <- unique(x$synthetic)
	return(list(countries=countries, 
				diseases=diseases,
				synthetics=synthetics))
}


get.epi.ts <- function(db.path, 
					   country,
					   disease,
					   synthetic) {
	### Retrieve epidemic time series
	### given country and disease
	###
	db = dbConnect(SQLite(), dbname = db.path)
	
	sqlcmd00 <- paste0("SELECT DISTINCT *
					FROM table_epievent,table_disease,table_location 
					WHERE (
					table_disease.disease_name='",disease,"'
					AND table_epievent.disease_id=table_disease.disease_id
					AND table_epievent.synthetic=",synthetic,
					" AND table_location.location_id=table_epievent.location_id
					AND table_location.country='",country,"')")
	
	c1 <- paste0("table_disease.disease_name='",disease,"'")
	c12 <- " AND "
	if(is.null(disease)) {
		c1<-""
		c12 <- ""
	}
	
	c2 <- paste0(c12, "table_location.country='",country,"'")
	c23 <- " AND "
	if(is.null(country)) {
		c2 <- ""
		c23 <- ""
	}
	
	c3 <- paste0(c23,"table_epievent.synthetic=",synthetic)
	c34 <- " AND "
	if(is.null(synthetic)) {
		c3 <- ""
		c34 <- ""
	}
	
	cend <- " AND "
	if(is.null(disease) & is.null(country) & is.null(synthetic)) cend <- ""
	
	sqlcmd <- paste0("SELECT DISTINCT * FROM table_epievent,table_disease,table_location WHERE (",
					 c1,
					 c2,
					 c3,
					 cend,
					 "table_epievent.disease_id=table_disease.disease_id",
					 " AND table_location.location_id=table_epievent.location_id" ,
					 ")")
	sqlcmd

	q <- dbGetQuery(db,sqlcmd)
	dbDisconnect(db)
	return(q)
}



