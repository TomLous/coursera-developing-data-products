---
title       : Start Trek TNG
subtitle    : General Analysis of Dialogs & influence in rating
author      : Tom Lous  
job         : 
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : [mathjax]            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
---



## Star Trek the Next Generation

* Off the air for > 20 years
* Continues to have huge impact on our culture & technology
* Many (main) characters that influenced the series

![](http://vignette2.wikia.nocookie.net/memoryalpha/images/0/0e/The_Next_Generation_Main_Cast_Season_1.jpg/revision/latest?cb=20091202034552&path-prefix=en)


--- .class #id 

## Show statistics




The show had 175 episodes, 1861 different characters and a total of 68487 script dialogs.
These I consider the main characters that have a calculatable impact on the show ratings


```
##  [1] "PICARD"  "RIKER"   "GEORDI"  "WORF"    "TROI"    "DATA"    "BEVERLY"
##  [8] "WESLEY"  "TASHA"   "Q"
```

They account for  46815 script dialogs, which is 68% of all dialogs.

The show ratings have a fairly high average

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
##   3.400   6.600   7.400   7.332   8.000   9.300       2
```

--- .class #id 

## Exploration



To analyze who's lines, words or sections (of dialog) have the most impact on predicting the imdbRating, a dataset was created that combined all maincharacters and their lines, words ans sections as features for the imdbRating.
Resulting in a matrix of 

```
## [1] 174  32
```

After training 1500 Random Forests. The predictor on the dataset endend up with $R^2$ of 0.148 and a MSE of 0.717
Which seems not great, but it probably overfitted the data, so it did a pretty good job predicting the actual ratings

These were the top 5 most important variables for predicting the imdbRating


```
## [1] "TROI.numWords"     "TROI.numSections"  "TROI.numLines"    
## [4] "TASHA.numSections" "DATA.numSections"
```

--- .class #id 

## Conclusion

Based on these conclusions it's hard to say which character has a positive or negative impact on the ratings. First of all a dataset with 175 samples is hard to train on. 
Other factors were also excluded, like the category of episode (Disaster/Monster of the week, Humanist message, Political Message, Character piece, etc, etc.) or other cateories  like (time travel, Borg, Klingon, Holodeck, etc)

But that should't deter you to play around with the data [https://tomlous.shinyapps.io/TNG_Analysis/](https://tomlous.shinyapps.io/TNG_Analysis/)

Live long and prosper!
