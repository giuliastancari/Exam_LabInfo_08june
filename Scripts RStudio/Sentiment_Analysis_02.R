#Sentiment Analysis - Part 2

#We want now to analyse basic emotions in tweets

#First of all, we need to install and load the packages for sentiment analysis
install.packages("syuzhet")
library(syuzhet)

install.packages("reshape2")
library(reshape2)

library(tidyverse)

#We firstly load the corpus (created in Part 1)
load("CSV&Files/TwitterforSA.RData")

#Let's now find emotional values for one text
get_nrc_sentiment(my_df$text[1])

#And now, let's add these values to all texts (Need to iterate on all texts to do this)
emotion_values <- data.frame()

for(i in 1:length(my_df$text)){
  
  emotion_values <- rbind(emotion_values, get_nrc_sentiment(my_df$text[i]))
  if(i %% 100 == 0)
    print(i/length(my_df$text))
  
}
#It will take some time

#We then normalize per text length and again iterate on all tweets
my_df$length <- lengths(strsplit(my_df$text, "\\W"))

for(i in 1:length(my_df$text)){
  
  emotion_values[i,] <- emotion_values[i,]/my_df$length[i]
  
}

#Finally we can unite the dataframes
my_df <- cbind(my_df, emotion_values)

my_df$text <- NULL
my_df$length <- NULL

#We can have two wisualization of Sentiment Analysis
#1. The first visualization consists in barplot

#Firstly, we calculate means and secondly we melt dataframe
my_df_mean <- my_df %>%
  group_by(search) %>%
  summarise_all(list(mean = mean))

my_df_mean <- melt(my_df_mean)

#We can now visualize the plot (will appear on the right part of the screen, at the bottom)
p1 <- ggplot(my_df_mean, aes(x=variable, y=value, fill=search))+
  geom_bar(stat="identity", position = "dodge")+
  theme(axis.text.x = element_text(angle = 90, hjust=1))
p1

#We can also save theplot
ggsave(p1, filename = "Figures/Twitter_barplot_01.png", height = 9, width = 16, scale = 0.5)

#2. The second visualization consists in boxplot

#As before, we melt dataframe
my_df <- melt(my_df)

#We directly now make the plot
p2 <- ggplot(my_df, aes(x=variable, y=value, fill=search))+
  geom_boxplot(position = "dodge")+
  theme(axis.text.x = element_text(angle = 90, hjust=1))
p2

#We can also save plot
ggsave(p2, filename = "Figures/Twitter_boxplot_02.png", height = 9, width = 16, scale = 0.5)
