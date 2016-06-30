library(manipulate)
myPlot <- function(s) {
  plot(cars$dist - mean(cars$dist), cars$speed - mean(cars$speed))
  abline(0, s)
}
manipulate(myPlot(s), s = slider(0, 2, step = 0.1))

library(rCharts)
dTable(airquality, sPaginationType = "full_numbers")

library(shiny)
shinyUI(pageWithSidebar(  
  headerPanel("Data science FTW!"),  
  sidebarPanel(    
    h2('Big text'),    
    h3('Sidebar')  
  ),  
  mainPanel(      
    h3('Main Panel text')  
  )
))