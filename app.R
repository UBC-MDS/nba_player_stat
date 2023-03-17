# NBA Stats App

# Load necessary libraries for the app
library(shiny)
library(ggplot2)
library(thematic)
library(plotly)
library(plyr)
library(tidyverse)
library(rvest)
library(ggrepel)
library(readr)
library(RCurl)
library(jpeg)

# For Radar chart
library(ggradar)
# For checking URL
library(httr)
# For capitalize the name
library(stringr)
library(htmltools)
#sun's package
library(stringdist)
library(tidyverse)
#read the data first
data <- read_csv("docs/player_data.csv")
players_list<-c(data$name)
#Using  the Jaro-Winkler distance to match the most similar text.
find_closest_name <- function(target_name, name_list) {
  target_name_lower <- tolower(target_name)
  name_list_lower <- tolower(name_list)
  

  distances <- sapply(name_list_lower, function(x) stringdist(target_name_lower, x, method = "jw"))
  
  min_index <- which.min(distances)
  
  return(name_list[min_index])
}


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
  # print(team_code)
  # if (team_code %in% names(teams)) {
  #   print(teams[[team_code]])
  #   return(teams[[team_code]])
  # } else {
  #   print('NOT A TEAM')
  #   return('NOT A TEAM')
  # }
  return(teams[[team_code]])
}

get_player_web <- function(player) {
  player_name_split <- tolower(strsplit(player, " ")[[1]])
  slug_ln <- substr(player_name_split[2], start = 1, stop = 5)
  slug_fn <- substr(player_name_split[1], start = 1, stop = 2)
  slug <- paste0(slug_ln, slug_fn, '01')#"bryanko01" 
  
  # define player page URL and player image URL
  url <- paste0("https://www.basketball-reference.com/players/",substr(slug,1,1),"/",slug,".html")
  image_url <- paste0("https://www.basketball-reference.com/req/202106291/images/players/",slug,".jpg")
  
  response <- GET(url)
  
  return(list(url = url,
              image_url = image_url,
              response = status_code(response)))
}

update_player <- function(player) {
  
  player_web <- get_player_web(player)
  
  url <- player_web$url
  image_url <- player_web$image_url
  
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
  
  # print(player_exp_no_na)
  
  player_exp_no_na$Team <- apply(player_exp_no_na, MARGIN = 1, FUN = function(x) {
    nba_teams_map(x["Tm"])
  })
  
  # print(player_exp_no_na)
  
  player_exp_no_na <- player_exp_no_na |> 
    rename_with(~ "Game played", .cols = "G")
  
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
  
  return(list(image_url = image_url, 
              player_exp_no_na = player_exp_no_na,
              player_exp = player_exp,
              player_first_season = player_first_season,
              player_last_season = player_last_season,
              player_age = player_age,
              player_positions = player_positions,
              player_teams = player_teams))
}

player <- str_to_title('Vince Carter')

player_info <- update_player(player)

image_url <- player_info$image_url
player_positions <- player_info$player_positions
player_age <- player_info$player_age
player_exp <- player_info$player_exp
player_first_season <- player_info$player_first_season
player_last_season <- player_info$player_last_season
player_exp_no_na <- player_info$player_exp_no_na
player_teams <- player_info$player_teams

# print(as.integer(gsub(",", "", substr(player_first_season, start = 1, stop = 4))))


# Define UI for application that draws a histogram
ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch="journal"),
  titlePanel(title=div(img(src="nba_logo.png", height='100px'), "NBA Player Stats Application Dashboard", align="center")),
  h6(" "),
  sidebarLayout(
    sidebarPanel(
      column(width = 12,
             # First part - Filter by Name (by Chen)
             h4("Search by player name :"),
             h6("(This search bar automatically checks player name, so make sure the player name is correct)"),
             textInput("player_search", "", placeholder="Search by CORRECT player 'first_name last_name'"),
             # actionButton("update_button", "Update Stats"),
             
             # Second Part - Player Description
             h6(" "),
             fluidRow(id='player_info',
                      column(width=4, align="center",
                             # img(id="player_image", src=image_url, width=100),
                             uiOutput("player_image_ui")),
                      # imageOutput("player_image_ui", width="150px")),
                      column(id = "player_intro", width = 8, align = "left",
                             fluidRow(column(width = 12,
                                             h2(
                                               style = "height:30px;margin-top:-10px;",
                                               textOutput(outputId = "player_full_name")
                                             ))),
                             fluidRow(column(width = 12,
                                             h6(
                                               style = "height:15px; padding-bottom:10px;text-decoration: underline;",
                                               'Position:'
                                             ))),
                             fluidRow(column(width = 12,
                                             h6(
                                               style = "height:15px; margin-top:-5px; padding-bottom:10px;",
                                               textOutput(outputId = "player_pos")
                                             ))),
                             fluidRow(column(width = 12,
                                             h6(
                                               style = "height:15px; text-decoration: underline;",
                                               'Age:'
                                             ))),
                             fluidRow(column(width = 12,
                                             h6(
                                               style = "height:15px;margin-top:-5px;",
                                               textOutput(outputId = "player_age")
                                             ))),
                             fluidRow(column(width = 12,
                                             h6(
                                               style = "height:15px; padding-bottom:10px;text-decoration: underline;",
                                               'Experience:'
                                             ))),
                             fluidRow(column(width = 12,
                                             h6(
                                               style = "height:15px;margin-top:-5px;",
                                               textOutput(outputId = "player_exp")
                                             )))
                      )),
             
             # Third Part - Filter by Year (by Nate)
             h1(" "),
             h1(" "),
             h1(" "),
             h1(" "),
             
              selectInput("stat_select", "Select a Statistic:",
                           choices = c("Points", "Assists", "Blocks", "Rebounds", "Steals")),
             
             sliderInput(
               inputId = "careeryearslider",
               label = "Career Year",
               min = as.integer(gsub(",", "", substr(player_first_season, start = 1, stop = 4))),
               max = as.integer(gsub(",", "", substr(player_last_season, start = 1, stop = 4))),
               value = range(as.integer(gsub(",", "", substr(player_first_season, start = 1, stop = 4))),
                             as.integer(gsub(",", "", substr(player_last_season, start = 1, stop = 4)))),
               step = 1,
               sep = ""),
             
             # Forth Part - Filter Team (by Sun)
             h1(" "),
             h1(" "),
             h1(" "),
             h1(" "),
             selectInput(inputId='team_select',
                         label="Select the team",
                         choices = player_teams,
                         selected = 'wt'),
             
             # Fifth Part - Select Whole Career (by Peng)
             h1(" "),
             h1(" "),
             checkboxInput('wholecareer_tick','Whole Career Statistics', value = TRUE),
             
             # Add spacing at bottom of sidebarLayout
             h3(" "),
             
      )
    ),
    mainPanel(
      column(width = 12, 
             column(width=10, align="center",
                    plotlyOutput(
                      outputId = "plot_pts",
                      width = "100%",
                      height = "220px",
                      inline = FALSE,
                      reportTheme = TRUE
                    ),
                    plotlyOutput(
                      outputId = "plot_game",
                      width = "100%",
                      height = "220px",
                      inline = FALSE,
                      reportTheme = TRUE
                    ),
                    plotOutput(
                      outputId = "plot_radar",
                      width = "100%",
                      height = "225px",
                    )
             ),
             
      )
    )
    
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  output$player_image_ui <- renderUI({
    tags$img(
      id = "player_image_",
      src = image_url,
      width = 120
    )
  })
  
  # output$image <- renderImage({
  #   list(src = image_url, width = "100%") # Set the width to 100% to make the image responsive
  # }, deleteFile = TRUE)
  
  # output$player_image_ui <- renderImage({
  #   filename <- normalizePath(image_url)
  #   
  #   # Return a list containing the filename and alt text
  #   list(href = filename)
  #   
  # }, deleteFile = FALSE)
  
  output$player_full_name <- renderText({
    'Vince Carter'
  })
  
  output$player_pos <- renderText({
    player_positions
  })
  
  output$player_age <- renderText({
    paste0(player_age)
  })
  
  output$player_exp <- renderText({
    paste0(player_exp, ' years.')
  })
  
  # automatically uncheck whole career when updating careeryearslider
  observeEvent(input$careeryearslider, {
    updateCheckboxInput(session, "wholecareer_tick", value = FALSE)
  })
  
  # automatically uncheck whole career when updating team_select
  observeEvent(input$team_select, {
    updateCheckboxInput(session, "wholecareer_tick", value = FALSE)
  })
  
  update_plots <- function(input, output, session){
    output$plot_pts <- renderPlotly({
      
      # Filter by Year (by Nate)
      min_year_input <- as.integer(input$careeryearslider[1])
      max_year_input <- as.integer(input$careeryearslider[2])
      data_by_year <- player_exp_no_na |> filter(Season >= min_year_input, Season <= max_year_input)
      
      # Filer by Team (by Sun)
      selected_team <- substr(input$team_select,
                              start = nchar(input$team_select) - 3,
                              stop = nchar(input$team_select) - 1)
      data_by_year_team <- data_by_year |> filter(Tm == selected_team)
      
      # Filter Whole Career (by Peng)
      if (input$wholecareer_tick) {
        displayed_data <- player_exp_no_na
        text_title <- 'Points/Games for the Whole Career '
      } else {
        displayed_data <- data_by_year_team
        text_title <- paste0('Points/Games between ', 
                             min_year_input, ' and ', max_year_input, ' playing for ', input$team_select)
      }
      
      
      # Plot
      ggplotly( 
        ggplot(displayed_data, 
               aes(Season, `PTS per game`, color = Team, group = Team)) + 
          guides(fill = "none") +
          ggtitle(text_title) +
          ylab('Points per games') +
          geom_point(stat = 'summary', fun = sum) +
          geom_line(stat = 'summary', fun = sum, alpha = 0.5) +
          theme(axis.text.x = element_text(angle = 45, hjust = 1))
      )
    })
    
    output$plot_game <- renderPlotly({
      
      # Filter by Year (by Nate)
      min_year_input <- as.integer(input$careeryearslider[1])
      max_year_input <- as.integer(input$careeryearslider[2])
      data_by_year <- player_exp_no_na |> filter(Season >= min_year_input, Season <= max_year_input)
      
      # Filer by Team (by Sun)
      selected_team <- substr(input$team_select, 
                              start = nchar(input$team_select) - 3,
                              stop = nchar(input$team_select) - 1)
      data_by_year_team <- data_by_year |> filter(Tm == selected_team)
      
      # Filter Whole Career (by Peng)
      if (input$wholecareer_tick) {
        displayed_data <- player_exp_no_na
        text_title <- 'Games Played for the Whole Career '
      } else {
        displayed_data <- data_by_year_team
        text_title <- paste0('Games played between ', 
                             min_year_input, ' and ', max_year_input, ' playing for ', input$team_select)
      }
      
      ggplotly( 
        ggplot(displayed_data, 
               aes(Season, `Game played`)) +
          ggtitle(text_title) +
          geom_bar(stat = 'summary', fun = sum, fill = "#c8102e") +
          ylab('Game Played') +
          theme(axis.text.x = element_text(angle = 45, hjust = 1),
                legend.position = "none"))
    })
    
    output$plot_radar <- renderPlot({
      
      # Filter by Year (by Nate)
      min_year_input <- as.integer(input$careeryearslider[1])
      max_year_input <- as.integer(input$careeryearslider[2])
      data_by_year <- player_exp_no_na |> filter(Season >= min_year_input, Season <= max_year_input)
      
      # Filer by Team (by Sun)
      selected_team <- substr(input$team_select, 
                              start = nchar(input$team_select) - 3,
                              stop = nchar(input$team_select) - 1)
      data_by_year_team <- data_by_year |> filter(Tm == selected_team)
      
      # Filter Whole Career (by Peng)
      if (input$wholecareer_tick) {
        displayed_data <- player_exp_no_na
      } else {
        displayed_data <- data_by_year_team
      }
      
      # Create a matrix of player data
      player_matrix <- data.frame(
        Points = mean(displayed_data$`PTS per game`),
        Assists = mean(displayed_data$`AST per game`),
        Steals = mean(displayed_data$`STL per game`),
        Rebounds = mean(displayed_data$`TRB per game`),
        Blocks = mean(displayed_data$`BLK per game`)
      ) |> rownames_to_column(var = "Category")
      
      # Find the maximum value in the data frame
      max_val <-max(player_matrix[, -1])
      grid_vals <- seq(0, max_val, length.out = 5)
      grid_max <- ceiling(max(grid_vals) * 1.1)
      grid_vals[length(grid_vals)] <- grid_max
      grid_mid_idx <- (length(grid_vals) + 1) / 2
      grid_vals_for_ggradar <- c(grid_vals[1],
                                 ceiling(grid_vals[grid_mid_idx]),
                                 grid_vals[length(grid_vals)])
      
      # Highest season avgs in NBA regular seasons
      nba_reg_high_pts <- 50.36 # Wilt Chamberlain*	
      nba_reg_high_trb <- 27.2 # Wilt Chamberlain*	
      nba_reg_high_ast <- 14.5 # John Stockton
      nba_reg_high_stl <- 3.67 # Alvin Robertson
      nba_reg_high_blk <- 3.5 # Mark Eaton	
      
      nba_reg_high <- c(ceiling(nba_reg_high_pts),
                        ceiling(nba_reg_high_trb),
                        ceiling(nba_reg_high_ast),
                        ceiling(nba_reg_high_stl),
                        ceiling(nba_reg_high_blk))
      
      ggradar(
        player_matrix, 
        values.radar = grid_vals_for_ggradar,
        grid.min = grid_vals[1], 
        grid.mid = ceiling(grid_vals[grid_mid_idx]), 
        grid.max = grid_vals[length(grid_vals)],
        axis.label.size = 4,
        # Polygons
        group.line.width = 1, 
        group.point.size = 3,
        group.colours = "#1d428a",
        # Background and grid lines
        background.circle.colour = "white",
        gridline.mid.colour = "grey"
      )
    })
  }
  
  thematic::thematic_shiny()
  
  image_url <- player_info$image_url
  player_positions <- player_info$player_positions
  player_age <- player_info$player_age
  player_exp <- player_info$player_exp
  player_first_season <- player_info$player_first_season
  player_last_season <- player_info$player_last_season
  player_exp_no_na <- player_info$player_exp_no_na
  player_teams <- player_info$player_teams
  
  url_status_200 <- FALSE
  
  # Define reactive to get input value
  observeEvent(input$player_search, {
    
    middleware<-find_closest_name(input$player_search,players)
    player <<- str_to_title(middleware)
    # player <<- str_to_title(input$player_search)
    # print(player)
    url_status <- get_player_web(player)$response
    
    if (url_status == 200){
      # print(paste0("The URL ", url, " is accessible."))
      player_info <- update_player(player)
      image_url <- player_info$image_url
      player_positions <- player_info$player_positions
      player_age <- player_info$player_age
      player_exp <- player_info$player_exp
      player_first_season <- player_info$player_first_season
      player_last_season <- player_info$player_last_season
      player_exp_no_na <- player_info$player_exp_no_na
      player_teams <- player_info$player_teams
      
      url_status_200 <- TRUE
      
      # image_url(image_url)  
      
      output$player_image_ui <- renderUI({
        tags$img(
          id = "player_image_",
          src = image_url,
          width = 120
        )
      })
      
      output$player_full_name <- renderText({
        #player
        find_closest_name(player,players_list)
      })
      
      output$player_pos <- renderText({
        player_positions
      })
      
      output$player_age <- renderText({
        paste0(player_age)
      })
      
      output$player_exp <- renderText({
        paste0(player_exp, ' years.')
      })
      
      updateSliderInput(session, 
                        "careeryearslider", 
                        min = as.integer(substr(player_first_season, start = 1, stop = 4)),
                        max = as.integer(substr(player_last_season, start = 1, stop = 4)),
                        # value = as.integer((as.integer(substr(player_first_season, start = 1, stop = 4)) + 
                        #                       as.integer(substr(player_last_season, start = 1, stop = 4)))/2),
                        value = c(as.integer(substr(player_first_season, start = 1, stop = 4)),
                                  as.integer(substr(player_last_season, start = 1, stop = 4)))
      )
      updateSelectInput(session, 
                        "team_select", 
                        choices = player_teams)
      
      #updateCheckboxInput(session, "wholecareer_tick", value = TRUE)
      
      output$plot_pts <- renderPlotly({
        
        # Filter by Year (by Nate)
        min_year_input <- as.integer(input$careeryearslider[1])
        max_year_input <- as.integer(input$careeryearslider[2])
        data_by_year <- player_exp_no_na |> filter(Season >= min_year_input, Season <= max_year_input)
        
        # Filer by Team (by Sun)
        selected_team <- substr(input$team_select,
                                start = nchar(input$team_select) - 3,
                                stop = nchar(input$team_select) - 1)
        data_by_year_team <- data_by_year |> filter(Tm == selected_team)
        
                # bind the selected option to the top_stat_type variable
        top_stat_type <- reactive({
          input$stat_select
        })
        curr_stat<-top_stat_type()
        if (input$wholecareer_tick) {
          displayed_data <- player_exp_no_na
          text_title <- paste(curr_stat,'/Games for the Whole Career ')
        } else {
          displayed_data <- data_by_year_team
          text_title <- paste0(curr_stat,'/Games between ', 
                               min_year_input, ' and ', max_year_input, ' playing for ', input$team_select)
        }
        # print(displayed_data)
        get_y_axis_label <- function(input_string) {
  # use switch statement to select the appropriate label based on the input string
  label <- switch(input_string,
                  "Points" = "PTS per game",
                  "Assists" = "AST per game",
                  "Blocks" = "BLK per game",
                  "Rebounds" = "TRB per game",
                  "Steals" = "STL per game")
  return(label)
}
        # Plot
        ggplotly( 
          ggplot(displayed_data, 
                 aes(Season, .data[[get_y_axis_label(curr_stat)]], color = Team, group = Team)) + 
            guides(fill = "none") +
            ggtitle(text_title) +
            ylab(paste(curr_stat,' per games')) +
            geom_point(stat = 'summary', fun = sum) +
            geom_line(stat = 'summary', fun = sum, alpha = 0.5) +
            theme(axis.text.x = element_text(angle = 45, hjust = 1))
        )
      })
      
      output$plot_game <- renderPlotly({
        
        # Filter by Year (by Nate)
        min_year_input <- as.integer(input$careeryearslider[1])
        max_year_input <- as.integer(input$careeryearslider[2])
        data_by_year <- player_exp_no_na |> filter(Season >= min_year_input, Season <= max_year_input)
        
        # Filer by Team (by Sun)
        selected_team <- substr(input$team_select, 
                                start = nchar(input$team_select) - 3,
                                stop = nchar(input$team_select) - 1)
        data_by_year_team <- data_by_year |> filter(Tm == selected_team)
        
        # Filter Whole Career (by Peng)
        if (input$wholecareer_tick) {
          displayed_data <- player_exp_no_na
          text_title <- 'Games Played for the Whole Career '
        } else {
          displayed_data <- data_by_year_team
          text_title <- paste0('Games played between ', 
                               min_year_input, ' and ', max_year_input, ' playing for ', input$team_select)
        }
        
        ggplotly( 
          ggplot(displayed_data, 
                 aes(Season, `Game played`)) +
            ggtitle(text_title) +
            geom_bar(stat = 'summary', fun = sum, fill = "#c8102e") +
            ylab('Game Played') +
            theme(axis.text.x = element_text(angle = 45, hjust = 1),
                  legend.position = "none"))
      })
      
      output$plot_radar <- renderPlot({
        
        # Filter by Year (by Nate)
        min_year_input <- as.integer(input$careeryearslider[1])
        max_year_input <- as.integer(input$careeryearslider[2])
        data_by_year <- player_exp_no_na |> filter(Season >= min_year_input, Season <= max_year_input)
        
        # Filer by Team (by Sun)
        selected_team <- substr(input$team_select, 
                                start = nchar(input$team_select) - 3,
                                stop = nchar(input$team_select) - 1)
        data_by_year_team <- data_by_year |> filter(Tm == selected_team)
        
        # Filter Whole Career (by Peng)
        if (input$wholecareer_tick) {
          displayed_data <- player_exp_no_na
        } else {
          displayed_data <- data_by_year_team
        }
        
        # Create a matrix of player data
        player_matrix <- data.frame(
          Points = mean(displayed_data$`PTS per game`),
          Assists = mean(displayed_data$`AST per game`),
          Steals = mean(displayed_data$`STL per game`),
          Rebounds = mean(displayed_data$`TRB per game`),
          Blocks = mean(displayed_data$`BLK per game`)
        ) |> rownames_to_column(var = "Category")
        # print(player_matrix)
        
        # Find the maximum value in the data frame
        max_val <-max(player_matrix[, -1])
        grid_vals <- seq(0, max_val, length.out = 5)
        grid_max <- ceiling(max(grid_vals) * 1.1)
        grid_vals[length(grid_vals)] <- grid_max
        grid_mid_idx <- (length(grid_vals) + 1) / 2
        grid_vals_for_ggradar <- c(grid_vals[1],
                                   ceiling(grid_vals[grid_mid_idx]),
                                   grid_vals[length(grid_vals)])
        
        # Highest season avgs in NBA regular seasons
        nba_reg_high_pts <- 50.36 # Wilt Chamberlain*	
        nba_reg_high_trb <- 27.2 # Wilt Chamberlain*	
        nba_reg_high_ast <- 14.5 # John Stockton
        nba_reg_high_stl <- 3.67 # Alvin Robertson
        nba_reg_high_blk <- 3.5 # Mark Eaton	
        
        nba_reg_high <- c(ceiling(nba_reg_high_pts),
                          ceiling(nba_reg_high_trb),
                          ceiling(nba_reg_high_ast),
                          ceiling(nba_reg_high_stl),
                          ceiling(nba_reg_high_blk))
        
        ggradar(
          player_matrix, 
          values.radar = grid_vals_for_ggradar,
          grid.min = grid_vals[1], 
          grid.mid = ceiling(grid_vals[grid_mid_idx]), 
          grid.max = grid_vals[length(grid_vals)],
          axis.label.size = 4,
          # Polygons
          group.line.width = 1, 
          group.point.size = 3,
          group.colours = "#1d428a",
          # Background and grid lines
          background.circle.colour = "white",
          gridline.mid.colour = "grey"
        )
      })
    }
  })
  
  update_plots(input, output, session)
  
}

# Run the application 
shinyApp(ui = ui, server = server)