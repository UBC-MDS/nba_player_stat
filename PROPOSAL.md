
- author: Althrun Sun, Lin Chen, Peng Zhang

## Motivation and Purpose


The motivation behind this project is to help NBA fans better understand their favorite players and visualize how the players have performed historically over time and across teams. Since the NBA has a long history and team changes are a regular occurrence, it was necessary to create a data visualization app that could cover all 30 teams in the NBA.

Further, it helps NBA fans make better decisions when betting, as the clustering visualization of player data helps fans give basic judgments on player performance levels. Fans can determine a player's style of play by where he scores most often, how he scores most often, the number of assists, etc., and use this as a starting point to get to know a new player.

On the other hand, we can also honor those former superstars, such as Kobe Bryant, by visualizing their performance. We can learn about the wonders the legendary superstar created with the Lakers and the glory of the purple and gold dynasty. Salute to the eternal Lakers #24.


## Description of the data

The NBA player stats data for regular season will be retrived from in real time from [The Basketball Reference website](https://www.basketball-reference.com/) when application user search the NBA player name in the search bar. 

The returned data will contain contain total of 54 features for each year of this player in the NBA along with some particular summary stats based on the team he played for, as well as a career summary.

For the usage of the returned data, we won't be using all of the features. 

Before dive into the details about the data, it would be necessary to explain what each used feature column means:
- Season : The regular season played.
- Age : Player's age on February 1 of the season
- Tm : Team
- Pos : Position
- G : Games
- FG% : Field Goal Percentage
- TRB : Total Rebounds Per game
- AST : Assists Per game
- STL : Steals Per game
- BLK : Blocks Per game
- PTS : Points Per game

The data features will be used for this application are as followings:

1. For player information section, we used 
    - The `Pos` column for **Position**
    - The `Age` column of the last year (from `Season` column) player in NBA for **Age**
    - The `Season` column (the rows for each year the player player) for **Experience**

2. For interaction/filter section, we used
    - The `Season` column (the rows for each year the player played) for **Year** slide bar
    - The `Tm` column for **Team** check boxes, by using the unique values in the `Tm` column

3. For the game information plot section, we used
    - The `PTS` column divided by the `G` column (the rows for each year the player player) for **Point per game**
    - The `FG%` column (the rows for each year the player player) for **Shooting accuracy** (this can be further breakdown into **3 Pointer shooting accuracy**, **2 Pointer shooting accuracy** and **Free Throw shooting accuracy** for furture development)

4. For the game played plot section, we used:
    - The `G` column (the rows for each year the player player) 

5. For the player skill section, we used:
    - The `PTS` column divided by the `G` column (the rows for each year the player player) for **Point per game**
    - The `TRB` column divided by the `G` column (the rows for each year the player player) for **Total Rebound per game**
    - The `AST` column divided by the `G` column (the rows for each year the player player) for **Assist per game**
    - The `STL` column divided by the `G` column (the rows for each year the player player) for **Steal per game**
    - The `BLK` column divided by the `G` column (the rows for each year the player player) for **Block per game**

## Primary research question and usage scenarios

The project aims to answer the following primary question:
How can we understand a NBA player's historical performance and the type of role he plays on the court?
Below is an example of usage scenario from a member of our target audience.

Tom is an enthusiast NBA fan and playing sports betting in his spare time. He is interested with assessing NBA players based on their performance in the previous NBA games. The dashboard developed from this project provides statistics data visualization covering basketball players from all 30 teams in the NBA. Tom is able to search a particular player by their name, filter their performance data by specifying the year, quarter, and corresponding team names, then he can easily check the player's statistics, such as points per game, shooting accuracy, and skill indicators. The dashboard is a handy tool for him to make betting decisions through the data-driven approach.


