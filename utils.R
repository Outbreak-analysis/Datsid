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


slice.recurrent.timeseries <- function(dat,w){
	### SLiCES A TIME SERIES WITH RECURRING EPIDEMICS
	###
	
	pk <- peaks(x = dat$inc, w)
	tr <- troughs(x = dat$inc, w)
	
	t.pk <- dat$t[pk]
	t.tr <- dat$t[tr]
	t.tr <- t.tr[diff(t.tr)>w]
	if(t.tr[1]<t.pk[1]) t.tr <- t.tr[1:length(t.pk)]
	if(t.tr[1]>t.pk[1]) {
		while(length(t.tr)!=length(t.pk)) t.pk <- t.pk[-1]
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