# Web Scraping

# First of all, we need to install "rvest" and after call the library
install.packages("rvest") 
library(rvest)

# define the link (here we take "War and Peace" in Goodreads)
my_link <- "https://www.goodreads.com/book/show/656.War_and_Peace"

# read the html to an R variable
doc <- read_html(my_link)

# then find the element in the HTML that identifies the reviews
doc %>% html_nodes(xpath = "//div[@class='friendReviews elementListBrown']")
# tip: you can use F12 in your browser to see the structure of the page
# you need to use Xpath expressions to find the relevant nodes
# info: https://www.w3schools.com/xml/xpath_syntax.asp

# once verified that it works, you can save it to a variable
full_reviews <- doc %>% html_nodes(xpath = "//div[@class='friendReviews elementListBrown']")

# ...and iterate on it to extract (for example) just the text of the reviews
my_reviews <- character()

for(i in 1:length(full_reviews)){
  
  my_reviews[i] <- full_reviews[[i]] %>% html_node(css = "[class='reviewText stacked']") %>% html_text()
  # note: to iterate inside of HTML nodes, we need to use a different syntax, CSS selector
  # info: https://www.w3schools.com/cssref/css_selectors.asp
  
}

# then we can explore the result!
my_reviews[1] # first review
my_reviews[7] # seventh review
# etc...
############################

library(tidyverse)

# read the csv into a dataframe
my_df <- read.csv("corpora/harrypotter_tweets.csv", stringsAsFactors = F)

# explore the dataframe
View(my_df)

# see all available metadata
colnames(my_df)

# count tweets per language
my_df %>% count(lang)

# filter by language
ita_df <- my_df %>% filter(lang == "it")

# count tweets per username
my_df %>% count(author.username, sort = T)

# filter by username
user_df <- my_df %>% filter(author.username == "HarryPotterEnth")

# etc. etc.
