library(ggplot2)
library(DBI)
library(RSQLite)

source("read_db.R")

plot_data <- function(db.name, 
					  country = NULL, 
					  disease = NULL, 
					  disease_type = NULL, 
					  synthetic = NULL,
					  logscale = FALSE) {
	
	dat <- get.epi.ts(db.name, 
					  country,
					  disease,
					  synthetic) 
	
	if(!is.null(disease_type)) {
	    disease_type2 <- disease_type
	    dat <- subset(dat, disease_type==disease_type2)
	}
	
	# Reformat before plots:
	dat$reportdate <- as.Date(dat$reportdate)
	dat$fullloc <- paste(dat$country,dat$adminDiv1,dat$adminDiv2)
	tmp <- substr(dat$eventtype2,1,6)
	tmp[is.na(tmp)] <- ""
	tmp2 <- dat$socialstruct
	tmp2[is.na(tmp2)] <- ""
	dat$datatype <- paste(dat$eventtype,tmp,tmp2)
	dat$sourcedata <- paste("source:", substr(dat$source,1,24))
	dat$synthetic.plot <- paste("synthetic:",dat$synthetic)
	dat$synthetic.plot[dat$synthetic==0] <- "Real epidemic"
	
	## Plots
	
	g <- ggplot(dat)
	
	if(!logscale) {
		g <- g + geom_step(aes(x=reportdate,
							   y=count,
							   colour=datatype),size=2)
	}
	if(logscale) {
		g <- g + geom_point(aes(x=reportdate,
								y=count,
								colour=datatype),size=2)
		g <- g + geom_line(aes(x=reportdate,
								y=count,
								colour=datatype),size=1, alpha=0.5)
		g <- g + scale_y_log10()
	}
	g <- g + facet_wrap(~fullloc + disease_name + sourcedata + synthetic.plot,
						scales = "free")
	
	plot(g)
}
