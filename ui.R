outreach.list<-c("Prabin","Thangsen HC", "Bahunepati HC", "Test1", "Test2")

shinyUI(fluidPage(
  titlePanel("SMS Received"),
  
  column(4, wellPanel(
        dateRangeInput('dateRange',
                   label = 'Select Date: yyyy-mm-dd',
                   start = Sys.Date() - 7, end = Sys.Date()
    ),
    selectInput(inputId="outreach",
                label= "Select Outreach",
                choices= outreach.list,
                multiple = TRUE,
                selected="Thangsen HC")
    
  )),
  
   column(12,
                tabsetPanel(type = "tabs", 
                     tabPanel("Plot", 
                              plotOutput("plot")), 
                     tabPanel("Summary", 
                              tableOutput("dataFrame")), 
                     tabPanel("Table", 
                              verbatimTextOutput("tableText"),
                              tableOutput("table"))
  )
))
)