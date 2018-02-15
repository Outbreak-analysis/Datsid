library(ggplot2)
library(DBI)
library(RSQLite)
library(dplyr)

source("read_db.R")

#' Return a dataframe listing all epidemics
#' in the database, with the number of 
#' data points and dates range for each epidemic
#' @param db.path String. Path and name to the database.
#' @return Dataframe.
list.all.epidemics <- function(db.path) {
    
    db = DBI::dbConnect(RSQLite::SQLite(), dbname = db.path)
    q.epi <- DBI::dbGetQuery(db,'SELECT * FROM table_epievent')
    q.loc <- DBI::dbGetQuery(db,'SELECT * FROM table_location')
    q.dis <- DBI::dbGetQuery(db,'SELECT * FROM table_disease')
    DBI::dbDisconnect(conn = db)
    
    
    dat <- q.epi %>%
        left_join(q.loc, by='location_id') %>%
        left_join(q.dis, by='disease_id')
    
    dat$reportdate <- as.Date(dat$reportdate)
    
    epi <- dat %>%
        group_by(country, 
                 location_name, 
                 source,
                 disease_name,
                 disease_type,
                 disease_subtype,
                 disease_subtype2,
                 eventtype,
                 eventtype2) %>%
        summarize(n = length(epievent_id),
                  date1 = min(reportdate),
                  date2 = max(reportdate))
    return(epi)
}


#' Plot epidemic data given country, location, etc.
#' 
plot_data <- function(db.path, 
                      country.ISO3166,
                      location.name,
                      disease.name,
                      disease.type,
                      disease.subtype,
                      event.type,
                      synthetic = 0,
					  logscale = FALSE) {
	
    # db.path = 'datsid.db'
    # country.ISO3166='SL' ; location.name='Sierra Leone' ; disease.name='ebola'
    
	dat <- get.epi.ts.NEW(db.path, 
	                      country.ISO3166 ,
	                      location.name, 
	                      disease.name,
	                      disease.type,
	                      disease.subtype, 
	                      event.type,
	                      synthetic,
	                      plot.logscale = logscale,
	                      do.plot = TRUE)
	
}