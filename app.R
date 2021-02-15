library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)
library(ggthemes)
library(shinydashboard)

# Data Preparation Steps
proper=function(x) paste0(toupper(substr(x, 1, 1)), tolower(substring(x, 2)))

setwd("D:/Dropbox/ACOABO/hanau")

#prepare the data
dat <- readRDS("mockdata.RDS")
dat$attack<-sample(c("hanau","berlin"),1000,T)

dat$days_since_attack[dat$attack=="hanau"]<-round(as.numeric(dat$published[dat$attack=="hanau"]-quantile(dat$published,0.4),unit="days"),1)
dat$days_since_attack[dat$attack=="berlin"]<-round(as.numeric(dat$published[dat$attack=="berlin"]-quantile(dat$published,0.6),unit="days"),1)
dat<-dat[order(dat$published),]

#pepare the subset of columns that will be shown to users:
dat$Datum<-strftime(dat$published,"%d.%m.%Y")
dat$Titel<-apply(dat[,c("kicker","title")],1,paste,collapse=": ")
dat$Link <- paste0("<a href='",dat$link,"'>",dat$Titel,"</a> (",dat$author,")")
dat$Zeitung<-proper(dat$zeitung)
dat$Anschlag<-proper(dat$attack)

ui <- dashboardPage(
  
  dashboardHeader(title="Medienresonanz Großer Zeitungen zum Rassistischen Anschlag in Hanau",titleWidth="100%"),
  
    dashboardSidebar(
      selectInput(inputId="attack",label="Attentat",choices = c("Hanau"="hanau","Berlin"="berlin"),
                  selected = "hanau",multiple = T),
      selectInput(inputId="paper",label="Zeitungen",choices = c("Bild"="bild","Der Spiegel"="spiegel"),
                  selected = c("bild","spiegel"),multiple = T),
      sliderInput(inputId = "timeframe",
                  label = "Tage vor und nach dem Attentat:",
                  min = -90, max = 365*2,value = c(-30,365)),
      h4("Erläuterungen"),
      helpText("test")),
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
                                         zeitung %in% input$paper &
                                           attack %in% input$attack &
                                           days_since_attack > input$timeframe[1] &
                                           days_since_attack < input$timeframe[2],
                                         select=c("Datum","Zeitung","Link")
  ),
  escape = FALSE, #make sure <a> links are shown as links
  options = list(autoWidth = TRUE,columnDefs = list(list(width = '10px', targets = c(0,1))))) #column width
  
  #line plot:
  output$plot1=renderPlotly({
    ggplotly(ggplot(data=subset(dat,zeitung %in% input$paper &attack %in% input$attack),
                    aes(x=days_since_attack)) +
               geom_freqpoly(aes(group=attack,colour = proper(attack)),binwidth = 7) +
               theme_tufte()+labs(x="Tage seit Anschlag", y="Anzahl publizierter Artikel pro Woche") +
               scale_color_discrete(name="") +
               xlim(input$timeframe)  #for the lineplot the limits  restrict the time frame
    ) %>%  layout(legend = list(orientation = "v",xanchor ="right",yanchor="top"))
  })
  
  output$plot2 = renderPlotly({
    if (input$timeframe[2] > as.numeric(Sys.Date()-as.Date("2020-02-19"),unit="days") + 10) {
      ggplot() + 
        annotate("text", x = 4, y = 25, size=8, label = "Zeiträume nicht vergleichbar.\nZeitraum verkürzen.") + 
        theme_void() +   theme(axis.title.x=element_blank(),
                               axis.text.x=element_blank(), axis.line=element_blank(),axis.ticks.x=element_blank())
    } else {
      ggplotly(
        ggplot(subset(dat,
                      zeitung %in% input$paper &
                        attack %in% input$attack& #for the histogram i manually restrict the time frame
                        days_since_attack > input$timeframe[1] &
                        days_since_attack < input$timeframe[2]),
               aes(x=proper(zeitung),fill=attack)) +
          labs(x="",y=paste0("Artikel zw. ",-input$timeframe[1]," Tagen vor und ", input$timeframe[2]," Tagen nach dem Anschlag",collapse =""))+
          theme_tufte()+theme(legend.position="none")+
          geom_bar(position = "dodge")+
          geom_text(aes(label=paste0("<br />",proper(attack))), stat='count', position=position_dodge(width=0.9))
      )
    }
  })
  
}

shinyApp(ui = ui, server = server)