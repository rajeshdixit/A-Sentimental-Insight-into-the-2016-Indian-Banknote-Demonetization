#connect all libraries
library(twitteR)
library(ROAuth)
library(plyr)
library(dplyr)
library(stringr)
library(ggplot2)
#connect to API
download.file(url='http://curl.haxx.se/ca/cacert.pem', destfile='cacert.pem')
reqURL <- 'https://api.twitter.com/oauth/request_token'
accessURL <- 'https://api.twitter.com/oauth/access_token'
authURL <- 'https://api.twitter.com/oauth/authorize'
consumerKey <- "zTe9jVBVYdi77lxeldLOkBHzz"
#consumer key obtained from the twitter application

consumerSecret <- "VfEgXsRjVJnddsIbscbR9sZDaVGmFWhn8s3NQu3et1y1d9h3eS"
#consumer secret obtained from the twitter application

accessToken <- "145181414-DrFvsFU8mWVLO02O9sK8sqx4O42roxSSmfyF6eUB"
#access token obtained from the twitter application

accessTokenSecret <- "3PvjIiW2ZoGTsaOVH5aCfZXYfAC8gMJeaScRCGFds8grt"
Cred <- OAuthFactory$new(consumerKey=consumerKey,
                         consumerSecret=consumerSecret,
                         requestURL=reqURL,
                         accessURL=accessURL,
                         authURL=authURL)

Cred$handshake(cainfo = system.file('CurlSSL', 'cacert.pem', package = 'RCurl')) #There is URL in Console. You need to go to, get code and enter it in Console

save(Cred, file='twitter authentication.Rdata')
load('twitter authentication.Rdata') #Once you launched the code first time, you can start from this line in the future (libraries should be connected)
setup_twitter_oauth(consumer_key=consumerKey,  consumer_secret=consumerSecret, access_token=accessToken , access_secret=accessTokenSecret)


#the function for extracting and analyzing tweets
search <- function(searchterm)
{
  #extact tweets and create storage file
  list <- searchTwitter(searchterm, n=15, lang="en")
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
  neg <- scan('G:/R/2016 Indian banknote demonetization/negative_words.txt', what='character', comment.char=';') #folder with negative dictionary
  pos.words <- c(pos, 'upgrade')
  neg.words <- c(neg, 'wtf', 'wait', 'waiting', 'epicfail')
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
  ggplot(by.tweet, aes(created, number)) + geom_line(aes(group=tweet, color=tweet), size=2) +
    geom_point(aes(group=tweet, color=tweet), size=4) +
    theme(text = element_text(size=18), axis.text.x = element_text(angle=90, vjust=1)) +
    #stat_summary(fun.y = 'sum', fun.ymin='sum', fun.ymax='sum', colour = 'yellow', size=2, geom = 'line') +
    ggtitle(searchterm)
  ggsave(file=paste(searchterm, '_plot.jpeg'))
}
search("Virat Kohli")
