#Extracting textual part of the tweets

sample=NULL #Initialising
for (tweet in demonetization.tweets)
  sample = c(sample,tweet$getText())
