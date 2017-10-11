library(DBI)
library(RSQLite)
library(dplyr)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)	
db.path <- 'a.db'  #args[1]

db = dbConnect(SQLite(), dbname = db.path)
sqlcmd <- "SELECT * FROM table_epievent,table_disease,table_location
WHERE
table_epievent.disease_id=table_disease.disease_id AND
table_location.location_id=table_epievent.location_id"
q <- dbGetQuery(db,sqlcmd)
dbDisconnect(db)


q <- q[, !duplicated(colnames(q))]

# x <- ddply(q,c('country','disease_name','source'),
#            summarize,
#            n = length(epievent_id))
x <- q %>% group_by(country,disease_name,source) %>%
  summarise(n = length(epievent_id))


x$source <- substr(x$source,1,16)
x2 <- x[order(x$country),]
x2 <- subset(x2, disease_name != 'synthetic')
x2 <- subset(x2, source != 'GC')
print(x2)
sum(x2$n)


g1 <- ggplot(x2)+
  geom_bar(aes(x=disease_name, y=n, fill=country), stat='identity') +
  xlab('Disease') + ylab('Number of data points')+
  theme(text = element_text(size=18),
        axis.text.x = element_text(angle=45, hjust=1)) + 
  ggtitle('Number of data points')

q$reportdate2 <- as.Date(q$reportdate,format = '%Y-%m-%d')

q %>% 
  filter(disease_name != 'synthetic') %>%
  filter(disease_name != 'plague') %>%
  group_by(disease_name) %>%
  summarise(tmin = min(reportdate2, na.rm = T),
            tmax = max(reportdate2, na.rm = T)) %>%
  ggplot() +
  geom_segment(aes(y=disease_name, yend=disease_name, x=tmin, xend=tmax),
               size = 4)+
  ggtitle('Date ranges for epidemic time series') +
  xlab('Date') + ylab('') + 
  theme(text = element_text(size=18)) -> g2

png('tmp_plot1.png', width = 900, height = 500)
plot(g1)
dev.off()
png('tmp_plot2.png', width = 900, height = 500)
plot(g2)
dev.off()

