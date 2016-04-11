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
		S[t] <- max(0, S[t-1] - I[t])
	}
	return(list(time = 1:length(I), 
				S = S, 
				I = I))
}


wrap.sim.RESuDe <- function(prm,prmfxd){
	
	pop_size <- prmfxd[["pop_size"]]
	I.init <- prmfxd[["I.init"]]
	GI_span <- prmfxd[["GIspan"]]
	horizon <- prmfxd[["horizon"]]
	n.MC <- prmfxd[["n.MC"]]
	
	R0 <- prm[["R0"]]
	alpha <- prm[["alpha"]]
	kappa <- prm[["kappa"]]
	GI_mean <- prm[["GImean"]]
	GI_var <- prm[["GIvar"]]
	
	df <- data.frame()
	for(i in 1:n.MC){
		message(paste0("RESuDe MC: ",i,"/",n.MC))
		sim <- RESuDe.generate.data (pop_size, 
									 I.init,
									 R0, 
									 alpha, 
									 kappa, 
									 GI_span, 
									 GI_mean, 
									 GI_var,
									 horizon,
									 seed = i)
		tmp <- data.frame(tb  = sim$time,
						  inc = sim$I,
						  mc  = i)
		df <- rbind(df,tmp)
	}
	return(list(inc = df, param = prm))
}

create.RESuDe.prm <- function(filename){
	
	sp <- read.csv(filename, header=F)
	
	get.syn.prm <- function(sp,name){
		tmp <- sp[sp[,1]==name,][-1]
		return(as.numeric(na.omit(as.numeric(tmp))))
	}
	
	# Read model parameters 
	# that will generate synthetic data
	
	R0vec      <- get.syn.prm(sp,"R0") 
	alphavec   <- get.syn.prm(sp,"alpha") 
	kappavec   <- get.syn.prm(sp,"kappa") 
	GI_meanvec <- get.syn.prm(sp,"GImean") 
	GI_varvec  <- get.syn.prm(sp,"GIvar") 
	GI_varRelMeanvec  <- get.syn.prm(sp,"GIvarRelMean") # if variance specified _relative_ to mean (not just an independent value)
	
	n1 <- length(GI_varvec)
	n2 <- length(GI_varRelMeanvec)
	stopifnot(n1==0 | n2==0)
	
	if(n1==0) givar <- GI_varRelMeanvec
	if(n2==0) givar <- GI_varvec
	
	prm <- list()
	cnt <- 1
	for(r in R0vec){
		for(a in alphavec){
			for(k in kappavec){
				for(g1 in GI_meanvec){
					for(g2 in givar){
						gv <- g2
						if(n1==0) gv <- g2*g1
						prm[[cnt]] <- list(R0 = r,
										   alpha = a,
										   kappa = k,
										   GImean = g1,
										   GIvar = gv)
						cnt <- cnt + 1
					}
				}
			}
		}
	}
	return(prm)
}


test <- function(){
	
	sim <- RESuDe.generate.data(pop_size=10000, 
								I.init=2,
								R0 = 6, 
								alpha=0, 
								kappa=0, 
								GI_span=20, 
								GI_mean=3, 
								GI_var=3,
								horizon=180,
								seed=2)
	
	sim$I
	
}
