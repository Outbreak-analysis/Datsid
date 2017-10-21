library(lubridate)
library(dplyr)
library(tidyr)
library(XML)
library(httr)
library(snowfall)
library(ggplot2)

t0 <- as.numeric(Sys.time())

read_web_phac <- function(year.start) {
    message(paste('read_web_phac:',year.start))
    # Retrieve URL:
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
    
    get.webdata.unit <- function(i, url_vec) {
        try(expr = {
            url <- url_vec[i] 
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
            if(length(idx)>0){
                # Warning: Take the first table!
                tmp <- z[[idx[1]]]
                regions <- tmp[,1]
                x <- as.data.frame(sapply(tmp[,2:ncol(tmp)], as.numeric))
                dat <- cbind(regions, x)
                dat2 <- gather(dat, 'type','count',2:ncol(dat))
                dat2$date <- as.Date( format(date_decimal(yr+wk/52), "%Y-%m-%d") )
                return(dat2)
            }
        },
        silent = FALSE)
    }
    
    sfInit(parallel = TRUE, cpus = parallel::detectCores() )
    sfLibrary(httr);sfLibrary(XML);sfLibrary(dplyr);sfLibrary(tidyr);sfLibrary(lubridate)
    sfExportAll()
    df <- sfLapply(1:n, fun = get.webdata.unit, url_vec)
    sfStop()
    
    dfall <- do.call('rbind',df)
    return(dfall)
}

# Web pages for 2011 and 2012 are different... need to adjust the code.
# For now, retrieving only from 2013.
years.start <- c(2013:2016)
dat.yr <- lapply(years.start, read_web_phac)
dat <- do.call('rbind', dat.yr)

dat$type <- gsub(pattern = '\n', replacement = '', x = dat$type, fixed = TRUE)


# Save for downstream use:  
save(list='dat', file='resp-canada.RData')
write.csv(x = dat, 
          file = 'respiratory-canada-phac-raw.csv', 
          quote = FALSE, row.names = FALSE)

if(FALSE){
    pdf('test.pdf', width = 20, height=13)
    dat %>%
        filter(grepl('RSV',type)) %>%
        ggplot(aes(x=date, y=count, colour=type)) + 
        geom_line() + 
        facet_wrap(~regions, scales='free')
    dev.off()
}


t1 <- as.numeric(Sys.time())
message(paste('Web data - respiratory Canada done in ',
              round( (t1-t0)/60,1),'minutes'))


