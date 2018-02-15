library(shiny)
source('plot_data.R')

# Database name and path:
# (hard-coded for now, don't see a good reason to make this a variable...)
db.path <- 'datsid.db'

# Retrieve the data frame listing all epidemics
# in the database
message(paste('Loading database',db.path,'... '))
df <- list.all.epidemics(db.path)
message(paste('Database',db.path,'loaded.'))

replace.na.by.null <- function(x) {
    res <- x
    if(is.na(x) | x=='NA') {res <- NULL}
    return(res)
}
replace.empty.by.empty <- function(x) {
    res <- x
    if(!is.null(x)){
        if(x=='empty') {res <- ''}
    }
    return(res)
}

ui <- fluidPage(
    # Application title
    titlePanel("Database of Infectious Diseases Time Series"),
    
    sidebarLayout(
        sidebarPanel(width=2,
                     textInput("db.path",
                               "Database used: ",
                               value = db.path ) ,
                     
                     htmlOutput("country_selector"),
                     htmlOutput("location_selector"),
                     htmlOutput("disease_selector"),
                     htmlOutput("disease_type_selector"),
                     htmlOutput("disease_subtype_selector"),
                     htmlOutput("event_type_selector"),
                     checkboxInput("logscale",
                                   "Log scale", value=FALSE),
                     actionButton("go", "Update plot")
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("pf")
        )
    )
)


server <- function(input, output, session) {
    
    
    output$country_selector <- renderUI({
        u_cntry <- as.character(unique(df$country))
        selectInput(
            inputId = "country", 
            label = "Country",
            choices = u_cntry,
            selected = u_cntry[1])
    })
    
    output$location_selector <- renderUI({
        u_loc <- unique(df[df$country == input$country, 
                           "location_name"])
        # The inputSelector takes the column name
        # when there is only 1 row, so change from
        # data frame to character vector:
        if(nrow(u_loc)==1) {
            u_loc <- as.character(u_loc)
        }
        selectInput(
            inputId = "location_name", 
            label = "Location name",
            choices  = u_loc,
            selected = u_loc[1])
    })
    
    output$disease_selector <- renderUI({
        u_dis <- unique(df[df$country == input$country & 
                               df$location_name == input$location_name, 
                           "disease_name"])
        if(nrow(u_dis)==1) {
            u_dis <- as.character(u_dis)
        }
        selectInput(
            inputId = "disease_name", 
            label = "Disease name",
            choices  = u_dis,
            selected = u_dis[1])
    })
    
    output$disease_type_selector <- renderUI({
        u_typ <- unique(df[df$country == input$country & 
                               df$location_name == input$location_name & 
                               df$disease_name == input$disease_name, 
                           "disease_type"])
        if(nrow(u_typ)==1) {
            u_typ <- as.character(u_typ)
        }
        if(sum(is.na(u_typ))==0){
            u_typ <- c(u_typ,NA)
        }
        
        selectInput(
            inputId = "disease_type", 
            label = "Disease type",
            choices  = c(u_typ,'empty'),
            selected = NA)
    })
    
    output$disease_subtype_selector <- renderUI({
        
        dis_typ <- input$disease_type
        dis_typ <- replace.na.by.null(dis_typ)
        dis_typ <- replace.empty.by.empty(dis_typ)
        
        u_sub <- unique(df[df$country == input$country &
                               df$location_name == input$location_name &
                               df$disease_name == input$disease_name &
                               df$disease_type == dis_typ,
                           "disease_subtype"])
        if(nrow(u_sub)==1) {
            u_sub <- as.character(u_sub)
        }
        if(sum(is.na(u_sub))==0){
            u_sub <- c(u_sub,NA)
        }
        
        selectInput(
            inputId = "disease_subtype",
            label = "Disease subtype",
            choices  = c(u_sub,'empty'),
            selected = NA)
    })
    
    output$event_type_selector <- renderUI({
        
        dis_typ <- input$disease_type
        dis_typ <- replace.na.by.null(dis_typ)
        dis_typ <- replace.empty.by.empty(dis_typ)
        
        dis_sub <- input$disease_subtype
        dis_sub <- replace.na.by.null(dis_sub)
        dis_sub <- replace.empty.by.empty(dis_sub)
        
        dis_typ_cond <- TRUE
        if(!is.null(dis_typ)) {dis_typ_cond <- (df$disease_type == dis_typ)}
        dis_sub_cond <- TRUE
        if(!is.null(dis_sub)) {dis_sub_cond <- (df$disease_subtype == dis_sub)}
        
        u_evt <- unique(df[df$country == input$country &
                               df$location_name == input$location_name &
                               df$disease_name == input$disease_name &
                               dis_typ_cond &
                               dis_sub_cond,
                           "eventtype"])
        if(nrow(u_evt)==1) {
            u_evt <- as.character(u_evt)
        }
        if(sum(is.na(u_evt))==0){
            u_evt <- c(u_evt,NA)
        }
        selectInput(
            inputId = "eventtype",
            label = "Event type",
            choices  = c(u_evt,'empty'),
            selected = NA)
    })
    
    # ---- PLOT ----
    
    theplot <- eventReactive(input$go, {
        db.path       <- input$db.path
        country       <- input$country
        location.name <- input$location_name
        disease.name  <- input$disease_name
        disease.type  <- input$disease_type
        disease.subtype  <- input$disease_subtype
        event.type    <- input$eventtype
        logscale      <- input$logscale
        
        disease.type    <- replace.na.by.null(disease.type)
        disease.subtype <- replace.na.by.null(disease.subtype)
        event.type      <- replace.na.by.null(event.type)
        
        disease.type    <- replace.empty.by.empty(disease.type)
        disease.subtype <- replace.empty.by.empty(disease.subtype)
        event.type      <- replace.empty.by.empty(event.type)

        plot_data(db.path,
                  country.ISO3166 = country,
                  location.name,
                  disease.name ,
                  disease.type,
                  disease.subtype,
                  event.type,
                  synthetic,
                  logscale = logscale)
    })
    
    output$pf <- renderPlot(
        {
            theplot()
        },
        height = 1000, 
        width  = 1100)
} # server

shinyApp(ui, server)