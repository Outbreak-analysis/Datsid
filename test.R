source("read_DB.R")

# Build a new database:
db.name <- "test.db"
system(paste("./buildNewDB",db.name))

# Pick an epidemic:
country <- "RDC"
disease <- "ebola"

# Retrieve the data:
x <- get.epi.ts(db.name, country, disease, synthetic = NULL)

# Plot the data:
library(ggplot2)
x$date <- as.Date(x$reportdate)
ggplot(x) + geom_line(aes(x=date,y=count))
