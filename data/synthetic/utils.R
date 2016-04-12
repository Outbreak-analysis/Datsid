
create.model.prm <- function(filename, modelname){
	
	x0 <- read.table(filename, header=TRUE,sep=',')
	x <- subset(x0, model==modelname)
	
	prm <- list()
	for(i in 1:nrow(x)){
		if(x$model=="SEmInR"){
			prm[[i]] <- list(R0       = x$R0[i],
							 DOL.days = x$DOL[i],
							 DOI.days = x$DOI[i],
							 nE       = x$nE[i],
							 nI       = x$nI[i]
			)
		}
		if(x$model=="RESuDe"){
			prm[[i]] <- list(R0       = x$R0[i],
							 GImean   = x$GImean[i],
							 GIvar    = x$GIvar[i],
							 alpha    = x$alpha[i],
							 kappa    = x$kappa[i]
			)
		}
		
	}
	return(prm)
}


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

