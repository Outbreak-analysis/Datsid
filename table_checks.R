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
                 loc$adminDiv1,
                 loc$adminDiv2,
                 loc$adminDiv3,
                 loc$adminDiv4,
                 sep='_')
check.duplicate(loc$key, 'location')

# check duplicated coordinates:
loc$keygeo <- with(loc, paste(round(latitude,5),
                              round(longitude,5),
                              sep='_'))
# if no coordinated entered, 
# set to a unique value such that it's not flagged as duplicated:
idx <- which(loc$keygeo=='NA_NA')
loc$keygeo[idx] <- 1:length(idx)

check.duplicate(loc$keygeo, 'location (coordinates only)')

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


