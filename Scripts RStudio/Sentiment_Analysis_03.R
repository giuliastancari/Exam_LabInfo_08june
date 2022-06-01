#We can make further Sentiment Analysises

#We can use the library UDpipe for multi-language NLP

install.packages("udpipe")
library(udpipe)
library(tidyverse)
library(syuzhet)

#We then read the thai twitter file into the dataframe
my_df <- read.csv("CSV&Files/tweets.csv", row.names = 1, stringsAsFactors = F)

#And we select just thai tweets
my_df <- my_df %>% filter(lang == "th")

#We need to convert date of creation into date/time format
my_df$created_at[1]
class(my_df$created_at[1])

#Here, with a standard line code, we create date and hour
my_df$created_at <- strptime(my_df$created_at, "%Y-%m-%dT%H:%M:%S.000Z", tz = "CET")

my_df$created_at[1]
class(my_df$created_at[1])

#We just keep just what is relevant
my_df <- my_df[,c("text", "created_at")]

#And to simplify things, we reduce the dataframe to a random selection of 1000 tweets
my_df <- my_df[sample(1:length(my_df$text), 1000),]
rownames(my_df) <- 1:length(my_df$text)

#The dataset preparation is finally complete now

#We need to find models in the resources folder
list.files(path = "resources/udpipe", pattern = ".udpipe", full.names = T)

#We need to download a udpipe model for thai language
udpipe_download_model(language = "thai", model_dir = "resources/udpipe")

#We load the (thai) model
udmodel <- udpipe_load_model(file = "resources/udpipe/thai-isdt-ud-2.4-190531.udpipe")

#Then, we process the text
text_annotated <- udpipe(object = udmodel, x = my_df$text, doc_id = rownames(my_df), trace = T)

#Finally, now everything is ready to perform (multi-language) SA!

#We need to read OpeNER from resources folder
my_dictionary <- read.csv("resources/sentiment_dictionaries/OpeNER_ita.csv", stringsAsFactors = F)
View(my_dictionary)

#OpeNER includes values per lemma in lowercase, so we need to lowercase the lemmas in our text and perform the analysis on them
text_annotated$lemma_lower <- tolower(text_annotated$lemma)

#To avoid annotating stopwords, we limit the analysis to meaningful content words
POS_sel <- c("NOUN", "VERB", "ADV", "ADJ", "INTJ")
text_annotated$lemma_lower[which(!text_annotated$upos %in% POS_sel)] <- NA

#we use a left_join to add multiple annotations at once
text_annotated <- left_join(text_annotated, my_dictionary, by = c("lemma_lower" = "word")) 

#Now that the sentiment annotation is done, let's keep just the useful info 
text_annotated <- text_annotated[c(1,19:length(text_annotated))]
text_annotated$doc_id <- as.numeric(text_annotated$doc_id)

#We replace NAs with zeros
text_annotated <- mutate(text_annotated, across(everything(), ~replace_na(.x, 0)))
View(text_annotated)

#We then get overall values per tweet
sentences_annotated <- text_annotated %>%
  group_by(doc_id) %>%
  summarise_all(list(valence = mean))

#Let's order the tweet by number
sentences_annotated <- sentences_annotated[order(as.numeric(sentences_annotated$doc_id)),]

#Now we can join the annotations to the original dataframe 
my_df <- cbind(my_df, sentences_annotated[,2:length(sentences_annotated)])
View(my_df)

#Then we can re-order the dataframe based on the tweets creation dates
my_df <- my_df[order(my_df$created_at),]

#We put them in a graph
plot(
  my_df$valence, 
  type="l", 
  main="Vaccine on Italian Twitter", 
  xlab = "Time", 
  ylab= "Emotional Valence"
)

#Then, let's use the "rolling plot" function from syuzhet

rolling_plot <- function (raw_values, window = 0.1){
  wdw <- round(length(raw_values) * window)
  rolled <- rescale(zoo::rollmean(raw_values, k = wdw, fill = 0))
  half <- round(wdw/2)
  rolled[1:half] <- NA
  end <- length(rolled) - half
  rolled[end:length(rolled)] <- NA
  return(rolled)
}

my_df$valence <- rolling_plot(my_df$valence)

#Line chart
my_df$created_at <- as.POSIXct(my_df$created_at)
p1 <- ggplot(my_df, aes(x=created_at, y=valence)) + 
  geom_line()

p1

ggsave(p1, filename = "Figures/Twitter_rollingplot_03.png", width = 16, height = 9, scale = 0.5)
