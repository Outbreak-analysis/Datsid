library(lubridate)
library(dplyr)
library(tidyr)

#' Converts an epidemiological week to a date
#' in R format 'yyyy-mm-dd'
#' @param epiweek Epidemiological week
#' @param format Format of the epidemiological week (e.g., 'yyyyww')
convert.epiweek <- function(epiweek, format){
    res <- NA
    # epiweek <- 201734
    if(format=='yyyyww'){
        year <- as.numeric(substr(epiweek, start = 1, stop = 4))
        wk   <- as.numeric(substr(epiweek, start = 5, stop = 7))
        res <-  as.Date(format(date_decimal(year+wk/52), "%Y-%m-%d"))
    }
}

epievent.headers <- function(){
    x <- c('disease_id',
           'location_id',
           'eventdate',
           'reportdate',
           'count',
           'eventtype',
           'eventtype2',
           'agemin',
           'agemax',
           'gender',
           'socialstruct',
           'synthetic',
           'source')
    return(x)
}

create.empty.epievent.df <- function(nrow){
    h <- epievent.headers()
    nh <- length(h)
    x <- matrix(ncol=nh, nrow = nrow)
    colnames(x) <- h
    return(as.data.frame(x))
}

get.current.script.name <- function(){
    return( sub(".*=", "", commandArgs()[4]) )
}

#' Retrieve companion info file ending with '-info'
df.info.file <- function(){
    
    sname <- get.current.script.name()
    info.file <- gsub(pattern = '-reformat.R', replacement = '-info.csv',
                      x = sname, fixed = TRUE)
    if(info.file==sname){
        message('Problem while building info file name.')
        stop()
    }
    info <- read.csv(info.file, 
                     header = FALSE,
                     stringsAsFactors = F,
                     strip.white = T)
    names(info) <- c('name','val')
    return(info)
}

get.disease.table <- function(){
    read.csv(file = '../../tables/table_disease.csv',
             stringsAsFactors = F,
             strip.white = T)
}

get.location.table <- function(){
    read.csv(file = '../../tables/table_location.csv',
             stringsAsFactors = F,
             strip.white = T)
}

get.disease.id <- function(disease.name){
    res <- NA
    dn <- trimws(as.character(disease.name))
    tab.dis <- get.disease.table() %>%
        filter(disease_name==dn)
    tab.dis[tab.dis==''] <- NA
    if(nrow(tab.dis)==0){
        message(paste('Disease name <', dn,'> not found!'))
        stop()
    }
    if(nrow(tab.dis)==1){
        res <- tab.dis$disease_id
    }
    if(nrow(tab.dis) > 1){
        # if there is more than one match,
        # take the less informative disease description
        tmp <- apply(X = tab.dis, MARGIN = 2, FUN = is.na)
        idx <- which.max(apply(tmp, 1, sum))
        res <- tab.dis$disease_id[idx]
    }
    return(res)
}

get.disease.id.icd <- function(disease.icd){
    res <- NA
    dn <- trimws(as.character(disease.icd))
    tab.dis <- get.disease.table() %>%
        filter(disease_ICD==dn)
    tab.dis[tab.dis==''] <- NA
    if(nrow(tab.dis)==0){
        message(paste('Disease ICD <', dn,'> not found!'))
        stop()
    }
    if(nrow(tab.dis)==1){
        res <- tab.dis$disease_id
    }
    if(nrow(tab.dis) > 1){
        # if there is more than one match,
        # take the less informative disease description
        tmp <- apply(X = tab.dis, MARGIN = 2, FUN = is.na)
        idx <- which.max(apply(tmp, 1, sum))
        res <- tab.dis$disease_id[idx]
    }
    return(res)
}


get.location.id <- function(country, adminDiv1) {
    
    # What is asked:
    y <- data.frame(key=paste(country,adminDiv1,sep='_'))
    
    # From the table:
    x <- get.location.table()
    x$key <- paste(x$country, x$adminDiv1, sep='_')
    
    z <- left_join(y,x,"key")
    return(z$location_id)
}

fname.csv.reformated <- function(){
    sname <- get.current.script.name()
    fname <- gsub(pattern = '-reformat.R', 
                  replacement = '-db.csv',
                  x = sname)
    return(fname)
}

create.disease.key <- function(df){
    df$key <- with(df, paste(disease_name, 
                             disease_type,
                             disease_subtype,
                             disease_subtype2,
                             sep='_'))
    return(df)
}

create.location.key <- function(df){
    df$key <- with(df, paste(country, 
                             subcountry,
                             location_name,
                             sep='_'))
    return(df)
}


anglicize <- function(x){
    x <- gsub(x = x, pattern = 'é',replacement = 'e',fixed = TRUE)
    x <- gsub(x = x, pattern = 'è',replacement = 'e',fixed = TRUE)
    return(x)
}


