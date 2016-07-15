# devtools::install_github("RMHogervorst/TNG")
library(shiny)
library(ggvis)
library(ggplot2)
library(randomForest)

shinyServer(function(input, output) {

  terms <- reactive({

    #input$update
    #isolate({
      withProgress({
        setProgress(message = "Processing dialogs")
        getTermMatrix(input$selection, input$episodes)
      })
    #})
  })
  
  
  info_tooltip <- function(x) {
    if(is.null(x$mainCharacter)){
      rating_tooltip(x)
    }else{
      character_tooltip(x)
    }
  }
  
  character_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    episode <- resultset[resultset$episodeNum==x$episodeNum & resultset$mainCharacter==x$mainCharacter,]
    episodeName <- episodes[x$episodeNum]
      
    paste0("<b>", x$mainCharacter, "</b><br>",
             "<i>", episodeName, "</i><br>",
             "#lines: ",episode$numLines,"<br>",
             "#sections: ",episode$numSections,"<br>",
             "#words: ",episode$numWords,"<br>",
             "IMDB Rating: ", episode$imdbRating)
    }
  
  rating_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    episode <- ratings[ratings$episodeNum==x$episodeNum,]
    episodeName <- episodes[x$episodeNum]
    
    paste0("<b>", episodeName, "</b><br>",
           "IMDB Rating: ", episode$imdbRating, "<br>",
           "RandomForest Predicted: ", round(episode$predictions,1) )
  }
  
  
  wordcloud_rep <- repeatable(wordcloud)
  
  output$wordcloud <- renderPlot({
    v <- terms()
    wordcloud_rep(names(v), v, scale=c(5,0.8),
                  min.freq = 5, max.words=100,
                  colors=brewer.pal(8, "Dark2"))
  })
  
  linesPlot <- reactive({
      data1 <- select(resultset, numLines, numSections, episodeNum, mainCharacter) %>% 
        filter(episodeNum >= input$episodes[1] & episodeNum <  input$episodes[2] & (mainCharacter==input$selection | input$selection=="-ALL-"))
      
      data2 <-   select(ratings, episodeNum, imdbRating, predictions) %>% 
        filter(episodeNum >= input$episodes[1] & episodeNum <  input$episodes[2])
    
      
      ggvis() %>% 
      layer_points(data=data1, x=~episodeNum, prop("y", ~numLines, scale="ylines"), fill=~mainCharacter, size = ~numSections, size.hover := 200, fillOpacity := 0.4, fillOpacity.hover := 0.5, stroke:="black") %>% 
        layer_points(data=data2, x=~episodeNum, prop("y", ~imdbRating, scale="yrating"), size := 10, size.hover := 20, fillOpacity := 0.4, fillOpacity.hover := 0.7, fill:="orange", stroke:="orange", shape:="triangle-down") %>% 
        layer_points(data=data2, x=~episodeNum,prop("y", ~predictions, scale="yrating"), size := 7, size.hover := 20, fillOpacity := 0.4, fillOpacity.hover := 0.7, fill:="gray", stroke:="gray", shape:="triangle-up") %>% 
        layer_paths(data=data2, x=~episodeNum, prop("y", ~imdbRating, scale="yrating"), stroke:="orange",strokeOpacity:=0.3) %>% 
        layer_paths(data=data2, x=~episodeNum, prop("y", ~predictions, scale="yrating"), stroke:="gray",strokeOpacity:=0.3) %>% 
        add_axis("y", "yrating", orient = "right", grid = FALSE, title="Ratings") %>%
        add_axis("y", "ylines", orient = "left", grid = FALSE, title="#lines") %>%
        add_axis("x",  orient = "bottom", grid = FALSE, title="episode") %>%
        hide_legend("size") %>%
        add_tooltip(info_tooltip, "hover") %>%
        set_options(width ="auto", height = 500, duration=0)
  })
  
  
  linesPlot %>% bind_shiny("numlinesplot")
  
  output$varimpplot <-renderPlot({ varImpPlot(rfMod) },width = "auto", height = 500)
  
 # ratingsPlot <- reactive({
#    select(ratings, episodeNum, imdbRating, predictions) %>% 
#      filter(episodeNum >= input$episodes[1] & episodeNum <  input$episodes[2]) %>%
#      ggvis(x=~episodeNum) %>% 
#      layer_points(y=~imdbRating, size := 100, size.hover := 200, fillOpacity := 0.4, fillOpacity.hover := 0.7, fill:="orange", stroke:="orange", shape:="triangle-down") %>% 
#        layer_points(y=~predictions, size := 75, size.hover := 200, fillOpacity := 0.4, fillOpacity.hover := 0.7, fill:="gray", stroke:="gray", shape:="triangle-up") %>% 
#      add_tooltip(rating_tooltip, "hover") %>%
 #     set_options(width ="auto", height = 400, duration=0)
#  })
  
 # ratingsPlot %>% bind_shiny("ratingsplot")

})
