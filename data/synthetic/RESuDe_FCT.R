###
### RESuDe: Renewal Equation with Susceptible Depletion
###

GI_dist <- function(t, GI_span, GI_mean, GI_var){
	tvec <- 0:GI_span
	GI_k <- GI_mean^2/GI_var
	GI_theta <- GI_var/GI_mean
	tmp <- tvec^GI_k * exp(-GI_theta*tvec)
	tmp2 <- t^GI_k * exp(-GI_theta*t)
	return(tmp2/sum(tmp))
}


RESuDe.generate.data <- function(pop_size, 
						  I.init,
						  R0, 
						  alpha, 
						  kappa, 
						  GI_span, 
						  GI_mean, 
						  GI_var,
						  horizon,
						  seed=123) {
	set.seed(seed)
	
	if(length(I.init)==1){
		# used to generate synthetic data
		I <- vector()
		S <- vector()
		I[1] <- I.init
		S[1] <- pop_size - I.init
		numobs <- 1
	}
	if(length(I.init)>1){
		# Used when forecasting
		numobs <- length(I.init)
		I <- I.init
		S <- pop_size - cumsum(I.init)
	}
	
	for(t in (numobs+1):(numobs+horizon)){
		z <- 0
		for(j in 1:min(GI_span,t-1)){
			z <- z + GI_dist(j, GI_span, GI_mean, GI_var) * I[t-j]
		}
		I.tmp <- (S[t-1]/ pop_size)^(1+alpha) * R0 * exp(-kappa*t) * z 
		I[t] <- rpois(n=1, lambda =  min(I.tmp, S[t-1]) )
		S[t] <- S[t-1] - I[t]
	}
	return(list(time = 1:length(I), 
				S = S, 
				I = I))
}
