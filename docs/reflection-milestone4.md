## Reflection on NBA Performance Shiny App Development - MS4

### What have been implemented

During the milestone 4, we have implemented the following tasks for the Shiny app:

1.  App improvements

Based on the TA feedbacks, peer reviewers' suggestions, and also instructor feedback, the following improvements have been completed:

-   Added NBA player string matching function on player search bar. It has enhanced the user-friendly feature of the app that becomes more convenient for users to search their interested players without tying exact letters and prevent mis-spelling or inputting wrong player name.
-   Added statistic drop down selection to provide users with options of checking individual metrics. Now users are able to review particular performance metrics separately when they evaluate the player's technical skills. It is expected that the new feature will make the app more suitable for coaches or basket ball sporting analysts.
-   Added dynamic UI element to automatically uncheck whole career tick box when users update year slider bar or a team select checkbox. Previously, users have to uncheck the whole career tick box first and then continue to explore their desired year range or teams. The new feature makes the app more intuitive.
-   Improved multiple visualization elements for plots, such as axis labels, legend, display of year values, player's image rendering, etc. Particularly the first plot (Statistic metrics per game during the year range and at certain team) now shows more information on one single figure. Also, change format of year to numerical number without comma such as 1900, not 1,900.
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

-   We have received a couple of feedback from TAs and peer reviewers regarding the player name search bar. The team recognized the importance of searching convenience for app users, and we invested significant amount of hours to adopt the approximate string matching algorithm in the app. The current approach works better than previous version but there are still rooms for further improvements, such as showing drop down list of NBA players, so users can select or continue type in the name for search.

-   After adding the dynamic UI element to automatically uncheck the whole career tick box when the year slider bar or a team selection check box is triggered, we found it might still have another intuitive confusion for some users. After they click the whole career tick box, the year slider is frozen with showing the previously selected year range (not matching the intuition of the " whole career year range"). We need to figure out a better solution to try to cover all possible scenarios later.

-   During the week, we faced some problems with the API call to get the NBA Player data. It seems like the API has a limited calls per user, so we faced some unauthorized issue when calling the API several times when improving and testing the app. Furthermore, we implemented multiple step test cases such as inputting the player name, select statistics, filter year, select a team, these kind of tests were passed successfully on our local, but could not pass the test function on Github, therefore, we needed to come up with simple test. We expect that this come from the API problem, therefore, considering having the raw data instead of API is considered to be the major improvement we would like to solve later.

-   One thing to note is that because of we moved the `app.R` to the root directory for CI/CD, then we need to move `www` folder to the root directory as well because our code will read some information from `www` folder at the same directory level. We plan to revise a code so we can move `www` under `src` folder if it is more appropriate.

-   Furthermore, the team members were considering to apply more what we have learned from the 532 course in this app development, such as adding downloadable report, using reactive functions to avoid code duplication, etc. Since we encountered a few technical issues for testing and debug during the week although they were solved eventually, we will have to continuously improve the project after the course.
