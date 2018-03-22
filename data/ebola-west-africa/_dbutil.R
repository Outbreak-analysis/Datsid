library(DBI)
library(RSQLite)

getDiseaseId <- function(db, disease.name) {
    # get the disease_id
    disease.sql <- "
SELECT disease_id
FROM diseases
WHERE disease_name = ?"

    disease.res <- dbSendQuery(db, disease.sql)
    dbBind(disease.res, list(disease.name))
    rs <- dbFetch(disease.res)
    if (nrow(rs) == 0) {
        stop(paste(disease.name, "not found in diseases table"))
    }
    
    disease.id <- as.numeric(rs[1])
    dbClearResult(disease.res)
    return(disease.id)
}

getLocationId <- function(db, country.name) {
    # get the disease_id
    location.sql <- "
SELECT location_id
FROM locations
WHERE location_name = ?"

    location.res <- dbSendQuery(db, location.sql)
    dbBind(location.res, list(country.name))
    rs <- dbFetch(location.res)
    if (nrow(rs) == 0) {
        stop(paste(country.name, "not found in locations table"))
    }
    
    location.id <- as.numeric(rs[1])
    dbClearResult(location.res)
    return(location.id)

}

# Return the id associated with the key, or -1 if not found
# We're assuming there's a single ? in the SQL representing the key to
# search for.
getId <- function(db, selectSql, key) {
    select.rs <- dbSendQuery(db, selectSql)
    dbBind(select.rs, list(key))
    rs <- dbFetch(select.rs)

    if (nrow(rs) == 0) {
        id <- -1
    } else {
        id <- as.numeric(rs[1])
    }

    dbClearResult(select.rs)
    return(id)
}
    
# Execute a single statement, which we're assuming is an insert.
# We're also assuming there's a single ? in the SQL representing the key to
# search for.
insertId <- function(db, insertSql, key) {
    rs <- dbSendStatement(db, insertSql)
    dbBind(rs, list(key))
    dbHasCompleted(rs)
    dbGetRowsAffected(rs)
    dbClearResult(rs)
}
    
getOrInsertId <- function(db, selectSql, insertSql, key) {
    # Check if it's already in the db
    id <- getId(db, selectSql, key)
    if (id == -1) {
        insertId(db, insertSql, key)
        id <- getId(db, selectSql, key)
        if (id == -1) {
            stop(sprintf("failed to get id for key %s with sql %s", key, selectSql))
        }
    }
    return(id)
}

getEventId <- function(db, key) {
    selectSql <- "SELECT eventtype_id FROM eventtypes WHERE eventtype = ?"
    insertSql <- "INSERT INTO eventtypes (eventtype) VALUES (?)"

    return(getOrInsertId(db, selectSql, insertSql, key))
}

getSourceId <- function(db, key) {
    selectSql <- "SELECT source_id FROM sources WHERE source = ?"
    insertSql <- "INSERT INTO sources (source) VALUES (?)"

    return(getOrInsertId(db, selectSql, insertSql, key))
}

