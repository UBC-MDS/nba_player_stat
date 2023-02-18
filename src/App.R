# NBA Stats App

# Load necessary libraries for the app
library(shiny)
library(ggplot2)
library(plyr)
library(tidyverse)
library(rvest)
library(ggrepel)
library(readr)
library(RCurl)
library(jpeg)

# Read the dataset from the specified location in the application file directory
#dataset <-
  #read.csv("../data/preload_data_player_name.csv")

# Using real time api to load nba player stats data

# Add player name and player slug
player <- "Jason Kidd"
player_name_split <- tolower(strsplit(player, " ")[[1]])
slug_ln <- substr(player_name_split[2], start = 1, stop = 5)
slug_fn <- substr(player_name_split[1], start = 1, stop = 2)
slug <- paste0(slug_ln, slug_fn, '01')#"bryanko01" 

# define player page URL and player image URL
url <- paste0("https://www.basketball-reference.com/players/",substr(slug,1,1),"/",slug,".html")
image_url <- paste0("https://www.basketball-reference.com/req/202106291/images/players/",slug,".jpg")

# Read total stats
ttl_stat <- url %>%
  read_html %>%
  html_node("#totals") %>% 
  html_table()

# Read advanced stats
adv_stat <- url %>%
  read_html %>%
  html_node("#advanced") %>% 
  html_table()

# Merge stats tables
total_stats <- merge(ttl_stat, adv_stat, by=c("Season","Age", "Tm", "Lg", "Pos", "G", "MP"))
