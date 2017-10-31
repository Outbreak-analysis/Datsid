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
			textInput("db.path",
					  "Database used: ",
					  value = db.name ) ,

			selectInput("country.ISO3166", "Country ISO3166:",
						choices = c(z[["country"]],"any")) ,
			selectInput("location.name", "location.name:",
						choices = c(z[["location.name"]],"any"),
						selected = "any"),
			selectInput("disease.name", "disease.name:",
						choices = c(z[["disease.name"]],"any"),
						selected = "any"),
			selectInput("disease.type", "disease.type:",
			            choices = c(z[["disease.type"]],"any"),
			            selected = "any"),
			selectInput("disease.subtype", "disease.subtype:",
			            choices = c(z[["disease.subtype"]],"any"),
			            selected = "any"),
			selectInput("event.type", "event.type:",
						choices = c(z[["event.type"]],"any"),
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