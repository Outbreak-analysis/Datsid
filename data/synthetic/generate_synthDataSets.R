#### 
####    GENERATE MULTIPLE SYNTHETIC DATA SETS
####    USING A SEmInR STOCHASTIC MODEL
####

library(snowfall)
library(parallel)
library(ggplot2);theme_set(theme_bw())
source("SEmInR_Gillespie_FCT.R")

args <- commandArgs(trailingOnly = TRUE)
n.MC <- as.numeric(args[1])
# --- debug
# n.MC <- 3
# - - - ---
wrap.sim <- function(prm,prmfxd) {
	
	# unpack fixed parameters:
	horizon.years <- prmfxd[["horizon.years"]]
	pop.size <- prmfxd[["pop.size"]]
	I.init <- prmfxd[["I.init"]]
	n.MC <- prmfxd[["n.MC"]]
	remove.fizzles <- prmfxd[["remove.fizzles"]]
	
	# unpack variable parameters:
	DOL.days <- prm[["DOL.days"]]
	DOI.days <- prm[["DOI.days"]]
	R0 <- prm[["R0"]]
	nE <- prm[["nE"]]
	nI <- prm[["nI"]]
	
	sim <- simul.SEmInR(horizon.years=horizon.years ,
						DOL.days=DOL.days,
						DOI.days=DOI.days,
						R0=R0 ,
						pop.size=pop.size,
						nE=nE,
						nI=nI,
						I.init=I.init,
						n.MC=n.MC,
						remove.fizzles=remove.fizzles,
						save.to.Rdata.file = FALSE)
	return(sim)
}

prmfxd <- list(horizon.years = 1.3,
			   pop.size = 1E4,
			   I.init = 2,
			   n.MC = n.MC,
			   remove.fizzles = TRUE)

# Define the various model parameters (data sets):
Dvec <- c(2, 8)
R0vec <- c(1.5, 3, 6)
nI <- nE <- 5

prm <- list()
cnt <- 1
for(d in Dvec){
	for(r in R0vec){
		prm[[cnt]] <- list(DOL.days = d,
						 DOI.days = d,
						 R0 = r,
						 nE = nE,
						 nI = nI)
		cnt <- cnt + 1
	}
}

message(paste("\n ===> Simulating",
			  length(prm)*prmfxd[["n.MC"]],
			  "synthetic data = ",
			  length(prm),
			  "parameter sets x",
			  prmfxd[["n.MC"]],"MC ====\n")
		)

t1 <- as.numeric(Sys.time())
# Run all data sets 
sfInit(parallel = TRUE, cpu = detectCores())
sfLibrary(adaptivetau)
sfLibrary(plyr)
sfExportAll()
SIM <- sfSapply(prm, wrap.sim, prmfxd=prmfxd, simplify = FALSE)
sfStop()

message("... done.")

df <- data.frame()
mc.chosen <- 1:4

for(i in 1:length(prm)){
	title <- paste(names(SIM[[i]][["param"]]),
				   SIM[[i]][["param"]],
				   sep="_", collapse = ";")
	title <- paste0("BACKTEST_",i,";",title)
	tmp <- SIM[[i]][["inc"]]
	tmp <- subset(tmp, mc %in% mc.chosen)
	tmp$title <-factor(title)
	tmp$title2 <- i
	df <- rbind(df, tmp)
}


# Re-format dataframe for database:
n <- nrow(df)

date_vec <- format(Sys.Date()+ df$tb, "%Y-%m-%d")
df.db <- data.frame(disease_id = 99999,
					location_id = 99999,
					eventdate = date_vec,
					reportdate = date_vec,
					count = df$inc,
					eventype = "incidence",
					eventype2 = "",
					ageMin = "",
					ageMax = "",
					gender = "",
					socialstruct = "",
					synthetic = df$mc,
					source = df$title)

filesave <- "../syn-data.csv"

write.table(x = df.db, 
			file = filesave, 
			col.names = FALSE,
			row.names = FALSE,
			sep = ",")

message(paste("\n\n--> SYNTHETIC DATA SAVED IN:",filesave,"\n"))

pdf("plot_synthdata.pdf",width=22,height = 15)
g <- ggplot(df) + geom_step(aes(x=tb,y=inc,colour=factor(mc)),size=1)
g <- g + facet_wrap(~title) + scale_y_log10()
plot(g)
dev.off()



# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

t2 <- as.numeric(Sys.time())
message(paste("Completed in",round((t2-t1)/60,2),"minutes"))





