# 2016 Indian banknote demonetization: A statistical and sentimental insight using R

# the medium used is twitter
# there is a limit of 15 scrapes per 15 minutes from twitter Dev account

#load all the necessary packages/libraries

library("twitteR")
library("ROAuth")
library("RCurl")
library("plyr")
library("dplyr")
library("stringr")
library("ggplot2")
library("base64enc")
library("httr")
library("devtools")
library("bit64")
library("rjson")
library("corrgram")

# info obtained from twitter dev account

consumerKey <- "zTe9jVBVYdi77lxeldLOkBHzz"
#consumer key obtained from the twitter application

consumerSecret <- "VfEgXsRjVJnddsIbscbR9sZDaVGmFWhn8s3NQu3et1y1d9h3eS"
#consumer secret obtained from the twitter application

accessToken <- "145181414-DrFvsFU8mWVLO02O9sK8sqx4O42roxSSmfyF6eUB"
#access token obtained from the twitter application

accessTokenSecret <- "3PvjIiW2ZoGTsaOVH5aCfZXYfAC8gMJeaScRCGFds8grt"
#access token secret obtained from the twitter application

#check working directory

getwd()


# setting windows certificates

# cacert.pem is the collection of certificates

download.file(url = "https://curl.haxx.se/ca/cacert.pem",
              destfile = "G:/R/2016 Indian banknote demonetization/cacert.pem",
              method = "auto")

download.file(url = "http://curl.haxx.se/libcurl/", destfile = "G:/R/2016 Indian banknote demonetization/libcurl.pem", method = "auto")

# download.file() is used to download content from the web
# url is the source
# destfile is destination where the file is to be downloaded to

# Twitter Authentication process

reqURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"

my_oauth <- OAuthFactory$new(consumerKey = consumerKey,
                                   consumerSecret = consumerSecret,
                                   requestURL = reqURL,
                                   accessURL = accessURL,
                                   authURL = authURL)


# the new step will launch twitter from Rstudio

my_oauth$handshake(cainfo ="G:/R/2016 Indian banknote demonetization/cacert.pem")






save(my_oauth, file = "twitter authentication.Rdata")


#setup_twitter_oauth(key, secret, access_token=NULL, access_secret=NULL)

load("twitter authentication.Rdata")

#Once you launched the code first time, you can start from this line in the future (libraries should be connected)

setup_twitter_oauth(consumer_key = consumerKey,
                    consumer_secret = consumerSecret,
                    access_token = accessToken,
                    access_secret = accessTokenSecret)


search <- function(searchterm)
  
{
  #extact tweets and create storage file
  
  list <- searchTwitter(searchterm, n=1000, lang = "en")
  
  df <- twListToDF(list)
  
  df <- df[, order(names(df))]
  
  df$created <- strftime(df$created, '%Y-%m-%d')
  
  if (file.exists(paste(searchterm, '_stack.csv'))==FALSE) write.csv(df, file=paste(searchterm, '_stack.csv'), row.names=F)
  
  #merge the last extraction with storage file and remove duplicates
  
  stack <- read.csv(file=paste(searchterm, '_stack.csv'))
  
  stack <- rbind(stack, df)
  
  stack <- subset(stack, !duplicated(stack$text))
  
  write.csv(stack, file=paste(searchterm, '_stack.csv'), row.names=F)
  
  #tweets evaluation function
  
  score.sentiment <- function(sentences, pos.words, neg.words, .progress='none')
    
  {
    
    require(plyr)
    
    require(stringr)
    
    scores <- laply(sentences, function(sentence, pos.words, neg.words){
      
      sentence <- iconv(sentence, 'UTF-8', 'ASCII')
      
      sentence <- gsub('[[:punct:]]', "", sentence)
      
      sentence <- gsub('[[:cntrl:]]', "", sentence)
      
      
      sentence <- gsub('\\d+', "", sentence)
      
      sentence <- tolower(sentence)
      
      word.list <- str_split(sentence, '\\s+')
      
      words <- unlist(word.list)
      
      pos.matches <- match(words, pos.words)
      
      neg.matches <- match(words, neg.words)
      
      pos.matches <- !is.na(pos.matches)
      
      neg.matches <- !is.na(neg.matches)
      
      score <- sum(pos.matches) - sum(neg.matches)
      
      return(score)
      
    }, pos.words, neg.words, .progress=.progress)
    
    scores.df <- data.frame(score=scores, text=sentences)
    
    return(scores.df)
  }
  
  pos <- scan('G:/R/2016 Indian banknote demonetization/positive_words.txt', what='character', comment.char=';') #folder with positive dictionary
  
  neg <- scan('G:/R/2016 Indian banknote demonetization/positive_words.txt', what='character', comment.char=';') #folder with negative dictionary
  
  pos.words <- pos
  
  neg.words <- neg
  
  Dataset <- stack
  
  Dataset$text <- as.factor(Dataset$text)
  
  scores <- score.sentiment(Dataset$text, pos.words, neg.words, .progress='text')
  
  write.csv(scores, file=paste(searchterm, '_scores.csv'), row.names=TRUE) #save evaluation results
  
  #total score calculation: positive / negative / neutral
  
  stat <- scores
  
  stat$created <- stack$created
  
  stat$created <- as.Date(stat$created)
  
  stat <- mutate(stat, tweet=ifelse(stat$score > 0, 'positive', ifelse(stat$score < 0, 'negative', 'neutral')))
  
  by.tweet <- group_by(stat, tweet, created)
  
  by.tweet <- summarise(by.tweet, number=n())
  
  write.csv(by.tweet, file=paste(searchterm, '_opin.csv'), row.names=TRUE)
  
  #chart
  
  # ggplot(by.tweet, aes(created, number)) + geom_line(aes(group=tweet, color=tweet), size=2) +
  
  # geom_point(aes(group=tweet, color=tweet), size=4) +
  
  # theme(text = element_text(size=18), axis.text.x = element_text(angle=90, vjust=1)) +
  
  #stat_summary(fun.y = 'sum', fun.ymin='sum', fun.ymax='sum', colour = 'yellow', size=2, geom = 'line') +
  
  # ggtitle(searchterm)
  
  # ggsave(file=paste(searchterm, '_plot.jpeg'))
  
  ggplot(by.tweet, aes(created, number)) + geom_point() + scale_x_continuous("Created", breaks = seq(0,0.35,0.05))+ 
    scale_y_continuous("Number", breaks = seq(0,270,by = 30))+ theme_bw()
  
  ggtitle(searchterm)
  
  ggsave(file=paste(searchterm, '_plot1.jpeg'))
  
  ggplot(by.tweet, aes(created, number)) + geom_point(aes(color = Item_Type)) + 
    scale_x_continuous("Created", breaks = seq(0,0.35,0.05))+
    scale_y_continuous("Number", breaks = seq(0,270,by = 30))+
    theme_bw() + labs(title="Scatterplot")
  
  ggtitle(searchterm)
  
  ggsave(file=paste(searchterm, '_plot2.jpeg'))
  
  
  
  ggplot(by.tweet, aes(number)) + geom_histogram(binwidth = 2)+
    scale_x_continuous("Number", breaks = seq(0,270,by = 30))+
    scale_y_continuous("Count", breaks = seq(0,200,by = 20))+
    labs(title = "Histogram")
  
  ggtitle(searchterm)
  
  ggsave(file=paste(searchterm, '_plot3.jpeg'))
  
  
  
  
  corrgram(by.tweet, order=NULL, panel=panel.shade, text.panel=panel.txt,
           main="Correlogram")
}
search("Demonetization")


#library("wordcloud")
#?wordcloud

#wordcloud(search, min.freq = 4, scale = c(1,5), random.color = F, max.words = 45, random.order = F)


