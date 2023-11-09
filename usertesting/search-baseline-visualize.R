library(readr)

# read in data
suburban_desktop_one <- read_csv("SUBURBAN-DESKTOP-1SCHOOL-QA-2023-11.csv")
suburban_mobile_one <- read_csv("SUBURBAN-MOBILE-1SCHOOL-QA-2023-11.csv")
rural_desktop_one <- read_csv("RURAL-DESKTOP-1SCHOOL-QA-2023-11.csv")
rural_mobile_one <- read_csv("RURAL-MOBILE-1SCHOOL-QA-2023-11.csv")

# PIE CHARTS
# pie chart (four strings) to the question
# `UX: Did you encounter any specific usability issues or challenges when trying to find this school?`
# TODO

# graph same question across all mobile v. all desktop
# TODO

# graph same question, but urban v. suburban v. rural
# TODO


# BAR GRAPH
# bar graph (strings: NA, 1, 2, 3, 4, 5+) to the question 
# `ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
# TODO

# graph same question across all mobile v. all desktop
# TODO

# graph same question, but urban v. suburban v. rural
# TODO


# STACKED BAR GRAPHS
# likert (stacked bar graph) to the question
# `SUCCESS: How confident are you that you found the correct school?`
# TODO

# graph same question across all mobile v. all desktop
# TODO

# graph same question, but urban v. suburban v. rural
# TODO

# bar graphs for `SUCCESS` split based on their answer to:
# `Next, please think of your youngest child who is currently in K-12 school. Does this school have more more than one campus?`
# TODO: 

# (
# `EASE: How easily were you able to find the correct school on GreatSchools?	
# )

# (
# `LOCATION: Some K-12 schools have multiple campuses (eg, a charter school might have a location in Mesa, AZ and another campus in Phoenix, AZ). How confident are you that you found the correct campus or location?``)
# )

# time, clicks, pages, unique_pages,
hist(df$`Time on task (seconds)`)
hist(df$`Clicks`)
hist(df$`Pages`)
hist(df$`Unique pages`)
