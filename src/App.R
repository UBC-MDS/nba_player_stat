# NBA Stats App

# Load necessary libraries for the app
library(shiny)
library(ggplot2)
library(plotly)
library(plyr)
library(tidyverse)
library(rvest)
library(ggrepel)
library(readr)
library(RCurl)
library(jpeg)

# For Radar chart
# library(fmsb) 
library(ggradar)


# Read the dataset from the specified location in the application file directory
#dataset <-
  #read.csv("../data/preload_data_player_name.csv")

# Using real time api to load nba player stats data

# ---- Functions ----
position_map <- function(pos) {
  pos <- toupper(pos)  # convert input to all uppercase
  switch(pos,
         "PG" = "Point Guard",
         "SG" = "Shooting Guard",
         "SF" = "Small Forward",
         "PF" = "Power Forward",
         "C" = "Center")
}

nba_teams_map <- function(team_code) {
  teams <- list(ATL = "Atlanta Hawks (ATL)",
                BKN = "Brooklyn Nets (BKN)",
                BOS = "Boston Celtics (BOS)",
                CHA = "Charlotte Hornets (CHA)",
                CHI = "Chicago Bulls (CHI)",
                CLE = "Cleveland Cavaliers (CLE)",
                DAL = "Dallas Mavericks (DAL)",
                DEN = "Denver Nuggets (DEN)",
                DET = "Detroit Pistons (DET)",
                GSW = "Golden State Warriors (GSW)",
                HOU = "Houston Rockets (HOU)",
                IND = "Indiana Pacers (IND)",
                LAC = "Los Angeles Clippers (LAC)",
                LAL = "Los Angeles Lakers (LAL)",
                MEM = "Memphis Grizzlies (MEM)",
                MIA = "Miami Heat (MIA)",
                MIL = "Milwaukee Bucks (MIL)",
                MIN = "Minnesota Timberwolves (MIN)",
                NOP = "New Orleans Pelicans (NOP)",
                NJN = "Brooklyn Nets (NJN)",
                NYK = "New York Knicks (NYK)",
                OKC = "Oklahoma City Thunder (OKC)",
                ORL = "Orlando Magic (ORL)",
                PHI = "Philadelphia 76ers (PHI)",
                PHO = "Phoenix Suns (PHO)",
                PHX = "Phoenix Suns (PHX)",
                POR = "Portland Trail Blazers (POR)",
                SAC = "Sacramento Kings (SAC)",
                SAS = "San Antonio Spurs (SAS)",
                TOR = "Toronto Raptors (TOR)",
                TOT = "Two Other Teams (TOT)",
                UTA = "Utah Jazz (UTA)",
                WAS = "Washington Wizards (WAS)")
  return(teams[[team_code]])
}

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

# Prepare player stats table
player_stats <- total_stats |> select(c('Season', 'Age', 'Tm', 'Pos', 'G', 'FG%', 'TRB', 'AST', 'STL', 'BLK', 'PTS'))

player_stats <- player_stats |>
  mutate('TRB per game' = round(player_stats$TRB / player_stats$G, 2),
         'AST per game' = round(player_stats$AST / player_stats$G, 2),
         'STL per game' = round(player_stats$STL / player_stats$G, 2),
         'BLK per game' = round(player_stats$BLK / player_stats$G, 2),
         'PTS per game' = round(player_stats$PTS / player_stats$G, 2))

# remove missing values
player_exp_no_na <- player_stats |> filter(!is.na(player_stats$Age))

player_exp_no_na <- player_exp_no_na[player_exp_no_na$Tm != 'TOT',]

# Get PLayer Experience
player_exp <- length(unique(player_exp_no_na$Age))

# Get Player career year range
player_first_season <- min(unique(player_exp_no_na$Season))
player_last_season <- max(unique(player_exp_no_na$Season))

# Get PLayer Age
player_age <- max(player_exp_no_na$Age, na.rm = TRUE)

# Get PLayer Positions
player_position_ls <- unique(player_exp_no_na$Pos)

player_positions <- ''

for (i in seq_along(player_position_ls)) {
  player_positions <- paste0(player_positions, 
                             position_map(player_position_ls[i]), 
                             collapse = "")
  if (i != length(player_position_ls)) {
    player_positions <- paste0(player_positions, ' & ', collapse = "")
  }
}

# Get PLayer teams
player_team_ls <- unique(player_exp_no_na$Tm)

player_teams <- c()

for (team in player_team_ls) {
  player_teams <- c(player_teams, nba_teams_map(team))
}


# ---- UI----
ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "journal"),
  titlePanel(title=div(img(src="nba_logo.png", height='50px'), "NBA Player Stats Application Dashboard")),
  fluidRow(column(
            width = 11,
            h4("Search by player name :"),
            sidebarPanel(
              width = 8,
              textInput("search", "", placeholder = "Search by player full name (first_name last_name)")),
            fluidRow(column(width = 3, align = "center", img(src=image_url, width=100)),
                     column(width = 8, align = "center",
                            fluidRow(player),
                            fluidRow('Position:', player_positions),
                            fluidRow('Age:', player_age),
                            fluidRow('Experience:', player_exp))),
            h4("Filters :"),
            sidebarLayout(
              sidebarPanel(
                width = 3,
                sliderInput(
                  inputId = "careeryearslider",
                  label = "Career Year",
                  min = as.integer(substr(player_first_season, start = 1, stop = 4)),
                  max = as.integer(substr(player_last_season, start = 1, stop = 4)),
                  value = as.integer((as.integer(substr(player_first_season, start = 1, stop = 4)) + 
                                       as.integer(substr(player_last_season, start = 1, stop = 4)))/2),
                  step = 1
                )
              ),
              mainPanel(
                width = 9,
                fluidRow(
                  column(width = 4, plotlyOutput(outputId = "plot_by_year_pts")),
                  column(width = 4, plotlyOutput(outputId = "plot_by_year_g")),
                  column(width = 4, plotOutput(outputId = "plot_by_year_radar"))
                )
              )
            ),
            sidebarLayout(
              sidebarPanel(
                width = 3,
                selectInput(inputId='team_select',
                            label="Select the team",
                            choices = player_teams,
                            selected = 'wt')
              ),
              mainPanel(
                width = 9,
                fluidRow(
                  column(width = 6, plotlyOutput(outputId = 'plot_by_team_pts')),
                  column(width = 6, plotlyOutput(outputId = "plot_by_team_g"))
                )
              )
            ),
            fluidRow(column(width = 2, "Team(s)")),
            fluidRow(column(width = 6, checkboxInput('change_sign','Team A'))),
            fluidRow(column(width = 6, checkboxInput('change_sign','Team B'))),
            fluidRow(column(width = 6, checkboxInput('change_sign','Team C'))),
            fluidRow(column(width = 6, checkboxInput('change_sign','Team D')))),
           # column(
           #   width = 5,
           #   h4("Points per game and shooting accuracy :"),
           #   fluidRow(column(width = 8, align = "center", img(src="PTS.png", height='200px'))),
           #   h4("Game played in each season :"),
           #   fluidRow(column(width = 8, align = "center", img(src="GamePlayed.png", height='200px'))),
           #   h4("Player Radar Chart :"),
           #   fluidRow(column(width = 8, align = "center", img(src="PlayerRadar.png", height='250px'))),
           # )
        )
)

# ---- Backend ----
server <- function(input, output, session) {
  
  thematic::thematic_shiny()
  
  output$plot_by_year_pts <- renderPlotly({
    
    year_input <- as.integer(input$careeryearslider)
    
    data_by_year <- player_exp_no_na[player_exp_no_na$Season <= year_input + 1,]
    
    ggplotly( 
      ggplot(data_by_year, 
             aes(Season, `PTS per game`)) + 
        ggtitle(paste0(player, ' Points per game between ', 
                       as.integer(substr(player_first_season, start = 1, stop = 4)), ' and ', 
                       year_input)) +
        geom_point()+
        theme(axis.text.x = element_text(angle = 45, hjust = 1)))
  })
  
  output$plot_by_year_g <- renderPlotly({
    
    year_input <- as.integer(input$careeryearslider)
    
    data_by_year <- player_exp_no_na[player_exp_no_na$Season <= year_input + 1,]
    
    ggplotly( 
      ggplot(data_by_year, 
             aes(Season, G)) + 
        ggtitle(paste0(player, ' games played between ', 
                       as.integer(substr(player_first_season, start = 1, stop = 4)), ' and ', 
                       year_input)) +
        geom_point()+
        theme(axis.text.x = element_text(angle = 45, hjust = 1)))
  })
  
  output$plot_by_year_radar <- renderPlot({
    year_input <- as.integer(input$careeryearslider)
    
    data_by_year <- player_exp_no_na[player_exp_no_na$Season <= year_input + 1,]
    
    avg_pts <- mean(data_by_year$`PTS per game`)
    avg_trb <- mean(data_by_year$`TRB per game`)
    avg_ast <- mean(data_by_year$`AST per game`)
    avg_stl <- mean(data_by_year$`STL per game`)
    avg_blk <- mean(data_by_year$`BLK per game`)
    
    # Create a matrix of player data
    player_matrix <- data.frame(
      Points = avg_pts,
      Rebounds = avg_trb,
      Assists = avg_ast,
      Steals = avg_stl,
      Blocks = avg_blk
    )
    
    print(player_matrix)
  
    # # Create a vector of stat labels
    # stat_labels <- rownames(player_matrix)
    # 
    # # Create a vector of maximum values for each stat
    # max_values <- rep(20, length(stat_labels))
    # 
    # # Create the radar chart
    # radarchart(player_matrix)
    
    ggradar(
      player_matrix, 
      values.radar = c("0", "10", "20"),
      grid.min = 0, grid.mid = 10, grid.max = 20,
      # Polygons
      group.line.width = 1, 
      group.point.size = 3,
      group.colours = "#00AFBB",
      # Background and grid lines
      background.circle.colour = "white",
      gridline.mid.colour = "grey"
    )
  })
  
  output$plot_by_team_pts <- renderPlotly({
    
    team_selected <- substr(input$team_select, 
                            start = nchar(input$team_select) - 3, 
                            stop = nchar(input$team_select) - 1)
    
    data_by_team <- player_exp_no_na[player_exp_no_na$Tm == team_selected,]
    
    ggplotly( 
      ggplot(data_by_team, 
             aes(Season, `PTS per game`)) + 
        ggtitle(paste0(player, ' played for ', input$team_select)) +
        geom_point()+
        theme(axis.text.x = element_text(angle = 45, hjust = 1)))
  })
  
  output$plot_by_team_g <- renderPlotly({
    
    team_selected <- substr(input$team_select, 
                            start = nchar(input$team_select) - 3, 
                            stop = nchar(input$team_select) - 1)
    
    data_by_team <- player_exp_no_na[player_exp_no_na$Tm == team_selected,]
    
    ggplotly( 
      ggplot(data_by_team, 
             aes(Season, G)) + 
        ggtitle(paste0(player, ' played for ', input$team_select)) +
        geom_point()+
        theme(axis.text.x = element_text(angle = 45, hjust = 1)))
  })
  
}

shinyApp(ui, server)
