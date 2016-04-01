#!/usr/bin/env Rscript
reqs <- c("optparse", "RSQLite", "tools")
need.inst <- !sapply(reqs, require, character.only=T)
if (sum(need.inst)) install.packages(reqs[need.inst])

dbconn <- function(nm) dbConnect(SQLite(), dbname=nm)
checkExists <- function(files) {
  chks <- file.exists(files)
  if (sum(!chks)) {
    warning("missing files:", files[!chks],"; proceeding with other files")
    newfiles <- files[chks]
    if (length(newfiles)) newfiles else stop("file list is empty.") 
  } else {
    files
  }
}

parse_args <- function(argv = commandArgs(trailingOnly = T)) {
  parser <- optparse::OptionParser(
    usage = "usage: %prog path/to/db.sqlite path/to/ingest.csv [path/to/ingest2.csv, ...]",
    description = "add csv inputs to an epi database",
    option_list = list(
      optparse::make_option(
        c("--verbose","-v"),  action="store_true", default = FALSE,
        help="verbose?"
      )
    )
  )
  req_pos <- list(dbConnection=dbconn, inputfiles=identity)
  parsed <- optparse::parse_args(parser, argv, positional_arguments = c(2, Inf))
  parsed$options$help <- NULL
  result <- c(mapply(function(f,c) f(c), req_pos, list(parsed$args[1], parsed$args[-1]), SIMPLIFY = F), parsed$options)
  result$storeres <- function(dt, was) {
    saveRDS(dt, sub(parsed$args[1], parsed$args[2], was))
    dt
  }
  
  if(result$verbose) print(result)
  result
}

checkSrc <- function(dbConnection, inputfiles) {
  keep <- mapply(function(fn, md5s) {
    res <- dbGetPreparedQuery(dbConnection, "SELECT id, md5sum FROM source WHERE name == ?;", fn)
    TRUE # to do
  }, inputfiles, md5sum(inputfiles))
  inputfiles[TRUE]
}
  
ingest <- function(dbConnection, inputfiles) {
  reducedInputFiles <- checkSrc(dbConnection, inputfiles)
  
  # for each input file
  #  - ask if present in db already:
  #  - lookup file name in sources table; if not found, proceed
  #    else if md5sum same => next file
  #    else rm data associated with that source id, proceed
  #  -
}

stop()

clargs <- parse_args(
  #  c("input/background-clusters/spin-glass/acc-30-30", "input/background-clusters/spin-glass/agg-30-30", "-v") # uncomment to debug
)

# Tables setup: location, disease 
table.location <- read.csv("tables/table_location.csv")
table.disease <- read.csv("tables/table_disease.csv")
dbWriteTable(db,"table_location", table.location, append=TRUE)
dbWriteTable(db,"table_disease", table.disease, append=TRUE)

## Import new data in existing database:
for(i in 1:length(csvlist)){
	newdat <- read.csv(file = csvlist[i], header = F)
	dbWriteTable(db,"tmp_epievent", newdat, append=TRUE)
	
	message(paste0("Data in ",
				   csvlist[i],
				   " successfuly added to database (",
				   nrow(newdat),
				   " new rows)."))
}
field.names <- dbListFields(db, "tmp_epievent")
field.names2 <- paste(field.names,collapse = ",")
q <- paste0("INSERT INTO table_epievent(",
			field.names2,
			") SELECT * FROM tmp_epievent;")

dbSendQuery(db,q)
# Disconnect when finish querying the database:
dbDisconnect(db)


