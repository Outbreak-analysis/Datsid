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
