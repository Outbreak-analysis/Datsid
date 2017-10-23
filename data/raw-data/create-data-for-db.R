###
###   LAUNCH ALL SCRIPTS TO CREATE CSV FILES FORMATED FOR DATABASE
###

t0 <- as.numeric(Sys.time())
# Clean up

system('rm -rf *.RData')
system('rm -rf *-db.csv')


# First download data whenever possible

ls.web <- system('ls *-web.R', intern = TRUE)
for(i in 1:length(ls.web)){
  message(paste('---> DOWNLOADING:', ls.web[i]))
  system(paste('Rscript',ls.web[i]))
}

# Reformat all raw data into the database format:
ls.ref <- system('ls *-reformat.R', intern = TRUE)
for(i in 1:length(ls.ref)){
  message(paste('---> REFORMATING:', ls.ref[i]))
  system(paste('Rscript',ls.ref[i]))
}

# copy csv files to 'data':
system('ls -alh *-db.csv')
system('cp *-db.csv ../')

t1 <- as.numeric(Sys.time())
dt <- t1-t0
msg <- paste('Data downloaded and reformated in',round(dt/60,1),'minutes')
message(msg)
