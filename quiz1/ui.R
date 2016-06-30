#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(pageWithSidebar(  
  headerPanel("Example plot"),  
  sidebarPanel(    
    sliderInput('mu', 'Guess at the mu',value = 70, min = 60, max = 80, step = 0.05)  ), 
  mainPanel(    
    plotOutput('myHist')  
  )
))