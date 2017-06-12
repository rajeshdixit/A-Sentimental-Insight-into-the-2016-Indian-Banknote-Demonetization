library("twitteR")
library("ROAuth")
library("RCurl")
library("httr")
library("base64enc")

key <- "OtyWagU0wvVbvtolqiBlNB8IR"
secret <- "LARiMxvWddTJOekSsjtB2W2SshdCEaN2QCXFeGCQTcVtpe2VbG"
token <- "145181414-W85w2l9KR75O5VMoci4IqVbndwSk60It58HUzzCC"
token_secret <- "gPcdT5hFgrQAA9LI1EgH5l3u8jJ2g7gu2F1ct4T8Fkoc0"

?setup_twitter_oauth

setup_twitter_oauth(key, secret, token, token_secret)

mytweets = searchTwitter("#GITAM",n=1000)

