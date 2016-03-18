source("read_DB.R")


db.path <- "a.db"
country <- "UK"
disease <- "measles"
x <- get.epi.ts(db.path,country,disease)
head(x)
