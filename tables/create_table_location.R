dat <- read.csv('table_location_data.csv')

# Check for duplicates:

dup <- duplicated(dat)
if(sum(dup)>0){
    warning(paste('Duplicated in table_location_data.csv -->',
                  dat$location_name[dup],collapse = '\n') )
    dat <- dat[!dup,]
}

# Create unique IDs:

dat <- cbind(location_id=1:nrow(dat), dat)

write.csv(x = dat, file = 'table_location.csv', quote = F, row.names = F)
