demonetization.tweets = searchTwitter("demonetization",
                                       lang="en",
                                       n=100000,
                                       geocode='21.146633,79.088860,1118mi',
                                       resultType = "mixed")
demonetization_text = sapply(demonetization.tweets, function(x) x$getText())
df <- do.call("rbind", lapply(demonetization.tweets, as.data.frame))
demonetization_text <- sapply(df$text,function(row) iconv(row, "latin1", "ASCII", sub=""))
str(demonetization_text)

#corpus is a collection of text documents
library(tm)
demo_corpus <- Corpus(VectorSource(demonetization_text))
demo_corpus
inspect(demo_corpus[1])
#clean text
demo_clean <- tm_map(demo_corpus, removePunctuation)
demo_clean <- tm_map(demo_clean, content_transformation)
demo_clean <- tm_map(demo_clean, content_transformer(tolower))
demo_clean <- tm_map(demo_clean, removeWords, stopwords("english"))
demo_clean <- tm_map(demo_clean, removeNumbers)
demo_clean <- tm_map(demo_clean, stripWhitespace)
demo_clean <- tm_map(demo_clean, removeWords, c("demonetisation","demo","DeMo","https","youtube"))#removing search words
#wordcloud
#wordcloud(demo_clean)
#wordcloud(demo_clean, random.order=F)
#wordcloud(demo_clean, random.order=F, scale=c(4,0.5))#max font size,min font size
#wordcloud(demo_clean, random.order=F,col=rainbow(50), scale=c(4,0.5))
wordcloud(demo_clean, random.order=F,max.words=80, col=rainbow(50), scale=c(4,0.5))
