library(readr)
library(janitor)
library(tidyverse)
library(ggplot2)
library(likert) 


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
title_graph = "ux_did_you_encounter_any_"
p <- pie_chart(df, title_graph)
p

# graph same question across all mobile v. all desktop
facet_var = "device"
# graph same question, but urban v. suburban v. rural
facet_var = "how_would_you_describe_th"
# p <- pie_chart(df, title_graph, facet_var)
# p

# BAR GRAPH
# bar graph (strings: NA, 1, 2, 3, 4, 5+) to the question 
# `ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
# TODO

# graph same question across all mobile v. all desktop
facet_var = "device"
# graph same question, but urban v. suburban v. rural
facet_var = "how_would_you_describe_th"


# STACKED BAR GRAPHS
# likert (stacked bar graph) to the question
# EASE
bar_x = "how_would_you_describe_th"
bar_fill = "ease_how_easily_were_you_"
p <- stacked_bar(df, bar_x, bar_fill) 
p

# `SUCCESS: How confident are you that you found the correct school?`
# TODO
bar_x = "how_would_you_describe_th"
bar_fill = "success_how_confident_are"
p <- stacked_bar(df, bar_x, bar_fill) 
p

# graph same question across all mobile v. all desktop
facet_var = "device"
# TODO

# graph same question, but urban v. suburban v. rural
facet_var = "how_would_you_describe_th"
# TODO

# bar graphs for `SUCCESS` split based on their answer to:
# EASE
facet_var = "ease_how_easily_were_you_"
# LOCATION
facet_var = "location_some_k_12_school"

# time, clicks, pages, unique_pages,
hist(df$`Time on task (seconds)`)
hist(df$`Clicks`)
hist(df$`Pages`)
hist(df$`Unique pages`)

summarized_df <- function(df, title_graph, facet_var) {
  summarized_df <- df %>% 
    rename(title_graph = all_of(title_graph)) %>% 
    group_by(title_graph) %>% 
    summarize(count=n()) %>% 
    mutate(prop = count / sum(count) *100) %>%
    mutate(ypos = cumsum(prop)- 0.5*prop ) %>% 
    mutate(title_graph=substr(title_graph, 1, 20))
  return summarized_df
}

test <- function() {
  fake_df <- data.frame(
    Community = c("Rural", "Rural", "Rural", "Rural", "Suburban", "Suburban", "Suburban", "Suburban", "Urban", "Urban", "Urban", "Urban"),
    Ease = c("very easy", "easy", "neutral", "hard", "very easy", "very easy", "very easy", "very easy", "easy", "easy", "very easy", "very easy")
    # , Device = c("Computer", "Computer", "Mobile", "Mobile", "Device", "Device", "Computer", "Computer", "Computer", "Computer", "Mobile", "Computer")
    )
  
  # Print the created data frame
  print(fake_df)
  
  bar_x <- "Community"
  bar_fill <- "Ease"
  # attribute_c <- "Device"
  
  summary_df <- fake_df %>%
    group_by_at(vars(!!bar_x, !!bar_fill)) %>%
    summarise(Count = n())
  
  print(summary_df)
  
  ggplot(summary_df, aes(x = !!as.symbol(bar_x), y = Count, fill = as.factor(!!as.symbol(bar_fill)))) +
    geom_bar(stat = "identity") +
    labs(title = "Distribution of Ease in Communities",
         x = bar_x,
         y = "Count",
         fill = bar_fill) +
    theme_minimal()
}

stacked_bar <- function(df, bar_x, bar_fill) {
  bar_x = "how_would_you_describe_th"
  bar_fill = "ease_how_easily_were_you_"
  # following this tutorial: https://www.statology.org/stacked-barplot-in-r/
  df <- bind_rows(rural_df, suburban_df)
  
  summary_df <- df %>%
    group_by_at(vars(!!bar_x, !!bar_fill)) %>%
    summarise(Count = n())

  # make sure the bar graph is for strings; check if worried # print(summary_df)
  summary_df[[bar_fill]] <- as.character(summary_df[[bar_fill]])
  print(summary_df)
  
  ggplot(summary_df, aes(x = !!as.symbol(bar_x), y = Count, fill = as.factor(!!as.symbol(bar_fill)))) +
    geom_bar(stat = "identity") +
    labs(title = "Distribution of Ease in Communities",
         x = bar_x,
         y = "Count",
         fill = bar_fill) +
    theme_minimal()

  return(p)
}



pie_chart <- function(df, title_graph) {
  title_graph = "ux_did_you_encounter_any_"
  pie_df <- df %>% 
    rename(title_graph = all_of(title_graph)) %>% 
    group_by(title_graph) %>% 
    summarize(count=n()) %>% 
    mutate(prop = count / sum(count) *100) %>%
    mutate(ypos = cumsum(prop)- 0.5*prop ) %>% 
    mutate(title_graph=substr(title_graph, 1, 20))

  p <- ggplot(pie_df, aes(x="", y=prop)) +
    geom_bar(stat="identity", width=1, color="white") +
    coord_polar("y", start=0) +
    theme_void() + 
    theme(legend.position="none") +
    
    geom_text(aes(y = ypos, label = 
                    title_graph
                    ), color = "white", size=6) +
    scale_fill_brewer(palette="Set1")
#   + facet_wrap(~as.factor(facet_var))
  
    return(p)
}

