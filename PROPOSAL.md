---
editor_options: 
  markdown: 
    wrap: 72
---

# Motivation and Purpose

Our role: Data scientist consultancy firm.

Target audience: People who are enthusiastic NBA fans and are interested
in assessing NBA player performances.

NBA or National Basketball Association is the most famous professional
Basketball league in the world. It consists of 30 professional
basketball teams with approximately 500 players playing per season.

The motivation behind this project is to help NBA fans better understand
their favorite players and visualize how the players have performed
historically over time and across players and teams. Since the NBA has a
long history and team changes are a regular occurrence, it is necessary
to create a data visualization that could show the player's
performances.

Further, it helps NBA fans make better decisions when betting, as the
visualization of player data helps fans give basic judgments on player
performance levels. Fans can determine a player's style such as what
kind of player he is, how many games he plays, how much he scores per
game, the number of assists, etc., and use this as a starting point to
get to know a new player better.

On the other hand, we can also honor and learn those former NBA
superstars, such as Micheal Jordan and Kobe Bryant, by visualizing their
performances. For instance, Kobe Bryant, we can learn about the wonders
the legendary superstar created with the Lakers and the glory of the
purple and gold dynasty with scored 33,643 points, 7,047 rebounds, and
6,306 assists during the entire career. Salute to the eternal Lakers
#24.

# Description of the data

The NBA player stats data for the regular season will be retrieved from
in real-time from [The Basketball Reference
website](https://www.basketball-reference.com/) when the application
user searches the NBA player name in the search bar.

The returned data will contain a total of 54 features for each year of
this player in the NBA along with some particular summary stats based on
the team he played for, as well as a career summary.

For the usage of the returned data, we won't be using all of the
features.

Before diving into the details of the data, it would be necessary to
explain what each used feature column means: - Season : The regular
season played. - Age : Player's age on February 1 of the season - Tm :
Team - Pos : Position - G : Games - FG% : Field Goal Percentage - TRB :
Total Rebounds Per game - AST : Assists Per game - STL : Steals Per
game - BLK : Blocks Per game - PTS : Points Per game

The data features will be used for this application are as followings:

1.  For player information section, we used
    -   The `Pos` column for **Position**
    -   The `Age` column of the last year (from `Season` column) player
        in NBA for **Age**
    -   The `Season` column (the rows for each year the player player)
        for **Experience**
2.  For interaction/filter section, we used
    -   The `Season` column (the rows for each year the player played)
        for **Year** slide bar
    -   The `Tm` column for **Team** check boxes, by using the unique
        values in the `Tm` column
3.  For the game information plot section, we used
    -   The `PTS` column divided by the `G` column (the rows for each
        year the player player) for **Point per game**
    -   The `FG%` column (the rows for each year the player player) for
        **Shooting accuracy** (this can be further breakdown into **3
        Pointer shooting accuracy**, **2 Pointer shooting accuracy** and
        **Free Throw shooting accuracy** for furture development)
4.  For the game played plot section, we used:
    -   The `G` column (the rows for each year the player player)
5.  For the player skill section, we used:
    -   The `PTS` column divided by the `G` column (the rows for each
        year the player player) for **Point per game**
    -   The `TRB` column divided by the `G` column (the rows for each
        year the player player) for **Total Rebound per game**
    -   The `AST` column divided by the `G` column (the rows for each
        year the player player) for **Assist per game**
    -   The `STL` column divided by the `G` column (the rows for each
        year the player player) for **Steal per game**
    -   The `BLK` column divided by the `G` column (the rows for each
        year the player player) for **Block per game**

# Primary research question and usage scenarios

The project aims to answer the following primary question:

`How can we understand a NBA player's historical performance and skills during their career?`

Below is an example of a usage scenario from a member of our target
audience.

Tom is an enthusiastic NBA fan and would like to assess his loved NBA
players based on the real performance data in previous NBA games. There
are some options available on the internet to obtain the information,
such as searching particular players through Wikipedia pages, checking
historical data from NBA official website, sporting news websites, and
[The Basketball Reference
website](https://www.basketball-reference.com/), etc. However, he found
it was less effective to find his interested information in a
well-organized way from these websites. Either he had to read paragraphs
or a massive table to extract key data by himself, or there was less
control to customize the visualizations to make his own analysis
conclusions. By using `NBA Player Stats Application Dashboard`, now Tom
can effectively and efficiently search players' NBA performance data and
draw insights from the app. When he enters one of his loved player's
name, Vince Carter, in the search section of the app, firstly, he will
see Vince's head photo and basic information including position, age,
years of experiences. Then he is able to see three plots to show the
player's performance history, such as points per game, number of games
played, and some skill indicators (Point per game, Total Rebound per
game, Assist per game, Steal per game, and Block per game). The app has
provided filtering features for him to select the particular year
range and NBA team to output the above plots matching his desired
conditions. This is a convenient way for Tom to play with the plotting
and help him to analyze the player's performance in particular year(s)
and in a specific team. By setting the year range between 1998 and 2008,
it is clear to see Vince had earned above 20 points on average for most
of the years; but after 2008, his capability to gain points had been
dropped year after year till 2019 when he left the NBA although the
total number of games he played annually did not decrease for the
later years. In addition, the app indicates Vince had played with eight NBA teams during his career. It seems he had the best performance when he was a team member with Toronto Raptors (TOR) from 1998 to 2004.
