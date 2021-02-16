library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)
library(ggthemes)
library(shinydashboard)
try({setwd('~/hanau-media/')})
try({setwd('D:/Dropbox/hanau-media')})
source('pseudo apis.R')
source('0 - config.R')

results<-readRDS("2 - cleanedsearchresults.RDS")
dat<-results$dat
#prepare the data

ui <- dashboardPage(
  
  dashboardHeader(title="Medienresonanz Deutscher Zeitungen zum Rassistischen Anschlag in Hanau",titleWidth="100%"),
  
    dashboardSidebar(
      selectInput(inputId="Anschlag",label="Attentat",choices = unique(dat$Anschlag),
                  selected = "Hanau",multiple = T),
      selectInput(inputId="Zeitung",label="Zeitungen",choices = unique(dat$Zeitung),
                  selected = unique(dat$Zeitung),multiple = T),
      sliderInput(inputId = "timeframe",
                  label = "Tage vor und nach dem Attentat:",
                  min = -90, max = 365*2,value = c(-30,365)),
      h4("Erläuterungen"),
      helpText(
        paste0("Articles on Hanau are identified as matching any of these search terms:\n",
                                  paste0(prefix_hanau,collapse=", "),
                                  "\ncombined and a suffix:\n",
                                  paste0(suffix,collapse=", "),
                                  "\non spiegel.de/suche, https://www.faz.net/suche/, sueddeutsche.de/news, and www.bild.de/suche.bild.html.\n",
                                  "Articles on Berlin are identified through these terms:\n",
                                  paste0(prefix_berlin,collapse=", "),
                                  "\nwith the same suffixes. The last update of the search results happened on ",results$date
                )
      )),
      dashboardBody(
      fluidRow(column(7,plotlyOutput('plot1')), column(5,plotlyOutput('plot2'))),
      hr(),
      dataTableOutput('table')  
    )
)

# Define server logic required to draw a histogram ----
server <- function(input, output){
  
  #table that is shown in the lower section
  output$table <- renderDataTable( subset(dat,
                                         Zeitung %in% input$Zeitung &
                                           Anschlag %in% input$Anschlag &
                                           days_since_attack > input$timeframe[1] &
                                           days_since_attack < input$timeframe[2],
                                         select=c("Datum","Zeitung","Link")
  ),
  escape = FALSE, #make sure <a> links are shown as links
  options = list(autoWidth = TRUE,columnDefs = list(list(width = '10px', targets = c(0,1))))) #column width
  
  #line plot:
  output$plot1=renderPlotly({
    ggplotly(ggplot(data=subset(dat,Zeitung %in% input$Zeitung &Anschlag %in% input$Anschlag),
                    aes(x=days_since_attack)) +
               geom_freqpoly(aes(group=attack,colour = Anschlag),binwidth = 7) +
               theme_tufte()+labs(x="Tage seit Anschlag", y="Anzahl publizierter Artikel pro Woche") +
               scale_color_discrete(name="") +
               xlim(input$timeframe)  #for the lineplot the limits  restrict the time frame
    ) %>%  layout(legend = list(orientation = "v",xanchor ="right",yanchor="top"))
  })
  
  output$plot2 = renderPlotly({
    if (length(input$Anschlag)>1 & input$timeframe[2] > as.numeric(Sys.Date()-as.Date("2020-02-19"),unit="days") + 10) {
      ggplot() + 
        annotate("text", x = 4, y = 25, size=8, label = "Zeiträume nicht vergleichbar.\nZeitraum verkürzen.") + 
        theme_void() +   theme(axis.title.x=element_blank(),
                               axis.text.x=element_blank(), axis.line=element_blank(),axis.ticks.x=element_blank())
    } else {
      ggplotly(
        ggplot(subset(dat,
                      Zeitung %in% input$Zeitung &
                        Anschlag %in% input$Anschlag& #for the histogram i manually restrict the time frame
                        days_since_attack > input$timeframe[1] &
                        days_since_attack < input$timeframe[2]),
               aes(x=Zeitung,fill=attack)) +
          labs(x="",y=paste0("Artikel zw. ",-input$timeframe[1]," Tagen vor und ", input$timeframe[2]," Tagen nach dem Anschlag",collapse =""))+
          theme_tufte()+theme(legend.position="none")+
          geom_bar(position = "dodge")+
          geom_text(aes(label=paste0("<br />",Anschlag)), stat='count', position=position_dodge(width=0.9))
      )
    }
  })
  
}

shinyApp(ui = ui, server = server)