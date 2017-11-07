source("read_db.R")

# Name of the database
db.name <- "datsid.db"

# Try to build the database if it does not exist:
out <- system(paste('ls',db.name),intern = TRUE)
if(length(out)==0) 
    system(paste("./buildNewDB",db.name))

# Retrieve and plot the data
# of an arbitrary epidemic:
pdf('test-plot.pdf', width = 15, height = 12)
x <- get.epi.ts.NEW(db.path = db.name, 
                    country.ISO3166 = 'SL',
                    location.name = 'Sierra Leone',
                    disease.name = 'ebola',
                    do.plot = TRUE)
dev.off()
