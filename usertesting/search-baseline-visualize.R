library(readr)
library(janitor)
library(tidyverse)
library(ggplot2)


# read in data
rural_desktop_one <- read_csv("RURAL-DESKTOP-1SCHOOL-QA-2023-11.csv")  %>% 
    mutate(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
         =as.character(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`), 
         `ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
         =as.character(`ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`)) %>% 
  janitor::clean_names()
colnames(rural_desktop_one) <- lapply(names(rural_desktop_one), function(x) substr(x, start = 1, stop = 25))

rural_mobile_one <- read_csv("RURAL-MOBILE-1SCHOOL-QA-2023-11.csv") %>% 
  mutate(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
         =as.character(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`), 
         `ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
         =as.character(`ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`)) %>% 
  janitor::clean_names()
colnames(rural_mobile_one) <- lapply(names(rural_mobile_one), function(x) substr(x, start = 1, stop = 25))

suburban_mobile_one <- read_csv("SUBURBAN-MOBILE-1SCHOOL-QA-2023-11.csv") %>% 
  mutate(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
         =as.character(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`), 
         `ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
         =as.character(`ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`)) %>% 
  janitor::clean_names()
colnames(suburban_mobile_one) <- lapply(names(suburban_mobile_one), function(x) substr(x, start = 1, stop = 25))

suburban_desktop_one <- read_csv("SUBURBAN-DESKTOP-1SCHOOL-QA-2023-11.csv") %>% 
  mutate(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
         =as.character(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`), 
         `ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
         =as.character(`ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`)) %>% 
  janitor::clean_names()
colnames(suburban_desktop_one) <- lapply(names(suburban_desktop_one), function(x) substr(x, start = 1, stop = 25))

# combine them into one big df
rural_df <- bind_rows(rural_desktop_one, rural_mobile_one)
suburban_df <- bind_rows(suburban_mobile_one, suburban_desktop_one)
df <- bind_rows(rural_df, suburban_df)


# PIE CHARTS
# looking at responses to 
var_string = "ux_did_you_encounter_any_"
p <- pie_chart(df, var_string)
p

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
# EASE
# LOCATION

# time, clicks, pages, unique_pages,
hist(df$`Time on task (seconds)`)
hist(df$`Clicks`)
hist(df$`Pages`)
hist(df$`Unique pages`)



# , var_split, 'COMMUNITY'
pie_chart <- function(df, var_string) {
  df <- df %>% 
    rename(var_graph = all_of(var_string)) %>% 
    group_by(var_graph) %>% 
    summarize(count=n()) %>% 
    mutate(prop = count / sum(count) *100) %>%
    mutate(ypos = cumsum(prop)- 0.5*prop ) %>% 
    mutate(var_graph=substr(var_graph, 1, 20))

  p <- ggplot(df, aes(x="", y=prop)) +
    geom_bar(stat="identity", width=1, color="white") +
    coord_polar("y", start=0) +
    theme_void() + 
    theme(legend.position="none") +
    
    geom_text(aes(y = ypos, label = 
                    var_graph
                    ), color = "white", size=6) +
    scale_fill_brewer(palette="Set1")
  # + facet_wrap(var_split)
  
    return(p)
}

