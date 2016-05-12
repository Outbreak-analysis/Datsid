#### 
####    GENERATE MULTIPLE SYNTHETIC DATA SETS
####

library(snowfall)
library(parallel)
library(ggplot2);theme_set(theme_bw())

source("SEmInR_Gillespie_FCT.R")
source("RESuDe_FCT.R")
source("utils.R")

t1 <- as.numeric(Sys.time())
args <- commandArgs(trailingOnly = TRUE)
n.MC <- as.numeric(args[1])
# --- debug
# n.MC <- 3 ; warning(" * * * * * * n.MC overridden! ")
# - - - ---

pop.size <- 100000
I.init <- 2
horizon.years <- 1.5

### SEmInR parameters:
prmfxd.SEmInR <- list(horizon.years = horizon.years,
					  pop.size      = pop.size,
					  I.init        = I.init,
					  n.MC          = n.MC,
					  remove.fizzles = TRUE)
prm.SEmInR <- create.model.prm("syndata-prmset.csv",
							   modelname = 'SEmInR')

### RESuDe parameters:
prmfxd.RESuDe <- list(pop.size = pop.size,
					  I.init   = I.init,
					  GIspan   = 20,
					  horizon  = round(365*horizon.years,0),
					  n.MC     = n.MC)
prm.RESuDe <- create.model.prm("syndata-prmset.csv",
							   modelname = 'RESuDe')

# Run all data sets 
n.prmsets <- length(prm.SEmInR)+length(prm.RESuDe)
message(paste("\n ===> Simulating",
			  n.prmsets*prmfxd.SEmInR[["n.MC"]],
			  "synthetic data = ",
			  n.prmsets,
			  "parameter sets x",
			  prmfxd.SEmInR[["n.MC"]],"MC ====\n")
)
sfInit(parallel = TRUE, cpu = detectCores())
sfLibrary(adaptivetau)
sfLibrary(plyr)
sfExportAll()
SIM.SEmInR <- sfSapply(prm.SEmInR, wrap.sim.SEmInR, prmfxd=prmfxd.SEmInR, simplify = FALSE)
SIM.RESuDe <- sfSapply(prm.RESuDe, wrap.sim.RESuDe, prmfxd=prmfxd.RESuDe, simplify = FALSE)
sfStop()
message("... simulations done.")

ref.SEmInR <- reformat.synthetic.for.db(SIM = SIM.SEmInR, 
										prm = prm.SEmInR,
										label = "SEmInR")

ref.RESuDe <- reformat.synthetic.for.db(SIM = SIM.RESuDe, 
										prm = prm.RESuDe,
										label = "RESuDe")

save.and.plot(ref.SEmInR, "SEmInR")
save.and.plot(ref.RESuDe, "RESuDe")

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

t2 <- as.numeric(Sys.time())
message(paste("\n\nCompleted in",round((t2-t1)/60,2),"minutes"))
