library(DBI)
library(RSQLite)
library(dplyr)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)	
db.path <- args[1]
# db.path = 'datsid.db'  'abc.db'

do.plot <- TRUE

db = DBI::dbConnect(RSQLite::SQLite(), dbname = db.path)
q.epi <- DBI::dbGetQuery(db,'SELECT * FROM table_epievent')
q.loc <- DBI::dbGetQuery(db,'SELECT * FROM table_location')
q.dis <- DBI::dbGetQuery(db,'SELECT * FROM table_disease')
DBI::dbDisconnect(conn = db)


dat <- q.epi %>%
    left_join(q.loc, by='location_id') %>%
    left_join(q.dis, by='disease_id')

print(dat %>%
          group_by(disease_name) %>%
          summarize(n_datapoints = length(epievent_id),
                    n_sources = length(unique(source))) 
)
x <- dat %>%
    group_by(country, disease_name, source) %>%
    summarize(n_datapoints = length(epievent_id)) %>%
    mutate(source = substr(source,1,16))
print(x)
print(paste(db.path, 'has a total of',prettyNum(sum(x$n_datapoints),big.mark=","),'data points.'))

if(do.plot){
    
    x <- x[!is.na(x$disease_name),]
    g.n <- ggplot(x)+
        geom_bar(aes(x=disease_name, y=n_datapoints, fill=country),
                 stat = 'identity', position='dodge') +
        scale_y_log10(breaks=10^c(1:6)) +
        theme(axis.text.x = element_text(angle = 30, hjust = 1),
              text = element_text(size=20)) +
        xlab('') + ylab('Number of data points')
    
    g.dates <- dat %>%
        filter(!is.na(disease_name)) %>%
        mutate(reportdate2 = as.Date(reportdate)) %>%
        group_by(disease_name) %>%
        summarize(start = min(reportdate2),
                  end = max(reportdate2)) %>%
        ggplot()+
        geom_segment(aes(x=start, xend=end, 
                         y=disease_name, yend=disease_name),
                     size=3)+
        theme(text = element_text(size=20)) +
        xlab('Data dates range') + ylab('')
    
    pdf('glimpse-plots.pdf', width = 12, height = 12)
    plot(g.n)
    plot(g.dates)
    dev.off()
}


message('\n [glimpse end] \n')

