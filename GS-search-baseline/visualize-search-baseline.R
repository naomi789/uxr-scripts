library(ggplot2)
library(likert) 

# FUNCTIONS: 
compare_histogram <- function(df, bar_x, comparing_on, title_graph, width, output_folder) {
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
  ggsave(file.path(output_folder, file_name), plot = p)
  
  return(p)
}

string_bar <- function(df, bar_x, comparing_on, title_graph, output_folder) {
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
  ggsave(file.path(output_folder, file_name), plot = p)
  
  return(p)
}

stacked_bar <- function(df, bar_x, bar_fill, title_graph, output_folder) {
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
  ggsave(file.path(output_folder, file_name), plot = p)
  
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
district <- read.csv("cleaned-data-district/no_unconfirmed-smartphones-combined-both-local-and-remote.csv") %>% 
  mutate(`username`
         =as.character(`username`), 
         `test_id_number`
         =as.character(`test_id_number`)) %>% 
  janitor::clean_names()
district_df <- district[c(1:12, 15:18, 21, 23, 26:27)]
district_df$study_version <- "district"

oneschool <- read.csv("cleaned-data-1school/1school_no_unconfirmed-smartphones-combined-local-remote.csv") %>% 
  mutate(`username`
         =as.character(`username`), 
         `test_id_number`
         =as.character(`test_id_number`)) %>% 
  janitor::clean_names()
oneschool_df <- oneschool[c(1:12, 23:27, 35:37)]
oneschool_dff$study_version <- "1SCHOOL"
multischool <- read.csv("cleaned-data-multischool/multischool_no_unconfirmed-smartphones-combined-local-remote.csv") %>% 
  mutate(`username`
         =as.character(`username`), 
         `test_id_number`
         =as.character(`test_id_number`)) %>% 
  janitor::clean_names()
multischool_df <- multischool[c(1:16, 21:24, 26, 28, 30:34)]

# MERGE RELEVANT COLUMNS 
merged_df <- bind_cols(oneschool_df, multischool_df, district_df)
print(length(colnames(merged_df)))
file_name <- "all-data-butstill-messy.csv"
write.csv(merged_df, file_name, row.names=FALSE)
output_folder_name = "visualizations-district"
