library(DBI)
library(RSQLite)
library(dplyr)
library(ggplot2)

get.list.existing <- function(db.path){
    x <- get.epi.ts.NEW(db.path)	
    
    country <- unique(x$country)
    location.name <- unique(x$location_name)
    disease.name <- unique(x$disease_name)
    disease.type <- unique(x$disease_type)
    disease.subtype <- unique(x$disease_subtype)
    event.type <- unique(x$eventtype)
    
    return(list(country=country, 
                location.name=location.name,
                disease.name=disease.name,
                disease.type=disease.type,
                disease.subtype=disease.subtype,
                event.type = event.type))
}


get.list.sources <- function(db.path){
    x <- get.epi.ts(db.path,NULL,NULL,NULL)	
    return(unique(x$source))
}

#' Returns the full database joining the tables: 
#' - table_epievent
#' - table_location
#' - table_disease
#' 
get.joined.tables <- function(db.path){
    db <- dbConnect(SQLite(), dbname = db.path)
    
    tab.epi <- dbGetQuery(conn = db, 
                          statement = 'SELECT DISTINCT *
                          FROM table_epievent')
    tab.loc <- dbGetQuery(conn = db, 
                          statement = 'SELECT DISTINCT *
                          FROM table_location')
    tab.dis <- dbGetQuery(conn = db, 
                          statement = 'SELECT DISTINCT *
                          FROM table_disease')
    dbDisconnect(db)
    
    dat <- tab.epi %>% 
        left_join(tab.loc, by='location_id') %>%
        left_join(tab.dis, by='disease_id')
    
    return(dat)
}

#' Plot time series returned from a database query
#' @param x Dataframe returned from database query.
#' @param title String. Title for the plot.
plot.ts <- function(x, title, logscale = FALSE) {
    
    g <- ggplot(x, aes(x=reportdate, y=count)) +
        geom_point(size=0.5) + geom_step() +
        facet_wrap(~country+location_name+ disease_type+ disease_subtype+eventtype,
                   scales = 'free') +
        ggtitle(title)
    
    if(logscale) g <- g + scale_y_log10()
    
    plot(g)   
}


get.epi.ts.NEW <- function(db.path, 
                           country.ISO3166 = '',
                           location.name = '',
                           disease.name = '',
                           disease.type = NULL,
                           disease.subtype = NULL,
                           event.type = NULL,
                           synthetic=0,
                           do.plot = FALSE,
                           plot.logscale=FALSE) {
    # DEBUG: db.path='datsid.db'
    # country.ISO3166='SL' ; location.name='Centre' ; disease.name='influenza'
    
    x <- get.joined.tables(db.path)
    
    
    if(country.ISO3166 != '') x <- filter(x, country == country.ISO3166)
    if(location.name != '')   x <- filter(x, location_name == location.name)
    if(disease.name != '')    x <- filter(x, disease_name == disease.name)
    if(!is.null(event.type))  x <- filter(x, eventtype==event.type)
    if(!is.null(disease.type))     x <- filter(x, disease_type==disease.type)
    if(!is.null(disease.subtype)) x <- filter(x, disease_subtype==disease.subtype)
    print(nrow(x))
    
    # Converts dates in R Data format:
    x$reportdate <- as.Date(x$reportdate, format = '%Y-%m-%d')
    x$eventdate  <- as.Date(x$eventdate, format = '%Y-%m-%d')
    
    # Plot (if requested):
    if(do.plot){
        title <- paste(db.path, 
                       country.ISO3166,
                       location.name,
                       disease.name,
                       disease.type,
                       disease.subtype,
                       event.type,
                       sep = '; ')
        plot.ts(x, title, logscale = plot.logscale)
    }
    return(x)
}

#' Select a subset of an epidemic time series based on dates
#' @param epi.ts Dataframe, typically returned from function \code{get.epi.ts.NEW}.
#' @param reportdate.min String. Minimum date yyyy-mm-dd
#' @param reportdate.max String. Maximum date yyyy-mm-dd
#' 
subset.date.epi.ts <- function(epi.ts, reportdate.min, reportdate.max) {
    x <- epi.ts %>%
        filter(reportdate.min <= reportdate & reportdate <= reportdate.max)
    return(x)
}







get.epi.ts <- function(db.path, 
                       country,
                       disease,
                       synthetic, 
                       print.sql=FALSE) {
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
    if(is.null(country)) c2 <- ""
    if(is.null(country) & is.null(disease)) c23 <- ""
    
    
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
    if(print.sql) print(sqlcmd)
    
    q <- dbGetQuery(db,sqlcmd)
    dbDisconnect(db)
    
    # Clean-up duplicated columns
    dupl <- duplicated(names(q))
    which(!dupl)
    q2 <- q[,which(!dupl)]
    
    return(q2)
}



date.to.duration <- function(datevec){
    ### Convert date in string format to numeric duration
    ### by substracting the smallest date to all other dates.
    
    # converts to date
    d <- as.Date(datevec)
    # substract smallest date:
    d.min <- min(d)
    x <- as.numeric(d-d.min)
    return(x)
}
