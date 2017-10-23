###
###   CHECK TABLES INTEGRITY & CONSISTENCY
###

library(tidyr)
library(plyr)

# tables directory:
DIR <- './tables/'


check.duplicate <- function(keys, table.name) {
    
    dup <- duplicated(keys)
    if(!all(!dup)){
        message(paste('ERROR. Duplicated entries in',
                      table.name,'table:'))
        message(paste(keys[dup], collapse='\n'))
        stop()
    }
}


check.unique.id <- function(table.name,table, id){
    ids <- table[id]    
    dup <- duplicated(ids)
    if(!all(!dup)){
        message(paste('ERROR. Duplicated unique ids in',
                      table.name,'table:'))
        message(paste(ids[dup,], collapse='\n'))
        stop()
    }
}

# ---- Locations ----

loc <- read.csv(paste0(DIR,'table_location.csv'), 
                stringsAsFactors = F)
check.unique.id('location', table = loc, id = 'location_id')

# checks for duplicates entries:
loc$key <- paste(loc$country,
                 loc$subcountry,
                 loc$location_name,
                 sep='_')
check.duplicate(loc$key, 'location')


# ---- Diseases ----

dis <- read.csv(paste0(DIR,'table_disease.csv'), 
                stringsAsFactors = F)

check.unique.id('disease', table = dis, id = 'disease_id')

dis$key <- with(dis,
                paste(disease_name,
                      disease_ICD,
                      disease_type,
                      disease_subtype,
                      disease_subtype2,
                      sep='_'))
check.duplicate(keys = dis$key, table.name = 'disease')


