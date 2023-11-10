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

# NUMERIC
# time, clicks, pages, unique_pages
# TIME ON TASK (IN SECONDS)
hist(df$`time_on_task_seconds`)
bar_x = "time_on_task_seconds"
comparing_on = "device"
title_graph = "Time on Task / Device"
p <- compare_histogram(df, bar_x, comparing_on, title_graph)
p 

# NUM CLICKS
hist(df$`clicks`)
bar_x = "clicks"
comparing_on = "device"
title_graph = "Clicks / Device"
p <- compare_histogram(df, bar_x, comparing_on, title_graph)
p 

# NUM PAGES
hist(df$`pages`)
bar_x = "pages"
comparing_on = "device"
title_graph = "Pages / Device"
p <- compare_histogram(df, bar_x, comparing_on, title_graph)
p 

# NUM UNIQUE PAGES
hist(df$`unique_pages`)
bar_x = "unique_pages"
comparing_on = "device"
title_graph = "unique pages / device"
compare_histogram(df, bar_x, comparing_on, title_graph)

# STACKED BAR GRAPHS
# graph UX and COMMUNITY
bar_x = "how_would_you_describe_th"
bar_fill = "ux_did_you_encounter_any_"
title_graph = "UX / Community"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# graph UX and DEVICE
bar_x = "device"
bar_fill = "ux_did_you_encounter_any_"
title_graph = "UX / Device"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# graph EASE and COMMUNITY
bar_x = "how_would_you_describe_th"
bar_fill = "ease_how_easily_were_you_"
title_graph = "EASE / COMMUNITY"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# graph EASE and DEVICE
bar_x = "device"
bar_fill = "ease_how_easily_were_you_"
title_graph = "EASE / DEVICE"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# graph ATTEMPTS and COMMUNITY
bar_x = "device"
bar_fill = "attempts_how_many_searche"
title_graph = "ATTEMPTS / COMMUNITY"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# graph ATTEMPTS and DEVICE
bar_x = "device"
bar_fill = "attempts_how_many_searche"
title_graph = "ATTEMPTS / DEVICE"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# graph SUCCESS and COMMUNITY
bar_x = "how_would_you_describe_th"
bar_fill = "success_how_confident_are"
title_graph = "SUCCESS / COMMUNITY"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# graph SUCCESS and DEVICE
bar_x = "device"
bar_fill = "success_how_confident_are"
title_graph = "SUCCESS / DEVICE"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# graph LOCATION / COMMUNITY
bar_x = "if_you_set_the_location_f"
comparing_on = "how_would_you_describe_th"
title_graph = "initially set location to"
p <- string_bar(df, bar_x, comparing_on, title_graph)
p

# graph LOCATION / DEVICE
bar_x = "if_you_set_the_location_f"
comparing_on = "device"
title_graph = "initially set location to"
p <- string_bar(df, bar_x, comparing_on, title_graph)
p

# FUNCTIONS: 
compare_histogram <- function(df, bar_x, comparing_on, title_graph) {
  summary_df <- df %>%
    group_by_at(vars(!!bar_x, !!comparing_on)) %>%
    summarise(Count = n())
  print(summary_df)
  
  p <- ggplot(summary_df, aes(x = !!as.symbol(bar_x), fill = !!as.symbol(comparing_on))) +
    geom_histogram(binwidth = 5, position = "dodge") +
    labs(title = title_graph,
         x = bar_x,
         y = "Count",
         fill = comparing_on) +
    theme_minimal()
  p
  return(p)
}

string_bar <- function(df, bar_x, comparing_on, title_graph) {
  summary_df <- df %>%
    group_by_at(vars(!!bar_x, !!comparing_on)) %>%
    summarise(Count = n())
  print(summary_df)
  
  p <- ggplot(summary_df, aes(x = !!as.symbol(bar_x), fill = !!as.symbol(comparing_on), y = Count)) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(title = title_graph,
         x = bar_x,
         y = "Count",
         fill = comparing_on) +
    theme_minimal()
  
  return(p)
}

stacked_bar <- function(df, bar_x, bar_fill, title_graph) {
  # following this tutorial: https://www.statology.org/stacked-barplot-in-r/
  summary_df <- df %>%
    group_by_at(vars(!!bar_x, !!bar_fill)) %>%
    summarise(Count = n())

  # make sure the bar graph is for strings; check if worried # print(summary_df)
  summary_df[[bar_fill]] <- as.character(summary_df[[bar_fill]])  
  # and if the strings are too long, cut them shorter
  summary_df[[bar_fill]] <- substr(summary_df[[bar_fill]], 1, 10)
  
  p <- ggplot(summary_df, aes(x = !!as.symbol(bar_x), y = Count, fill = device)) +
    geom_bar(stat = "identity") +
    labs(title = title_graph,
         x = bar_x,
         y = "Count",
         fill = bar_fill) +
    theme_minimal()

  return(p)
}
