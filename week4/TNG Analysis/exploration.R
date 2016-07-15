library(TNG)
library(R.utils)
library(dtplyr)
library(dplyr)
library(magrittr)
library(gtools)
library(stringr)
library(reshape2)
library(data.table)
library(ggvis)
library(randomForest)
#save(TNG, file="TNG.Rda")

# only get speech, not descriptions
speechOnly <- TNG %>% 
  filter(type == "speech" & !invalid(who))

# Define the main characters of TNG (very subjective I know)
    #PICARD|RIKER|GEORDI|FORGE|WORF|TROI|DATA|WESLEY|BEVERLY|CRUSHER|GUINAN|TASHA|YAR|LORE|LWAXANA|Q|ALEXANDER|KEIKO|MILES|BARCLAY|BORG
    #mainCharacters <- c("PICARD", "RIKER", "GEORDI", "WORF", "TROI", "DATA", "BEVERLY", "WESLEY", "GUINAN", "TASHA", "LORE", "LWAXANA", "MRS. TROI", "\"Q\"", "Q", "ALEXANDER", "KEIKO", "O'BRIEN", "BARCLAY", "BORG")
mainCharacters <- c("PICARD", "RIKER", "GEORDI", "WORF", "TROI", "DATA", "BEVERLY", "WESLEY", "TASHA",  "Q")

# Could this be better?: probably

speechOnly["mainCharacter"] <- sapply(speechOnly$who, function(x) mainCharacters[startsWith(toupper(trimws(x)), mainCharacters)][1])
speechOnly$mainCharacter[speechOnly$mainCharacter == "\"Q\""] <- "Q"
  #speechOnly$mainCharacter[speechOnly$mainCharacter == "MRS. TROI"] <- "LWAXANA"
  #speechOnly$mainCharacter[speechOnly$mainCharacter == "O'BRIEN"] <- "OBRIEN"
  #speechOnly$mainCharacter[is.na(speechOnly$mainCharacter)] <- "OTHER"
speechOnly["mainCharacter"] <- factor(speechOnly[["mainCharacter"]])
speechOnly["episode"] <- factor(speechOnly[["episode"]])
speechOnly["episodeCode"] <- sprintf("S%02dE%02d", speechOnly[["Season"]],speechOnly[["Episode"]])

episodes <- unique(speechOnly$episode)
#data.frame(
#names(episodes) = c('episode')

speechOnly$episodeNum <- match(speechOnly$episode, episodes)


resultset <- select(speechOnly, episodeNum, mainCharacter,text,Season,Episode,imdbRating,text) %>% 
  filter(!is.na(mainCharacter)) %>%
  group_by(episodeNum, mainCharacter,Season,Episode) %>% 
  summarise(numSections=n(),imdbRating=max(imdbRating),allText=paste(trimws(tolower(text)), collapse=". ")) %>% 
  arrange(Season, Episode)

resultset$allText = trimws(gsub("[0-9]+(\\.[0-9]+)?","-",resultset$allText))
resultset$allText = trimws(gsub("[\\.!\\?\"]+","@",resultset$allText))
resultset$allText = trimws(gsub("[ \t\n\r]+"," ",resultset$allText))
resultset$allText = trimws(gsub("@[ ] *@","@",resultset$allText))

resultset$numLines = str_count(resultset$allText, "@")
resultset$numWords = str_count(resultset$allText, " ")


numLinesData <- dcast(resultset, episodeNum + imdbRating ~ mainCharacter, value.var="numLines", fill=0)
numWordsData <- dcast(resultset, episodeNum + imdbRating ~ mainCharacter, value.var="numWords", fill=0)
numSectionsData <- dcast(resultset, episodeNum + imdbRating ~ mainCharacter, value.var="numSections", fill=0)
numData <- dcast(setDT(resultset), episodeNum + imdbRating ~ mainCharacter, value.var=c("numLines","numWords","numSections"), fill=0)

names_1 <- str_split_fixed(names(numData)[-(1:2)],"_",2)
names_2 <- paste(names_1[,2],names_1[,1],sep=".")
names(numData)[-(1:2)] <- names_2

fitLinesData <- lm(imdbRating ~ . - 1, data=data.frame(numLinesData)[,-1])
fitWordsData <- lm(imdbRating ~ . - 1, data=data.frame(numWordsData)[,-1])
fitSectionsData <- lm(imdbRating ~ . - 1, data=data.frame(numSectionsData)[,-1])
fitData <- lm(imdbRating ~ . - 1, data=data.frame(numData)[,-1])


ratingsLines <- predict(fitLinesData,numLinesData[,-1:-2])
ratingsWords <- predict(fitWordsData,numWordsData[,-1:-2])
ratingsSections <- predict(fitSectionsData,numSectionsData[,-1:-2])
ratingsAll <- predict(fitData,data.frame(numData)[,-1:-2])

trainingData <- data.frame(numData)[!is.na(numData$imdbRating), -1]

rfMod <- randomForest(
  x=trainingData[,-1], 
  y=trainingData$imdbRating,
  ntree=150,
  keep.forest=TRUE,
  proximity=TRUE) #do.trace=TRUE


predictions <- predict(rfMod, data.frame(numData)[,-1:-2], optional=TRUE)
ratings <- cbind(data.frame(numData)[,1:2],predictions)

maxEpisodes <- length(episodes)



save(mainCharacters,resultset,numData,ratings,episodes,maxEpisodes, file="TNGsummarized.Rda")





