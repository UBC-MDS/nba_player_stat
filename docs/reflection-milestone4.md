## Reflection on NBA Performance Shiny App Development - MS4

### What have been implemented

During the milestone 4, we have implemented the following tasks for the Shiny app:

1.  App improvements

Based on the TA feedback and peer reviewers' suggestions, the following improvements have been completed:

-   Added statistic selection drop down to provide users with options of checking individual metrics. Now users are able to review particular performance metrics separately when they evaluate the player's technical skills. It is expected that the new feature will make the app more suitable for coaches or basket ball sporting analysts.
-   Added approximate string matching to NBA players name search bar. It has enhanced the user-friendly feature of the app that becomes more convenient for users to search their interested players without tying exact letters.
-   Added dynamic UI element to automatically uncheck whole career when users update yearslider or team_select. Previously, users have to uncheck the whole career box first and then continue to explore their desired year range or teams. The new feature makes the app more intuitive.
-   Improved multiple visualization elements for plots, such as axis labels, legend, display of year values, player's image rendering, etc. Particularly the first plot (Statistic metrics per game during the year range and at certain team) now shows more information on one single figure.
-   Improved the documentation in the ReadMe file to make the instructions to users more clear.

2.  Reproducibility

As per the milestone 4 requirement, three tests have been created with the `shinytests2` package. In addition, the GitHub Action workflows for the automatic deployment to `shinyapps.io` and testing have been added and successfully passed.

3.  Further works for Production-ready app

-   Added spinners on all output plots.
-   Moved the app.R to root directory to make testing and deployment more smoothly.
-   Added GitHub repo description ("About" section) together with link to the final deployed app, and keywords.
-   Performed final check for reactivity and make sure all proposed functionality working properly.

### What not yet implemented

Due to the time constraint, the following items have not been implemented before submitting the milestone 4:

-   We have received a couple of feedback from TAs and peer reviewers regarding the player name search bar. The team recognized the importance of searching convenience for app users, and we invested significant amount of hours to adopt the approximate string matching algorithm in the app. The current approach works better than previous version but there are still rooms for further improvements, such as showing drop down options when typing names.

-   After adding the dynamic UI element to automatically uncheck whole career when yearslider or team_select is triggered, we found it might still have another intuitive confusion for some users. After they click the whole career checkbox, the yearslider is frozen with showing the previously selected year range (not matching the intuition of the "whole career year range"). We need to figure out a better solution to try to cover all possible scenarios later.

Furthermore, the team members were considering to apply more what we have learned from the 532 course in this app development, such as adding downloadable report, using reactive functions to avoid code duplication, etc. Since we encountered a few technical issues for testing and debug during the week although they were solved eventually, we will have to continuously improve the project after the course.
