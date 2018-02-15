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




OLD__plot_data <- function(db.name, 
                      country = NULL, 
                      disease = NULL, 
                      disease_type = NULL, 
                      synthetic = NULL,
                      logscale = FALSE) {
    
    # db.name = 'datsid.db'
    
    dat <- get.epi.ts(db.name, 
                      country,
                      disease,
                      synthetic) 
    
    if(!is.null(disease_type)) {
        disease_type2 <- disease_type
        dat <- subset(dat, disease_type==disease_type2)
    }
    
    # Reformat before plots:
    dat$reportdate <- as.Date(dat$reportdate)
    dat$fullloc <- paste(dat$country,dat$adminDiv1,dat$adminDiv2)
    tmp <- substr(dat$eventtype2,1,6)
    tmp[is.na(tmp)] <- ""
    tmp2 <- dat$socialstruct
    tmp2[is.na(tmp2)] <- ""
    dat$datatype <- paste(dat$eventtype,tmp,tmp2)
    dat$sourcedata <- paste("source:", substr(dat$source,1,24))
    dat$synthetic.plot <- paste("synthetic:",dat$synthetic)
    dat$synthetic.plot[dat$synthetic==0] <- "Real epidemic"
    
    ## Plots
    
    g <- ggplot(dat)
    
    if(!logscale) {
        g <- g + geom_step(aes(x=reportdate,
                               y=count,
                               colour=datatype),size=2)
    }
    if(logscale) {
        g <- g + geom_point(aes(x=reportdate,
                                y=count,
                                colour=datatype),size=2)
        g <- g + geom_line(aes(x=reportdate,
                               y=count,
                               colour=datatype),size=1, alpha=0.5)
        g <- g + scale_y_log10()
    }
    g <- g + facet_wrap(~fullloc + disease_name + sourcedata + synthetic.plot,
                        scales = "free")
    
    plot(g)
}
