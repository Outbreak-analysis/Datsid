library(shiny)

source("plot_data.R")

shinyServer(function(input, output) {
	
	output$pf <- renderPlot(
		{
		    db.path <- input$db.path
		    country.ISO3166    <- input$country.ISO3166
			location.name    <- input$location.name
			disease.name   <- input$disease.name
			disease.type  <- input$disease.type
			disease.subtype  <- input$disease.subtype
			event.type  <- input$event.type
			logscale   <- input$logscale

			if(country.ISO3166=="any") country.ISO3166 <- ''
			if(location.name=="any") location.name <- ''
			if(disease.name=="any") disease.name <- ''
			if(disease.type=="any") disease.type <- ''
			if(disease.subtype=="any") disease.subtype <- ''
			if(event.type=="any")   event.type <- ''

			plot_data(db.path,
			          country.ISO3166,
			          location.name,
			          disease.name ,
			          disease.type,
			          disease.subtype,
			          event.type,
			          synthetic,
			          logscale = logscale)
			
		},
		height=1000, 
		width=1300)
})

