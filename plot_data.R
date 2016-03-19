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
tmp <- substr(q.all$eventtype2,1,6)
tmp[is.na(tmp)] <- ""
tmp2 <- q.all$socialstruct
tmp2[is.na(tmp2)] <- ""
q.all$datatype <- paste(q.all$eventtype,tmp,tmp2)

q.all.real <- subset(q.all, synthetic==0)
q.all.syn <- subset(q.all, synthetic>0)

q.all.syn$source2 <- substr(q.all.syn$source,1,6)

## Plots
pdf(paste0("plot_data_",db.name,".pdf"),width=35,height=20)

g <- ggplot(q.all.real)+geom_step(aes(x=reportdate,y=count,colour=datatype),size=1)
g <- g + ggtitle("Real epidemics in database")
g <- g + facet_wrap(~fullloc+disease_name,scales = "free",ncol = 4)
plot(g)

g <- ggplot(q.all.syn)+geom_step(aes(x=reportdate,y=count,colour=datatype),size=1)
g <- g + ggtitle("Synthetic epidemics in database")
g <- g + facet_wrap(~fullloc+disease_name+source+synthetic,scales = "free")
#g <- g + theme(strip.text.x = element_text(size = 8, colour = "black"))
plot(g)

dev.off()
