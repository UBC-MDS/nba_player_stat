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

# Get PLayer Position, Age and Experience
player_stats <- total_stats |> select(c('Season', 'Age', 'Tm', 'Pos', 'G', 'FG%', 'TRB', 'AST', 'STL', 'BLK', 'PTS')) |>
  mutate('TRB per game' = round(player_stats$TRB / player_stats$G, 2),
         'AST per game' = round(player_stats$AST / player_stats$G, 2),
         'STL per game' = round(player_stats$STL / player_stats$G, 2),
         'BLK per game' = round(player_stats$BLK / player_stats$G, 2),
         'PTS per game' = round(player_stats$PTS / player_stats$G, 2))

player_exp_no_na <- player_stats |> filter(!is.na(player_stats$Age))

player_exp <- length(unique(player_exp_no_na$Age))

player_age <- max(player_exp_no_na$Age, na.rm = TRUE)


ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "journal"),
  titlePanel(title=div(img(src="nba_logo.png", height='50px'), "NBA Player Stats Application Dashboard")),
  fluidRow(column(width = 5,
                  h4("Search by player name :"),
                  sidebarPanel(
                    width = 8,
                    textInput("search", "", placeholder = "Search by player full name (first_name last_name)")),
                  fluidRow(column(width = 3, align = "center", img(src=image_url, width=100)),
                           column(width = 8, align = "center",
                                  fluidRow(player),
                                  fluidRow('Position:', player),
                                  fluidRow('Age:', player),
                                  fluidRow('Experience:', player))),
                  h4("Filters :"),
                  sidebarLayout(
                    sidebarPanel(
                      sliderInput(
                        inputId = "careeryearslider",
                        label = "Career Year",
                        min = 1990,
                        max = 2010,
                        value = 1995
                      )
                    ),
                    mainPanel(plotOutput(outputId = "distplot"))
                  ),
                  fluidRow(column(width = 2, "Team(s)")),
                  fluidRow(column(width = 6, checkboxInput('change_sign','Team A'))),
                  fluidRow(column(width = 6, checkboxInput('change_sign','Team B'))),
                  fluidRow(column(width = 6, checkboxInput('change_sign','Team C'))),
                  fluidRow(column(width = 6, checkboxInput('change_sign','Team D')))),
           column(
             width = 6,
             h4("Points per game and shooting accuracy :"),
             fluidRow(column(width = 8, align = "center", img(src="PTS.png", height='200px'))),
             h4("Game played in each season :"),
             fluidRow(column(width = 8, align = "center", img(src="GamePlayed.png", height='200px'))),
             h4("Player Radar Chart :"),
             fluidRow(column(width = 8, align = "center", img(src="PlayerRadar.png", height='250px'))),
           ))
)

server <- function(input, output, session) {
  
  thematic::thematic_shiny()
  output$distplot <- renderPlot({
    # generate bins
    x <- total_stats$PTS
    bins <- seq(min(x), max(x), length.out = input$careeryearslider + 1)
    
    # draw the histogram with the specified number of bins
    hist(x,
         breaks = bins, col = "darkgray", border = "white",
         xlab = "Career year/season",
         main = "Histogram of Points per game by season"
    )
  })
  
}

shinyApp(ui, server)
