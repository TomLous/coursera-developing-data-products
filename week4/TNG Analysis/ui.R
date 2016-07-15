library(shiny)

shinyUI(fluidPage(

  
  titlePanel("Star Trek TNG Dialog Exploration"),

  fluidRow(
    column(3,
      HTML("<b>Explores the dialog of all Star Trek TNG Episodes</b><br>
                 <i>Based of the dataset available at <a href=\"https://github.com/RMHogervorst/startrekTNGdataset\" target=\"_blank\">https://github.com/RMHogervorst/startrekTNGdataset</a></i><br>
                 <i>Code for this project <a href=\"https://github.com/TomLous/coursera-developing-data-products/tree/master/week4/TNG%20Analysis\" target=\"_blank\">https://github.com/TomLous/coursera-developing-data-products/tree/master/week4/TNG Analysis</a></i><br>
                <br>Filtered the script dataset to aggegate all dialog text per main character per episode.<br>
                Created features numLines, numWords & numSections per character (number of lines together in the script / single record in original dataset)<br>
                Trained a random forest on these features to predict the IMDB rating.<br><br><br>"),
      wellPanel(
          selectInput("selection", "Main character:", choices = c("-ALL-", mainCharacters)),
          sliderInput("episodes", "Episodes:", min=1, max=maxEpisodes, value=c(42,84))
      ),
      wellPanel(
        h4("Word frequency cloud"),
        plotOutput("wordcloud")
      )
    ),
    column(9,
       wellPanel(
         h4("#lines per character & (predicted) ratings for each episode"), 
         ggvisOutput("numlinesplot")
       )
    )
  )
))
