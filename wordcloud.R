#creating a wordcloud


#install.packages("tm")
#install.packages("stringi")
library(stringi)
library(twitteR)
library(tm)
library(wordcloud)
library(RColorBrewer)
require(twitteR)
library(twitteR)
library(tm)
library(wordcloud)
library(RColorBrewer)
#install.packages("rworldmap")
library(rworldmap)
#install.packages("rworldxtra")
library(rworldxtra)
library(streamR)
library(RCurl)
library(RJSONIO)
library(stringr)
library(ROAuth)
library(streamR)
library(googleVis)

#connect to API
download.file(url = "https://curl.haxx.se/ca/cacert.pem",
              destfile = "G:/R/2016 Indian banknote demonetization/cacert.pem",
              method = "auto")

download.file(url = "http://curl.haxx.se/libcurl/",
              destfile = "G:/R/2016 Indian banknote demonetization/libcurl.pem",
              method = "auto")

reqURL <- 'https://api.twitter.com/oauth/request_token'
accessURL <- 'https://api.twitter.com/oauth/access_token'
authURL <- 'https://api.twitter.com/oauth/authorize'
# info obtained from twitter dev account

consumerKey <- "zTe9jVBVYdi77lxeldLOkBHzz"
#consumer key obtained from the twitter application

consumerSecret <- "VfEgXsRjVJnddsIbscbR9sZDaVGmFWhn8s3NQu3et1y1d9h3eS"
#consumer secret obtained from the twitter application

accessToken <- "145181414-DrFvsFU8mWVLO02O9sK8sqx4O42roxSSmfyF6eUB"
#access token obtained from the twitter application

accessTokenSecret <- "3PvjIiW2ZoGTsaOVH5aCfZXYfAC8gMJeaScRCGFds8grt"
#access token secret obtained from the twitter application 
setup_twitter_oauth(consumer_key = consumerKey,
                    consumer_secret = consumerSecret,
                    access_token = accessToken,
                    access_secret = accessTokenSecret)




mach_tweets = searchTwitter("Demonetization", n=1500, lang="en")

mach_text = sapply(mach_tweets, function(x) x$getText())

mach_text = iconv(mach_text, 'UTF-8', 'ASCII')


# create a corpus
mach_corpus = Corpus(VectorSource(mach_text))

# create document term matrix applying some transformations
tdm = TermDocumentMatrix(mach_corpus,
                         control = list(removePunctuation = TRUE,
                                        stopwords = c("Demonetisation","#DeMo","demo","Demonitization","Demonotization","https","youtube", stopwords("english")),
                                        removeNumbers = TRUE, tolower = TRUE))

# define tdm as matrix
m = as.matrix(tdm)
# get word counts in decreasing order
word_freqs = sort(rowSums(m), decreasing=TRUE) 
# create a data frame with words and their frequencies
dm = data.frame(word=names(word_freqs), freq=word_freqs)

# plot wordcloud
wordcloud(dm$word, dm$freq, random.order=FALSE, colors=brewer.pal(8, "Dark2"))
# save the image in png format
png("2016_Indian_Banknote_demonetization.png", width=12, height=8, units="in", res=300)

wordcloud(dm$word, dm$freq, random.order=FALSE, colors=brewer.pal(8, "Dark2"))
dev.off()


# d <- density(combined.df$retweet_count,combined.df$favourites_count) # returns the density data 
# plot(d) # plots the results

#install.packages("aplpack")
library(aplpack)
attach(combined.df)
bagplot(combined.df$retweet_count,combined.df$favourites_count, xlab="rt", ylab="fav",
        main="Bagplot, used to visualize the location, spread, skewness, and outliers of the data set")
