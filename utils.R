peaks <- function(x,w,do.plot=FALSE){
	### Finds the peaks of a (noisy) time series 'x'
	### by simply looking, for each point, if the 
	### 'w' neighbours both on left and right are smaller.
	### The larger 'w', the less false positives and the more false negative.
	
	n <- length(x)
	pk <- rep(FALSE,n)
	for(i in (w+1):(n-w)){
		if(all( x[i] >= x[(i-w):(i+w)] )) pk[i] <- TRUE
	}
	if(do.plot){
		plot(x,typ='l', lwd=3)
		t <- 1:length(x)
		abline(v=t[pk],col='red')
		points(x=t[pk], y=inc[pk],col='red',pch=14,cex=2)
	}
	return(pk)
}

troughs <- function(x,w,do.plot=FALSE){
	return(peaks(-x,w,do.plot))
}

# set.seed(123)
# tt <- 1:200
# x <- cos(tt/10)+0.2*rnorm(n=length(tt))
# tpeak1 <- 68
# tpeak2 <- 125
# plot(x,typ='l')
# abline(v=c(tpeak1,tpeak2))

trough.bw.peaks <- function(x,idx.peak1,idx.peak2){
	# Return the earliest troughs 
	# between 2 already identified peak times
	xx <- x[idx.peak1:idx.peak2]
	tmp <- which.min(xx)
	return(idx.peak1+tmp[1]-1)
}


slice.recurrent.timeseries.old <- function(dat,w){
	### SLiCES A TIME SERIES WITH RECURRING EPIDEMICS
	###
	
	pk <- peaks(x = dat$inc, w)
	tr <- troughs(x = dat$inc, w)
	
	t.pk <- dat$t[pk]
	t.tr <- dat$t[tr]
	t.tr <- t.tr[diff(t.tr)>w]
	if(t.tr[1]<t.pk[1]) t.tr <- t.tr[1:length(t.pk)]
	if(t.tr[1]>t.pk[1]) {
		while(t.tr[1]>t.pk[1]) t.pk <- t.pk[-1]
	}
	inc.tr <- dat$inc[dat$t %in% t.tr]
	
	plot(dat$t,dat$inc,typ='l')
	points(t.pk,dat$inc[pk], col='red',pch=16)
	points(t.tr,inc.tr, col='blue',pch=1)
	text(x=t.tr,y=inc.tr, labels = t.tr,pos=1,cex=0.5)
	
	n.pk <- sum(pk)
	n.tr <- sum(tr)
	n <- min(c(length(t.tr),length(t.pk)))
	slice <- list()
	
	for(i in 1:n){ 
		tslice <- t.tr[i]:t.pk[i]
		inc_i <-  dat$inc[dat$t %in% tslice]
		slice[[i]] <- data.frame(t = 1:length(inc_i), 
								 inc = inc_i)
	}
	
	# for(i in 1:length(slice)){ 
	# 	plot(slice[[i]]$t, slice[[i]]$inc,typ='o',log='y')
	# }
	return(slice)
}



# dat <- get.db.data("../Datsid/a.db", epichoice="measles.UK.London")
# w <- 50

slice.recurrent.timeseries <- function(dat,w){
	### SLiCES A TIME SERIES WITH RECURRING EPIDEMICS
	###
	
	# find peaks and troughs:
	pk <- peaks(x = dat$inc, w)
	t.pk <- dat$t[pk]
	idx.peak <- which(pk)
	
	# find troughs between peaks:
	idx.tr <- vector()
	for(i in 1:(length(idx.peak)-1)){
		idx.tr[i] <- trough.bw.peaks(x = dat$inc, 
								   idx.peak1 = idx.peak[i], 
								   idx.peak2 = idx.peak[i+1])
		
	}
	
	t.tr <- dat$t[idx.tr]
	
	# Remove peaks and troughs that are too closes:
	t.tr <- t.tr[diff(t.tr)>w]
	t.pk <- t.pk[diff(t.pk)>w]
	
	# First plot of identified extrema, without further filtering:
	plot(dat$t,dat$inc,typ='l',main="extrema before filter")
	points(t.pk,dat$inc[dat$t %in% t.pk],pch=16)
	points(t.tr,dat$inc[dat$t %in% t.tr],pch=17,col='red')
	
	# make sure we start with a trough:
	if(t.tr[1]<t.pk[1]) t.tr <- t.tr[1:length(t.pk)]
	if(t.tr[1]>t.pk[1]) {
		while(t.tr[1]>t.pk[1]) t.pk <- t.pk[-1]
	}
	inc.tr <- dat$inc[dat$t %in% t.tr]
	inc.pk <- dat$inc[dat$t %in% t.pk]
	
	# DELETE ???
	# Only keep consecutive troughs & peaks
	# (everything is discarded after 2 consecutive peaks or troughs)
	# keep.slice <- slope.tr.pk > 0 
	# t.tr <- t.tr[keep.slice]
	# t.pk <- t.pk[keep.slice]
	# inc.tr <- inc.tr[keep.slice]
	# inc.pk <- inc.pk[keep.slice]
	# - - - - - - 
	
	slope.tr.pk <- (inc.pk-inc.tr)/(t.pk-t.tr)
	# Plots identified extrema after filter:
	plot(dat$t,dat$inc,typ='l',main="Identified extrema after filter")
	points(t.pk,inc.pk, col='red',pch=16)
	points(t.tr,inc.tr, col='blue',pch=17)
	text(x=t.tr,y=inc.tr, labels = t.tr,pos=1,cex=0.5)
	text(x=t.pk,y=inc.pk, labels = (1:length(inc.pk)),pos=3,cex=0.5)
	segments(x0=t.tr,y0=inc.tr, x1=t.pk,y1=inc.pk,col = 'orange',lty=1,lwd=3)
	
	# Save growth phase in separate data frames:
	n <- min(c(length(t.tr),length(t.pk)))
	slice <- list()
	for(i in 1:n){ 
		tslice <- t.tr[i]:t.pk[i]
		inc_i <-  dat$inc[dat$t %in% tslice]
		slice[[i]] <- data.frame(t = 1:length(inc_i), 
								 inc = inc_i)
	}
	return(slice)
}