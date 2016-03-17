library(ggplot2)
library(DBI)
library(RSQLite)

args <- commandArgs(trailingOnly = TRUE)
if (length(args)<1) stop("Not enough arguments!")
db.name <- args[1]

# Connect to the database
db = dbConnect(SQLite(), dbname=db.name)

# Nothing is filtered:
q.all <- dbGetQuery(db,"SELECT DISTINCT *
					FROM table_epievent,table_disease,table_location 
					WHERE (
					table_epievent.disease_id = table_disease.disease_id
					AND table_location.location_id = table_epievent.location_id)")

# Disconnect when finish querying the database:
dbDisconnect(db)

# Reformat before plots:
q.all$reportdate <- as.Date(q.all$reportdate)
q.all$fullloc <- paste(q.all$country,q.all$adminDiv1,q.all$adminDiv2)

## Plots
pdf(paste0("plot_data_",db.name,".pdf"),width=35,height=20)
g <- ggplot(q.all)+geom_step(aes(x=reportdate,y=count,colour=eventtype),size=1)
g <- g + ggtitle("Epidemics in database")
g <- g + facet_wrap(~fullloc+disease_name,scales = "free",ncol = 4)
plot(g)
dev.off()
