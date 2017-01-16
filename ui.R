library(shiny)

source("read_db.R")

get.db.name <- function(){
	dbname <- system("ls *.db",intern = TRUE)[1]
}

db.name <- get.db.name()
z <- get.list.existing(db.name[1])

shinyUI(fluidPage(
	# Application title
	titlePanel("Database of Infectious Diseases Time Series"),
	
	# Sidebar with a slider input for the number of bins
	sidebarLayout(
		sidebarPanel(
			textInput("db.name",
					  "Database used: ",
					  value = db.name ),
			
			selectInput("country", "Country:", 
						choices = c(z[["countries"]],"any")),
			selectInput("disease", "Disease:", 
						choices = c(z[["diseases"]],"any"),
						selected = "any"),
			selectInput("disease_type", "Disease type:", 
						choices = c(z[["diseases_type"]],"any"),
						selected = "any"),
			selectInput("synthetic", "Synthetic (0=real epidemic):", 
						choices = c(z[["synthetics"]],"any"),
						selected = "any"),
			
			checkboxInput("logscale",
						  "Log scale", value=FALSE)
		),
		
		# Show a plot of the generated distribution
		mainPanel(
			plotOutput("pf")
		)
	)
))