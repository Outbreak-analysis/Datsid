

download.report <- function(url.date) {
    url.root <- 'http://www.sante.gov.mg/home/uploads/____folderforallfiles/Bulletin%20Flash%20-'
    url.end  <- '-20h00_vf.pdf'
    url.end2 <- '-20h00_vf2.pdf'
    url  <- paste0(url.root, url.date, url.end)
    url2 <- paste0(url.root, url.date, url.end2)
    
    dest.name <- paste0('plague-MG-report-',url.date,'.pdf')
    
    print(url)
    try(download.file(url = url,  destfile = dest.name, quiet = TRUE), silent = TRUE)
    try(download.file(url = url2, destfile = dest.name, quiet = TRUE), silent = TRUE)
}

d1 <- as.Date('01-10-2017', format='%d-%m-%Y')
d2 <- as.Date('30-10-2017', format='%d-%m-%Y')
url.date <- seq(d1,d2,by=1)
url.date <- sapply(url.date, format, format='%d-%m-%Y')

x <- lapply(url.date, download.report)
