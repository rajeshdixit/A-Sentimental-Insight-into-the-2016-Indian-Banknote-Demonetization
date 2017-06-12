library(ROAuth)
library(twitteR)

consumer_key <- "##########"
#consumer key obtained from the twitter application

consumer_secret <- "##########"
#consumer secret obtained from the twitter application

access_token <- "##########"
#access token obtained from the twitter application

access_token_secret <- "##########"
#access token secret obtained from the twitter application

setup_twitter_oauth(consumer_key ,consumer_secret, access_token,  access_token_secret )

download.file(url = "https://curl.haxx.se/ca/cacert.pem",
              destfile = "G:/R/2016 Indian Banknote Demonetization/cacert.pem",
              method = "auto")

download.file(url = "http://curl.haxx.se/libcurl/", 
              destfile = "G:/R/2016 Indian Banknote Demonetization/libcurl.pem",
              method = "auto")

# download.file() is used to download content from the web
# url is the source
# destfile is destination where the file is to be downloaded to

# Twitter Authentication process

reqURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"

my_oauth <- OAuthFactory$new(consumerKey = consumer_key,
                             consumerSecret = consumer_secret,
                             requestURL = reqURL,
                             accessURL = accessURL,
                             authURL = authURL)


# the new step will launch twitter from Rstudio

my_oauth$handshake(cainfo ="G:/R/2016 Indian Banknote Demonetization/cacert.pem")





save(my_oauth, file = "twitter authentication.Rdata")


#setup_twitter_oauth(key, secret, access_token=NULL, access_secret=NULL)

load("twitter authentication.Rdata")

#Once you launched the code first time, you can start from this line in the future (libraries should be connected)


#After this you will be redirected to a URL where you click on authorize app and get the passkey to be entered in RStudio
