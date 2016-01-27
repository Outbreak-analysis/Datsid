library(ggplot2)
library(DBI)
library(RSQLite)

# Connect to the database
db = dbConnect(SQLite(), dbname="IDDB.db")

## The tables in the database
tbl <- dbListTables(conn = db)
print(tbl)

## The columns in a table
dbListFields(db, "table_epievent")

## The data in a table
head(dbReadTable(db, "table_epievent"))
dbReadTable(db, "table_disease")
dbReadTable(db, "table_location")

## Import new data in existing database:
if (FALSE){ # (ONLY SWITCH ON IF NEW DATA TO BE IMPORTED!)
	newdat <- read.csv("./EpiData/Influenza/Mexico/mexflu.csv", header = F)
	dbWriteTable(db,"table_epievent",newdat,append=TRUE)
}

## SQL queries ##
# Two choices:
# 1/ the SQL query can filter what is desired (e.g. cholera incidence in Haiti)
# 2/ the SQL query retrieve everything, then filter in R (i.e., subset data frame)
#
q1 <- dbGetQuery(db,"SELECT DISTINCT *
					FROM table_epievent,table_disease,table_location 
					WHERE (
					table_epievent.eventtype='incidence' 
					AND table_disease.disease_name='cholera'
					AND table_epievent.disease_id=table_disease.disease_id
					AND table_location.location_id=table_epievent.location_id
					AND table_location.country='HAITI')")
print(head(q1))

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
pdf("plot.pdf",width=15,height=10)
g <- ggplot(q.all)+geom_step(aes(x=reportdate,y=count,colour=eventtype),size=1)
g <- g + ggtitle("Epidemics in database")
g <- g +facet_wrap(~fullloc+disease_name,scales = "free")
plot(g)
dev.off()
