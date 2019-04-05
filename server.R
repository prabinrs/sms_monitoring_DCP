library(rjson)
library(shiny)
library(ggplot2)
sms_url<- sms_url<-"http://smsprima.com/api/keyword/generateReport?username=dhsms&password=sms%4012345&keyword=DHSMS"
sms_data<-fromJSON(file= sms_url)
sms_results<-sms_data$report
dataSMS<-do.call(rbind.data.frame,sms_results)
#outreach phone numbers
num<-c("9801002207","9801002246","9801002413","9841649480","9851004988","9801002904") 
out<-c("Prabin","Thangsen HC", "Bahunepati HC", "Test1", "Test2","Bahunepati HC")
numOUtreach<-data.frame(out, num)

#adding outreach Names;
dataSMS$outreach<-numOUtreach$out[match(dataSMS$mobile,numOUtreach$num)]
#repeate for each date
data.sum<-subset(dataSMS, select = c("outreach","ondate")) #creating subset for the summary i
data.sum$ondate<-as.Date(data.sum$ondate)
data.byout<-data.frame(table(data.sum$ondate, data.sum$outreach))
names(data.byout)[1]<-"ondate"
names(data.byout)[2]<-"outreach"
names(data.byout)[3]<- "caseReported"
data.byout$ondate<-as.Date(data.byout$ondate)

shinyServer(function(input, output, session) {
  
selection<-reactive({
  selected.data<-data.byout[data.byout$ondate %in% seq(from=as.Date(input$dateRange[1]), to =as.Date(input$dateRange[2]), by="day"),]
  selected.data<-selected.data[selected.data$outreach %in% input$outreach,]
  return(selected.data)
})

tableOutput<-reactive({
  selected.data<-data.byout[data.byout$ondate %in% seq(from=as.Date(input$dateRange[1]), to =as.Date(input$dateRange[2]), by="day"),]
  selected.data<-selected.data[selected.data$outreach %in% input$outreach,]
  selected.data$ondate<-as.character(selected.data$ondate)
  return(selected.data)
})
     output$dateRangeText  <- renderText({
    paste("input$dateRange is", 
          paste(as.character(input$dateRange), collapse = " to ")
    )
  })
    output$table<-renderTable({
      aggregate(selection()$caseReported, by=list(Category=selection()$outreach), FUN=sum)
      })
    output$tableText  <- renderText({
      paste("Total number of SMS repots of patient received on", 
            paste(as.character(input$dateRange), collapse = " to ")
      )
    })
    
    output$dataFrame<-renderTable({
      tableOutput()
    })
    output$plot<-renderPlot({
      ggplot(selection(), aes(x=ondate, y=caseReported, group=outreach, color=outreach))+
        geom_line(size=1,aes(linetype=outreach))+
        geom_point(aes(shape=outreach), size =2)+
        labs(y="Case Reported", x="Date", title="Number of SMS reports send From Outreach Center")
    })
})
