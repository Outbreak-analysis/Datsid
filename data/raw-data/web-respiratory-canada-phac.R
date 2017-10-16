library(lubridate)
library(dplyr)
library(tidyr)
library(XML)
library(httr)


read_web_phac <- function(year.start) {
  url_root <- 'https://www.canada.ca/en/public-health/services/surveillance/respiratory-virus-detections-canada/'
  
  url0 <- paste0(url_root, year.start, '-', year.start+1, '.html')
  a <- readLines(url0)
  a <- a[grepl('Ending',a)]
  pos1 <- unlist(gregexpr(pattern = 'href=', text = a))
  pos2 <- unlist(gregexpr(pattern = '.html', text = a))
  url_vec <- substr(x = a, start = pos1+7, stop = pos2+4)
  url_vec <- paste0('https://www.canada.ca/', url_vec)
  
  df <- list()
  n <- length(url_vec)
  for(i in 1:n){
    url <- url_vec[i] #'https://www.canada.ca/en/public-health/services/surveillance/respiratory-virus-detections-canada/2013-2014/respiratory-virus-detections-isolations-week-34-ending-august-23-2014.html'
    print(paste(i,'/',n))
    pos1 <- unlist(gregexpr(pattern = 'week-', text = url))
    pos2 <- unlist(gregexpr(pattern = '-ending-', text = url))
    pos3 <- unlist(gregexpr(pattern = '.html', text = url))
    wk <- as.numeric(substr(x = url, start = pos1+5, stop = pos2-1))
    yr <- as.numeric(substr(x = url, start = pos3-4, stop = pos3-1))
    
    z <- GET(url) %>% 
      content(as='text') %>%
      readHTMLTable(trim = TRUE, 
                    colClasses = 'character', 
                    stringsAsFactors = FALSE)
    
    idx <- which(grepl('Table 1', names(z)))
    tmp <- z[[idx]]
    regions <- tmp[,1]
    x <- as.data.frame(sapply(tmp[,2:ncol(tmp)], as.numeric))
    dat <- cbind(regions, x)
    dat2 <- gather(dat, 'type','count',2:ncol(dat))
    dat2$date <- as.Date( format(date_decimal(yr+wk/52), "%Y-%m-%d") )
    df[[i]] <- dat2
  }
  dfall <- do.call('rbind',df)
  return(dfall)
}


xx <- read_web_phac(year.start=2013)
library(ggplot2)
pdf('test.pdf', width = 20, height=13)
ggplot(xx, aes(x=date, y=count, colour=type)) + geom_line() + facet_wrap(~regions, scales='free')
dev.off()
