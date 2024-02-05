library(ggplot2)
library(likert) 

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
