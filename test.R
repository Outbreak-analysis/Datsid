source("read_db.R")

# Name of the database
db.name <- "datsid.db"

# Try to build the database if it does not exist:
out <- system(paste('ls',db.name),intern = TRUE)
if(length(out)==0) 
    system(paste("./buildNewDB",db.name))

# Pick an epidemic:
country <- "UK"
disease <- "measles"

# Retrieve the data:
x <- get.epi.ts(db.name, country, disease, synthetic = NULL)

# Plot the data:
library(ggplot2)
x$date <- as.Date(x$reportdate)
x2 <- subset(x, eventtype=='incidence')
ggplot(x2) + 
    geom_step(aes(x=date,y=count)) +
    ggtitle(paste(disease, country)) + 
    facet_wrap(~adminDiv1, scales='free_y')
