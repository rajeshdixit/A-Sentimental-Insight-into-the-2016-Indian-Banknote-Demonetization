
#install.packages("twitteR")
#install.packages("RCurl")
#install.packages("base64enc")
#install.packages("devtools")
#install.packages("tm")
#install.packages("googleVis")
#install.packages("streamR")
#install.packages("RJSONIO")
#install.packages("stringr")
#install.packages("ROAuth")
#install.packages("googleVis")
#install.packages("rworldmap")
#install.packages("rworldxtra")
library("plyr")
library("dplyr")
library("stringr")
library("ggplot2")
library("base64enc")
library("httr")
library("devtools")
library("bit64")
library("rjson")
library(twitteR)
library(rworldmap)
library(rworldxtra)
library(streamR)
library(RCurl)
library(RJSONIO)
library(stringr)
library(ROAuth)
library(streamR)

library(googleVis)

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

# my_oauth$handshake(cainfo ="G:/R/2016 Indian banknote demonetization/cacert.pem")


# save(my_oauth, file = "twitter authentication.Rdata")


#setup_twitter_oauth(key, secret, access_token=NULL, access_secret=NULL)

# load("twitter authentication.Rdata")

#Once you launched the code first time, you can start from this line in the future (libraries should be connected)









#setup_twitter_oauth(key, secret, access_token=NULL, access_secret=NULL)


#Once you launched the code first time, you can start from this line in the future (libraries should be connected)

setup_twitter_oauth(consumer_key = consumerKey,
                    consumer_secret = consumerSecret,
                    access_token = accessToken,
                    access_secret = accessTokenSecret)


my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))


save(my_oauth, file = "twitter authentication.Rdata")

load("twitter authentication.Rdata")
# Display Content

?parseTweets


for(x in 1:20)
{
  x = x+1 
  filterStream(file.name = "tweets_demonetization.json", track = c("Demonetization"),language = "en", timeout = 1000, oauth = my_oauth)
  tweets_demonetization.df <- parseTweets("tweets_demonetization.json", simplify = FALSE)
   if(x==16) break; 
}

tweets.df <- parseTweets("tweets_demonetization.json", simplify = FALSE)
combined.df <- rbind(tweets.df, tweets_demonetization.df)

newdf.df <- combined.df[tweets.df$place_lat != "NaN",]
keeps <- c("place_lat", "place_lon")
latlondata.df <- newdf.df[keeps]

#save all of the tweets in a data frame for further processing 
tweets.df[[37]] 
L = tweets.df$place_lat !=0
L
tweets.df[L,]
dim(tweets.df)

subset(tweets.df,COLUMNNAME=="created_at")



newmap <- getMap(resolution = "low")
plot(newmap)
points(latlondata.df$place_lon, latlondata.df$place_lat, col = "#ff6666", cex = 1.3)




#next part : run the code for the sentiment analysis . 
#Then try running it on the induvidual data frames and see what happens 
tweets1.df <- parseTweets("tweets1.json", simplify = TRUE)

tweets.df$created_at <- as.POSIXct(tweets.df$created_at, format="%a, %d %b %Y %H:%M:%S %z") 
df <- df[order(df$date),]
