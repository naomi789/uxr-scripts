library(ggplot2)
library(likert) 

# FUNCTIONS: 
compare_histogram <- function(df, bar_x, comparing_on, title_graph, width, output_folder_name) {
  summary_df <- df %>%
    group_by_at(vars(!!bar_x, !!comparing_on)) %>%
    summarise(Count = n())
  
  p <- ggplot(summary_df, aes(x = !!as.symbol(bar_x), fill = !!as.symbol(comparing_on))) +
    geom_histogram(binwidth = width, position = "dodge") +
    labs(
      # title = title_graph,
         x = bar_x,
         y = "Count",
         fill = comparing_on) +
    theme_minimal()
  
  file_name <- paste0(as.character(title_graph), ".png")
  ggsave(file.path(output_folder_name, file_name), plot = p)
  
  return(p)
}

string_bar <- function(df, bar_x, comparing_on, title_graph, output_folder_name) {
  summary_df <- df %>%
    group_by_at(vars(!!bar_x, !!comparing_on)) %>%
    summarise(Count = n())
  
  p <- ggplot(summary_df, aes(x = !!as.symbol(bar_x), fill = !!as.symbol(comparing_on), y = Count)) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(
      # title = title_graph,
         x = bar_x,
         y = "Count",
         fill = comparing_on) +
    theme_minimal()
  
  file_name <- paste0(as.character(title_graph), ".png")
  ggsave(file.path(output_folder_name, file_name), plot = p)
  
  return(p)
}

stacked_bar <- function(df, bar_x, bar_fill, title_graph, output_folder_name) {
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
    labs(
      # title = title_graph,
         x = bar_x,
         y = "Count",
         fill = bar_fill) +
    theme_minimal()
  
  file_name <- paste0(as.character(title_graph), ".png")
  ggsave(file.path(output_folder_name, file_name), plot = p)
  
  return(p)
}


pie_chart <- function(df, bar_fill, title_graph, output_folder_name) {
  summary_df <- df %>%
    group_by_at(vars(!!bar_fill)) %>%
    summarise(Count = n()) %>%
    mutate(Percentage = (Count / sum(Count)) * 100)
  
  p <- ggplot(summary_df, aes(x = "", y = Percentage, fill = !!as.symbol(bar_fill))) +
    geom_bar(stat = "identity", width = 1) +
    coord_polar("y") +
    labs(
      # title = title_graph,
         fill = bar_fill) +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  file_name <- paste0(as.character(title_graph), ".png")
  ggsave(file.path(output_folder_name, file_name), plot = p)
  
  return(p)
}

# GRAB DATA
df <- read.csv("cleaned-data-1school/1school_no_unconfirmed-smartphones-combined-local-remote.csv")
output_folder_name = "visualizations-1school"

# SKIPPING 
# pie chart of UX
bar_fill = "ux_did_you_encounter_any_"
title_graph = "ux-issues-as-pie-chart"
p <- pie_chart(df, bar_fill, title_graph, output_folder_name)
p

# stacked bar graph UX and COMMUNITY
bar_x = "how_would_you_describe_th"
bar_fill = "ux_did_you_encounter_any_"
title_graph = "ux-issues-compared-between-community-types"
p <- stacked_bar(df, bar_x, bar_fill, title_graph, output_folder_name) 
p

# stacked bar graph UX and DEVICE
bar_x = "device"
bar_fill = "ux_did_you_encounter_any_"
title_graph = "ux-issues-compared-between-device-types"
p <- stacked_bar(df, bar_x, bar_fill, title_graph, output_folder_name) 
p

# stacked bar graph UX and SEARCHTYPE
bar_x = "search_type"
bar_fill = "ux_did_you_encounter_any_"
title_graph = "ux-issues-compared-between-search-types"
p <- stacked_bar(df, bar_x, bar_fill, title_graph, output_folder_name) 
p

# pie chart of EASE
bar_fill = "ease_how_easily_were_you_"
title_graph = "ease-as-pie-chart"
p <- pie_chart(df, bar_fill, title_graph, output_folder_name)
p

# stacked bar graph EASE and COMMUNITY
bar_x = "how_would_you_describe_th"
bar_fill = "ease_how_easily_were_you_"
title_graph = "ease-compared-between-community-types"
p <- stacked_bar(df, bar_x, bar_fill, title_graph, output_folder_name) 
p

# stacked bar graph EASE and DEVICE
bar_x = "device"
bar_fill = "ease_how_easily_were_you_"
title_graph = "ease-compared-between-device-types"
p <- stacked_bar(df, bar_x, bar_fill, title_graph, output_folder_name) 
p

# stacked bar graph EASE and SEARCHTYPE
bar_x = "search_type"
bar_fill = "ease_how_easily_were_you_"
title_graph = "ease-compared-between-search-type"
p <- stacked_bar(df, bar_x, bar_fill, title_graph, output_folder_name) 
p

# pie chart of ATTEMPTS
bar_fill = "attempts_how_many_searche"
title_graph = "attempts-as-pie-chart"
p <- pie_chart(df, bar_fill, title_graph, output_folder_name)
p

# stacked bar graph ATTEMPTS and COMMUNITY
bar_x = "how_would_you_describe_th"
bar_fill = "attempts_how_many_searche"
title_graph = "attempt-count-compared-between-community-types"
p <- stacked_bar(df, bar_x, bar_fill, title_graph, output_folder_name) 
p

# stacked bar graph ATTEMPTS and DEVICE
bar_x = "device"
bar_fill = "attempts_how_many_searche"
title_graph = "attempt-count-compared-between-device-types"
p <- stacked_bar(df, bar_x, bar_fill, title_graph, output_folder_name) 
p

# stacked bar graph ATTEMPTS and SEARCHTYPE
bar_x = "search_type"
bar_fill = "attempts_how_many_searche"
title_graph = "attempt-count-compared-between-search-types"
p <- stacked_bar(df, bar_x, bar_fill, title_graph, output_folder_name) 
p

# pie chart of SUCCESS
bar_fill = "success_how_confident_are"
title_graph = "success-as-pie-chart"
p <- pie_chart(df, bar_fill, title_graph, output_folder_name)
p

# stacked bar graph SUCCESS and COMMUNITY
bar_x = "how_would_you_describe_th"
bar_fill = "success_how_confident_are"
title_graph = "success-binary-compared-between-community-types"
p <- stacked_bar(df, bar_x, bar_fill, title_graph, output_folder_name) 
p

# stacked bar graph SUCCESS and DEVICE
bar_x = "device"
bar_fill = "success_how_confident_are"
title_graph = "success-binary-compared-between-device-types"
p <- stacked_bar(df, bar_x, bar_fill, title_graph, output_folder_name) 
p

# stacked bar graph SUCCESS and SEARCHTYPE
bar_x = "search_type"
bar_fill = "success_how_confident_are"
title_graph = "success-binary-compared-between-search-types"
p <- stacked_bar(df, bar_x, bar_fill, title_graph, output_folder_name) 
p

# pie chart of LOCATION
bar_fill = "if_you_set_the_location_f"
title_graph = "location-as-pie-chart"
p <- pie_chart(df, bar_fill, title_graph, output_folder_name)
p

# string graph LOCATION / COMMUNITY
bar_x = "if_you_set_the_location_f"
comparing_on = "how_would_you_describe_th"
title_graph = "initial-location-compared-between-community-type"
p <- string_bar(df, bar_x, comparing_on, title_graph, output_folder_name)
p

# string graph LOCATION / DEVICE
bar_x = "if_you_set_the_location_f"
comparing_on = "device"
title_graph = "initial-location-compared-between-device-type"
p <- string_bar(df, bar_x, comparing_on, title_graph, output_folder_name)
p

# graph LOCATION / SEARCHTYPE
bar_x = "if_you_set_the_location_f"
comparing_on = "search_type"
title_graph = "initial-location-compared-between-search-type"
p <- string_bar(df, bar_x, comparing_on, title_graph, output_folder_name)
p

# pie chart locations
bar_fill = "if_you_set_the_location_f"
title_graph = "initial-location-as-pie-chart"
p <- pie_chart(df, bar_fill, title_graph, output_folder_name)
p

