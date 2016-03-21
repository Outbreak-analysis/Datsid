library(shiny)

source("plot_data.R")

shinyServer(function(input, output) {
	
	output$pf <- renderPlot(
		{
			country <- input$country
			disease <- input$disease
			synthetic <- input$synthetic
			logscale <- input$logscale
			
			if(country=="none") country <- NULL
			if(disease=="none") disease <- NULL
			if(synthetic=="none") synthetic <- NULL
			
			plot_data(db.name = input$db.name,
					  country = country,
					  disease = disease,
					  synthetic = synthetic,
					  logscale = logscale
					  )
			
		},
		height=1000, 
		width=1300)
})

