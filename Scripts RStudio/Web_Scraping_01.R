#Web Scraping + Upload File CSV

#First of all, we need to download the library tydyverse and call it
install.packages("tidyverse")
library(tidyverse)

#Read the csv into a dataframe and explore it
my_df <- read.csv("CSV/tweets.csv", stringsAsFactors = F)
View(my_df)


#We can see all available metadata and do a series of analysis on them
colnames(my_df)

#1.Count tweets per language
my_df %>% count(lang)

#2.Filter by language
eng_df <- my_df %>% filter(lang == "en")

#3.Count tweets per username
my_df %>% count(author.username, sort = T)

#4.Filter by username
user_df <- my_df %>% filter(author.username == "lens3yed")

#5.Count tweets per date of creation
my_df %>% count(created_at)

#6.Filter by date of creation
date_df <- my_df %>% filter(created_at == "2022-05-31T17:40:05.000Z")
date2_df <- my_df %>% filter(created_at == "2022-05-31T17:39:17.000Z")
