library(shiny)

source("plot_data.R")

shinyServer(function(input, output) {
	
	output$pf <- renderPlot(
		{
			country    <- input$country
			disease    <- input$disease
			disease_type    <- input$disease_type
			synthetic  <- input$synthetic
			logscale   <- input$logscale
			
			if(country=="any")      country <- NULL
			if(disease=="any")      disease <- NULL
			if(disease_type=="any") disease_type <- NULL
			if(synthetic=="any")    synthetic <- NULL
			
			plot_data(db.name = input$db.name,
					  country = country,
					  disease = disease,
					  disease_type = disease_type,
					  synthetic = synthetic,
					  logscale = logscale
					  )
			
		},
		height=1000, 
		width=1300)
})

