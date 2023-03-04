## Reflection on NBA Performance Shiny App Development

### What have been implemented

The main objective of this visualization dashboard is to provide multiple statistics of NBA players within one Shiny app, enable users to search their interested players, filter the players' historical performance data by preferred conditions and see the information from the plots.

During the milestone 1 and milestone 2, the team has completed a prototype of the app and deployed it on ShinyApps.io. It is publicly accessible and fully usable at this time although we are planning to implement additional improvements during the course or in the future.

The original data utilized for this app is retrieved in real-time from [The Basketball Reference website](https://www.basketball-reference.com/) when the user searches the NBA player's name in the search bar. Then the returned raw data will be processed at the server end and displayed at the user interface.

We have implemented three panels as below:

*-* **TitlePanel**: indicate the title of the visualization dashboard\
*-* **SidebarPanel**: includes five parts:\
Part 1: TextInput to search by player's name\
Part 2: Player's description for head photo and basic information\
Part 3: SliderInput to filter by year\
Part 4: SelectInput to filter by NBA teams\
Part 5: CheckboxInput to choose if showing the whole career statistics\
*-* **MainPanel**: includes three plots:\
Plot 1: The player's points per game\
Plot 2: The player's total number of games played\
Plot 3: Skill indicator radar (Point per game, Total Rebound per game, Assist per game, Steal per game, and Block per game)\

All three plots are interactively updated based on users' inputs from the SidebarPanel. For example, if the user specifies a player, selects the year range and team name, all three plots will be automatically filtered by the corresponding conditions unless the checkbox for the whole career statistics being checked. In that case, the plots will be showed for all data during the player's whole NBA career.

The development process has been following the course instructions, TA's feedback, and our proposal. Most of aspects of the app were implemented as proposed, but we have updated the overall layout of the panels from the original sketch to make the user interface looks more clean.

### What to be implemented

We are considering to update the theme to make the app more attractive.

### Limitations & Future improvements

The app has provided a clear and straightforward way for users to check NBA players' performance data. No particular searching skills and software knowledge is needed for a general public user to access the dashboard. However, due to the time constraint, we would acknowledge there are some limitations that may not meet users' additional needs. Such as to check more categories of performance indicators beyond what we can provide, to compare different players' data on one plot, or to make inference or predictions based on the historic data. We welcome more feedback from the course instructor, TAs, and all users.
