#### 
####    GENERATE MULTIPLE SYNTHETIC DATA SETS
####

library(snowfall)
library(parallel)
library(ggplot2);theme_set(theme_bw())

source("SEmInR_Gillespie_FCT.R")
source("RESuDe_FCT.R")

args <- commandArgs(trailingOnly = TRUE)
n.MC <- as.numeric(args[1])
# --- debug
# n.MC <- 3 ; warning(" * * * * * * n.MC overridden! ")
# - - - ---

t1 <- as.numeric(Sys.time())

pop.size <- 100000
I.init <- 2
horizon.years <- 1.3

### SEmInR parameters:
prmfxd.SEmInR <- list(horizon.years = horizon.years,
					  pop.size      = pop.size,
					  I.init        = I.init,
					  n.MC          = n.MC,
					  remove.fizzles = TRUE)
prm.SEmInR <- create.SEmInR.prm("syndata-prmset.csv")

### RESuDe parameters:
prmfxd.RESuDe <- list(pop_size = pop.size,
					  I.init   = I.init,
					  GIspan   = 20,
					  horizon  = round(365*horizon.years,0),
					  n.MC     = n.MC)
prm.RESuDe <- create.RESuDe.prm(filename = "syndata-prmset.csv")

# Run all data sets 

message(paste("\n ===> Simulating",
			  length(prm.SEmInR)*prmfxd.SEmInR[["n.MC"]],
			  " synthetic data = ",
			  length(prm.SEmInR),
			  "parameter sets x",
			  prmfxd.SEmInR[["n.MC"]],"MC ====\n")
)
sfInit(parallel = F, cpu = detectCores())
sfLibrary(adaptivetau)
sfLibrary(plyr)
sfExportAll()
SIM.SEmInR <- sfSapply(prm.SEmInR, wrap.sim.SEmInR, prmfxd=prmfxd.SEmInR, simplify = FALSE)
SIM.RESuDe <- sfSapply(prm.RESuDe, wrap.sim.RESuDe, prmfxd=prmfxd.RESuDe, simplify = FALSE)
sfStop()
message("... simulations done.")

reformat.synthetic.for.db <- function(SIM, prm, label) {
	### REFORMAT SYNTHETIC DATA FOR DATABASE
	### 'label' IS THE LABEL FOR THE MODEL THAT
	### GENERATED THE DATA.
	
	df <- data.frame()
	# Merge and label database's source with
	# the model used and its parameters
	for(i in 1:length(prm)){
		title <- paste(names(SIM[[i]][["param"]]),
					   format(SIM[[i]][["param"]],
					   	   scientific = FALSE),
					   sep="_", collapse = ";")
		title <- paste0(label,"_",i,";",title)
		tmp <- SIM[[i]][["inc"]]
		tmp$title <-factor(title)
		tmp$title2 <- i
		df <- rbind(df, tmp)
	}
	
	# Re-format dataframe for database's fields:
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
	
	return(list(df=df, df.db=df.db))
}

ref.SEmInR <- reformat.synthetic.for.db(SIM = SIM.SEmInR, 
										prm = prm.SEmInR,
										label = "SEmInR")

ref.RESuDe <- reformat.synthetic.for.db(SIM = SIM.RESuDe, 
										prm = prm.RESuDe,
										label = "RESuDe")

save.and.plot <- function(ref, modelname){
	df <- ref[["df"]]
	df.db <- ref[["df.db"]]
	filesave <- paste0("../syn-data-",modelname,".csv")
	write.table(x = df.db, 
				file = filesave, 
				col.names = FALSE,
				row.names = FALSE,
				sep = ",")
	
	message(paste("\n\n--> SYNTHETIC DATA SAVED IN:",filesave,"\n"))
	pdf(paste0("plot_syn-data-",modelname,".pdf"), width=22, height = 15)
	g <- ggplot(df) + geom_step(aes(x=tb,y=inc,colour=factor(mc)),size=1)
	g <- g + facet_wrap(~title) + scale_y_log10()
	plot(g)
	dev.off()
}

save.and.plot(ref.SEmInR, "SEmInR")
save.and.plot(ref.RESuDe, "RESuDe")

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

t2 <- as.numeric(Sys.time())
message(paste("Completed in",round((t2-t1)/60,2),"minutes"))
