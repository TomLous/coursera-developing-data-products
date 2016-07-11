library(TNG)
library(R.utils)
library(dplyr)
library(magrittr)
library(gtools)
library(stringr)
library(reshape2)


#save(TNG, file="TNG.Rda")
speechOnly <- TNG %>% 
  filter(type == "speech" & !invalid(who))

# Define the main characters of TNG (very subjective I know)
#PICARD|RIKER|GEORDI|FORGE|WORF|TROI|DATA|WESLEY|BEVERLY|CRUSHER|GUINAN|TASHA|YAR|LORE|LWAXANA|Q|ALEXANDER|KEIKO|MILES|BARCLAY|BORG
mainCharacters <- c("PICARD", "RIKER", "GEORDI", "WORF", "TROI", "DATA", "BEVERLY", "WESLEY", "GUINAN", "TASHA", "LORE", "LWAXANA", "MRS. TROI", "\"Q\"", "Q", "ALEXANDER", "KEIKO", "O'BRIEN", "BARCLAY", "BORG")

# Could this be better?: probably
speechOnly["mainchar"] <-  sapply(speechOnly$who, function(x) mainCharacters[startsWith(toupper(trimws(x)), mainCharacters)][1])
speechOnly$mainchar[speechOnly$mainchar == "\"Q\""] <- "Q"
speechOnly$mainchar[speechOnly$mainchar == "MRS. TROI"] <- "LWAXANA"
speechOnly$mainchar[is.na(speechOnly$mainchar)] <- "-OTHER-"
speechOnly["mainchar"] <- factor(speechOnly[["mainchar"]])
speechOnly["episode"] <- factor(speechOnly[["episode"]])


intermediateResult <- select(speechOnly, episode, mainchar,text,Season,Episode,imdbRating,text) %>% 
  group_by(episode, mainchar,Season,Episode) %>% 
  summarise(numSections=n(),imdbRating=max(imdbRating),allText=paste(trimws(tolower(text)), collapse=". ")) %>% 
  arrange(Season, Episode)

intermediateResult$allText = trimws(gsub("[0-9]+(\\.[0-9]+)?","-",intermediateResult$allText))
intermediateResult$allText = trimws(gsub("[\\.!\\?\"]+","@",intermediateResult$allText))
intermediateResult$allText = trimws(gsub("[ \t\n\r]+"," ",intermediateResult$allText))
intermediateResult$allText = trimws(gsub("@[ ] *@","@",intermediateResult$allText))

intermediateResult$numLines = str_count(intermediateResult$allText, "@")
intermediateResult$numWords = str_count(intermediateResult$allText, " ")




numLinesData <- dcast(intermediateResult, episode + imdbRating ~ mainchar, value.var="numLines", fill=0)
numWordsData <- dcast(intermediateResult, episode + imdbRating ~ mainchar, value.var="numWords", fill=0)
numSectionsData <- dcast(intermediateResult, episode + imdbRating ~ mainchar, value.var="numSections", fill=0)


save(intermediateResult,numLinesData,numWordsData,numSectionsData, file="TNGsummarized.Rda")
