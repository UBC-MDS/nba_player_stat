## Reflection on NBA Performance Shiny App Development - MS4

### What have been implemented

During the milestone 4, we have implemented the following tasks for the Shiny app:

1.  App improvements

Based on the TA feedback and peer reviewers' suggestions, the following improvements have been completed:

-   Added statistic selection drop down to provide users with options of checking individual metrics. Now users are able to review particular performance metrics separately when they evaluate the player's technical skills. It is expected that the new feature will make the app more suitable for coaches or basket ball sporting analysts.
-   Added approximate string matching to NBA players name search bar. It has enhanced the user-friendly feature of the app that becomes more convenient for users to search their interested players without tying exact letters.
-   Added dynamic UI element to automatically uncheck whole career when users update yearslider & team_select. Previously, users have to uncheck the whole career box first and then continue to explore their desired year range or teams. The new feature makes the app more intuitive.
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

In the current stage,

### Others
