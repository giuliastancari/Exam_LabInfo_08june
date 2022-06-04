#Networks

#Here, we want to make some analysises on the tweets, in order to create networks through Gephi
#The nodes are the tweets or the users
#The edges are respectively the retweets or the tweets 

library(tidyverse)

#We read tweets on the file 
my_df <- read.csv("CSV&Files/tweets.csv", stringsAsFactors = F)

#How many tweets were retweets?
#On the total, the result is the number of retweets
length(which(!is.na(my_df$referenced_tweets.retweeted.id)))

#How many tweets were retweets (of tweets present in our selection)?
#Some retweets are from tweets that are not present in the gropus I downloaded
length(which(my_df$referenced_tweets.retweeted.id %in% my_df$id))

#We reduce just to tweets that are retweets/retweeted inside of my dataset (they all have a relationship between them)
my_df <- my_df %>% filter(referenced_tweets.retweeted.id %in% id |
                            id %in% referenced_tweets.retweeted.id)

#Let's get how many times tweets were retweeted
retweets <- my_df %>% group_by(referenced_tweets.retweeted.id) %>% count()

#Let's see how many tweets were retweeted more than 500 times
length(which(retweets$n > 500))

#We have now concluded the filtering of tweets

#1. Build nodes table

#After having filtered, we create the tables with nodes and edges though dataframes

tweets_df <- data.frame(Id = my_df$id, Label = "", group = "Tweets")
users_df <- data.frame(Id = unique(my_df$author_id), Label = unique(my_df$author.username), group = "Users") 

#We make one unique dataframe
nodes_df <- rbind(tweets_df, users_df)

#2. Build edges table

authoring_df <- data.frame(Source = my_df$author_id, Target = my_df$id, Weight = 1, Type = "directed")

retweeting_df <- data.frame(Source = my_df$id, Target = my_df$referenced_tweets.retweeted, Weight = 1, Type = "directed")

#3. Remove NAs (i.e. the tweets that are not retweets)

which(is.na(retweeting_df$Target))

retweeting_df <- retweeting_df[-which(is.na(retweeting_df$Target)),]

edges_df <- rbind(authoring_df, retweeting_df)

#4.Write all in CSV files
write.csv(nodes_df, file = "CSV&Files/GephiTweetNodes.csv", row.names = F)
write.csv(edges_df, file = "CSV&Files/GephiTweetEdges.csv", row.names = F)
