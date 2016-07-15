load("TNGsummarized.Rda") 
library(tm)
library(wordcloud)
library(memoise)
library(dplyr)
library(magrittr)
library(ggvis)
library(randomForest)


getTermMatrix <- memoise(function(i_character, i_episodes) {
  # Careful not to let just any name slip in here; a
  # malicious user could manipulate this value.
  if (!(i_character %in% mainCharacters) && i_character!='-ALL-')
    stop("Unknown character")
  
  data <- select(resultset, allText, episodeNum, mainCharacter) %>% filter(episodeNum >= i_episodes[1] & episodeNum <  i_episodes[2] & (mainCharacter==i_character | i_character=="-ALL-")) %>%  summarise(text=paste(allText, collapse="@ "))
  text <- data$text[[1]]
  
  
  
  myCorpus = Corpus(VectorSource(text))
  myCorpus = tm_map(myCorpus, content_transformer(tolower))
  myCorpus = tm_map(myCorpus, removePunctuation)
  myCorpus = tm_map(myCorpus, removeNumbers)
  myCorpus = tm_map(myCorpus, removeWords,
                    c(stopwords("SMART"), "ill", "ive", "im", "youll","youve","youre","hell","hes","shell","shes", "well", "weve", "were","theyll", "theyve", "theyre", "and", "but","wont","dont","isnt"))
  
  myDTM = TermDocumentMatrix(myCorpus,
                             control = list(minWordLength = 1))
  
  m = as.matrix(myDTM)
  
  sort(rowSums(m), decreasing = TRUE)
})