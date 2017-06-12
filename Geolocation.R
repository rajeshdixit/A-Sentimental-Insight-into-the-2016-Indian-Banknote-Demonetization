
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
library(rworldmap)
library(rworldxtra)
library(streamR)
library(RCurl)
library(RJSONIO)
library(stringr)
library(ROAuth)
library(streamR)
library(googleVis)
?parseTweets

tweets_demonetization.df <- parseTweets("tweets_demonetization.json", simplify = FALSE)
tweets.df <- parseTweets("tweets_demonetization.json", simplify = FALSE)
combined.df <- rbind(tweets.df, tweets_demonetization.df)

newdf.df <- combined.df[tweets.df$place_lat != "NaN",]
keeps <- c("place_lat", "place_lon")
latlondata.df <- newdf.df[keeps]

newmap <- getMap(resolution = "low")
plot(newmap)
points(latlondata.df$place_lon, latlondata.df$place_lat, col = "#ff6666", cex = 1.3)

