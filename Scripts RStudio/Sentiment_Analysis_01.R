#We will makes few procedure to prepare the tweets for the Sentiment Analysis

#First of all, we install and load packages for language recognition
install.packages("cld2")
library(cld2)
library(tidyverse)

#Now we find the file address
all_twitter_files <- list.files(path = "CSV&Files", pattern = "tweets.", full.names = T)

#We read the file to prepare the dataframe
my_df <- read.csv(all_twitter_files)

#We filter the datas and keep just text and lang
my_df <- my_df[,c("text", "lang")]
my_df$search <- gsub(pattern = "CSV&Files/tweets", replacement = "", all_twitter_files)

#We need to exclude the "NA" tweets (probably due to errors in the scraping)
my_df <- my_df[!is.na(my_df$text),]

#We filter and reduce the languages to just engl
my_df %>% count(lang)
my_df <- my_df %>% filter(lang == "en")

#We can now remove the info on language, because it's useless
my_df$lang <- NULL

#Finally we can save the dataframe in a file
save(my_df, file = "CSV&Files/TwitterforSA.RData")
