library(readr)
library(janitor)
library(tidyverse)
library(ggplot2)
library(likert) 

# read in data
rural_mobile_district <- read_csv("cleaned-data/RURAL-MOBILE-DISTRICT-QA-2024-01.csv") %>% janitor::clean_names()
colnames(rural_mobile_district) <- lapply(names(rural_mobile_district), function(x) substr(x, start = 1, stop = 32))
rural_desktop_district <- read_csv("cleaned-data/RURAL-DESKTOP-DISTRICT-QA-2024-01.csv")  %>% 
  mutate(`remote_attempts_how_many_searches_or_queries_did_you_make_before_you_found_the_correct_district_for_example_if_you_typed_in_nyps_and_couldnt_find_the_district_but_typed_new_york_public_schools_and_found_it_then_select_2`
         =as.character(`remote_attempts_how_many_searches_or_queries_did_you_make_before_you_found_the_correct_district_for_example_if_you_typed_in_nyps_and_couldnt_find_the_district_but_typed_new_york_public_schools_and_found_it_then_select_2`)) %>% 
  janitor::clean_names()
colnames(rural_desktop_district) <- lapply(names(rural_desktop_district), function(x) substr(x, start = 1, stop = 32))
rural_df <- bind_rows(rural_desktop_district, rural_mobile_district)

suburban_mobile_district <- read_csv("cleaned-data/SUBURBAN-MOBILE-DISTRICT-QA-2024-01.csv") %>% janitor::clean_names()
colnames(suburban_mobile_district) <- lapply(names(suburban_mobile_district), function(x) substr(x, start = 1, stop = 32))
suburban_desktop_district <- read_csv("cleaned-data/SUBURBAN-DESKTOP-DISTRICT-QA-2024-01.csv") %>% janitor::clean_names()
colnames(suburban_desktop_district) <- lapply(names(suburban_desktop_district), function(x) substr(x, start = 1, stop = 32))
suburban_df <- bind_rows(suburban_mobile_district, suburban_desktop_district)

urban_mobile_district <- read_csv("cleaned-data/URBAN-MOBILE-DISTRICT-QA-2024-01.csv") %>% janitor::clean_names()
colnames(urban_mobile_district) <- lapply(names(urban_mobile_district), function(x) substr(x, start = 1, stop = 32))
urban_desktop_district <- read_csv("cleaned-data/URBAN-MOBILE-DISTRICT-QA-2024-01.csv") %>% janitor::clean_names()
colnames(urban_desktop_district) <- lapply(names(urban_desktop_district), function(x) substr(x, start = 1, stop = 32))
urban_df <- bind_rows(urban_mobile_district, urban_desktop_district)

# combine them into one big df
full_df <- bind_rows(suburban_df, urban_df, rural_df)

# TODO: remove before final run
# full_df <- full_df[!is.na(full_df$username),]

# stack remote and local questions
local_df <- full_df %>% select(-contains("remote_"))
# note that these answers are for local schools
local_df$search_type <- "local"
# write.csv(local_df, "local_df.csv")


# next, get all the remote ones AND the first 15 columns
remote_df <- full_df[c(1:15, 34:50)]
remote_df$search_type <- "remote"
# write.csv(remote_df, "remote_df.csv")

# if column name contains "remote_*" then rename it to "*"
remote_df <- remote_df %>%
  rename_with(~ sub("^remote_", "", .), starts_with("remote_"))
colnames(remote_df) <- lapply(names(remote_df), function(x) substr(x, start = 1, stop = 25))


# then shorten all local_df colnames to be the same length
colnames(local_df) <- lapply(names(local_df), function(x) substr(x, start = 1, stop = 25))
# write.csv(local_df, "local_df_but_shorter_names.csv")

# make sure all columns are char not double
local_df <- local_df %>% mutate(ease_how_easily_were_you_ = as.character(ease_how_easily_were_you_))
local_df <- local_df %>% mutate(loading_how_satisfied_wer = as.character(loading_how_satisfied_wer))
remote_df <- remote_df %>% mutate(ease_how_easily_were_you_ = as.character(ease_how_easily_were_you_))
remote_df <- remote_df %>% mutate(loading_how_satisfied_wer = as.character(loading_how_satisfied_wer))


# then combine the two columns into one df
df <- bind_rows(local_df, remote_df)

# last fix??? 
# if the "device" is "Smartphone (unconfirmed)" then rename it to "Smartphone"
df <- df %>% mutate(device = ifelse(device == "Smartphone (unconfirmed)", "Smartphone", device))

# and save it
write.csv(df, "no_unconfirmed-smartphones-combined-local-remote.csv")


# NUMERIC
# time, clicks, pages, unique_pages
# TIME ON TASK (IN SECONDS)
hist(df$`time_on_task_seconds`)
bar_x = "time_on_task_seconds"
comparing_on = "device"
title_graph = "Time on Task / Device"
p <- compare_histogram(df, bar_x, comparing_on, title_graph, 20)
p 

# NUM CLICKS
hist(df$`clicks`)
bar_x = "clicks"
comparing_on = "device"
title_graph = "Clicks / Device"
p <- compare_histogram(df, bar_x, comparing_on, title_graph, 5)
p 

# NUM PAGES
hist(df$`pages`)
bar_x = "pages"
comparing_on = "device"
title_graph = "Pages / Device"
p <- compare_histogram(df, bar_x, comparing_on, title_graph, 3)
p 

# NUM UNIQUE PAGES
hist(df$`unique_pages`)
bar_x = "unique_pages"
comparing_on = "device"
title_graph = "unique pages / device"
compare_histogram(df, bar_x, comparing_on, title_graph, 3)

# stacked bar graph UX and COMMUNITY
bar_x = "how_would_you_describe_th"
bar_fill = "ux_did_you_encounter_any_"
title_graph = "UX / Community"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# stacked bar graph UX and DEVICE
bar_x = "device"
bar_fill = "ux_did_you_encounter_any_"
title_graph = "UX / Device"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# stacked bar graph UX and SEARCHTYPE
bar_x = "search_type"
bar_fill = "ux_did_you_encounter_any_"
title_graph = "UX / SEARCH TYPE"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# stacked bar graph EASE and COMMUNITY
bar_x = "how_would_you_describe_th"
bar_fill = "ease_how_easily_were_you_"
title_graph = "EASE / COMMUNITY"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# stacked bar graph EASE and DEVICE
bar_x = "device"
bar_fill = "ease_how_easily_were_you_"
title_graph = "EASE / DEVICE"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# stacked bar graph EASE and SEARCHTYPE
bar_x = "search_type"
bar_fill = "ease_how_easily_were_you_"
title_graph = "EASE / SEARCH TYPE"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# stacked bar graph ATTEMPTS and COMMUNITY
bar_x = "how_would_you_describe_th"
bar_fill = "attempts_how_many_searche"
title_graph = "ATTEMPTS / COMMUNITY"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# stacked bar graph ATTEMPTS and DEVICE
bar_x = "device"
bar_fill = "attempts_how_many_searche"
title_graph = "ATTEMPTS / DEVICE"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# stacked bar graph ATTEMPTS and SEARCHTYPE
bar_x = "search_type"
bar_fill = "attempts_how_many_searche"
title_graph = "ATTEMPTS / SEARCH TYPE"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# stacked bar graph SUCCESS and COMMUNITY
bar_x = "how_would_you_describe_th"
bar_fill = "success_how_confident_are"
title_graph = "SUCCESS / COMMUNITY"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# stacked bar graph SUCCESS and DEVICE
bar_x = "device"
bar_fill = "success_how_confident_are"
title_graph = "SUCCESS / DEVICE"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p

# stacked bar graph SUCCESS and SEARCHTYPE
bar_x = "search_type"
bar_fill = "success_how_confident_are"
title_graph = "ATTEMPTS / SEARCH TYPE"
p <- stacked_bar(df, bar_x, bar_fill, title_graph) 
p


# string graph LOCATION / COMMUNITY
bar_x = "if_you_set_the_location_f"
comparing_on = "how_would_you_describe_th"
title_graph = "initially set location to"
p <- string_bar(df, bar_x, comparing_on, title_graph)
p

# string graph LOCATION / DEVICE
bar_x = "if_you_set_the_location_f"
comparing_on = "device"
title_graph = "initially set location to"
p <- string_bar(df, bar_x, comparing_on, title_graph)
p

# graph LOCATION / SEARCHTYPE
bar_x = "if_you_set_the_location_f"
comparing_on = "search_type"
title_graph = "LOCATION / SEARCH TYPE"
p <- string_bar(df, bar_x, comparing_on, title_graph)
p

# pie chart locations
bar_fill = "if_you_set_the_location_f"
title_graph = "set location as"
p <- pie_chart(df, bar_fill, title_graph)
p

# FUNCTIONS: 
compare_histogram <- function(df, bar_x, comparing_on, title_graph, width) {
  summary_df <- df %>%
    group_by_at(vars(!!bar_x, !!comparing_on)) %>%
    summarise(Count = n())
  
  p <- ggplot(summary_df, aes(x = !!as.symbol(bar_x), fill = !!as.symbol(comparing_on))) +
    geom_histogram(binwidth = width, position = "dodge") +
    labs(title = title_graph,
         x = bar_x,
         y = "Count",
         fill = comparing_on) +
    theme_minimal()
  
  return(p)
}

string_bar <- function(df, bar_x, comparing_on, title_graph) {
  summary_df <- df %>%
    group_by_at(vars(!!bar_x, !!comparing_on)) %>%
    summarise(Count = n())
  
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
  
  p <- ggplot(summary_df, aes(x = !!as.symbol(bar_x), y = Count, fill = !!as.symbol(bar_fill))) +
    geom_bar(stat = "identity") +
    labs(title = title_graph,
         x = bar_x,
         y = "Count",
         fill = bar_fill) +
    theme_minimal()
  
  return(p)
}


pie_chart <- function(df, bar_fill, title_graph) {
  summary_df <- df %>%
    group_by_at(vars(!!bar_fill)) %>%
    summarise(Count = n()) %>%
    mutate(Percentage = (Count / sum(Count)) * 100)
  
  p <- ggplot(summary_df, aes(x = "", y = Percentage, fill = !!as.symbol(bar_fill))) +
    geom_bar(stat = "identity", width = 1) +
    coord_polar("y") +
    labs(title = title_graph,
         fill = bar_fill) +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  return(p)
}
