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
district <- read.csv("cleaned-data-district/no_unconfirmed-smartphones-combined-both-local-and-remote.csv")
district_df <- district[c(1:7, 9:12, 15:17, 25:26)]
district_df$study_version <- "DISTRICT"
# print(colnames(district_df))
# print(length(colnames(district_df)))



oneschool <- read.csv("cleaned-data-1school/1school_no_unconfirmed-smartphones-combined-local-remote.csv")
oneschool_df <- oneschool[c(1:7, 9, 12:14, 24:26, 35, 36)]
oneschool_df$study_version <- "1SCHOOL"
# print(colnames(oneschool_df))
# print(length(colnames(oneschool_df)))


multischool <- read.csv("cleaned-data-multischool/multischool_no_unconfirmed-smartphones-combined-local-remote.csv")
multischool_df <- multischool[c(1:7, 9, 12:14, 22:23, 26, 28, 31:34)]
multischool_df$study_version <- "MULTISCHOOL"
# print(colnames(multischool_df))
# print(length(colnames(multischool_df)))



# MERGE RELEVANT COLUMNS 
merged_df <- bind_rows(oneschool_df, multischool_df, district_df)
print(length(colnames(merged_df)))
file_name <- "all-data-kinda-clean-ish.csv"
write.csv(merged_df, file_name, row.names=FALSE)

# PREP TO MAKE VISUALIZATIONS
output_folder_name = "visualizations-district"

# THINGS TO VISUALIZE
# bar graph of overall success (just district)
bar_x = "were_you_able_to_find_the"
title_graph = "1-search-success"
just_district_df <- merged_df[merged_df$study_version %in% c("DISTRICT"), ]
pie_chart(just_district_df, bar_x, title_graph, output_folder_name)

# bar graph of overall success (just 1 school)
bar_x = "success_how_confident_are"
title_graph = "1-search-success"
just_1school_df <- merged_df[merged_df$study_version %in% c("1SCHOOL"), ]
pie_chart(just_1school_df, bar_x, title_graph, output_folder_name)

# bar graph of accuracy (just multischool)
bar_x = "accuracy_how_confident_ar"
title_graph = "multi-school-search-accuracy"
just_multischool_df <- merged_df[merged_df$study_version == "MULTISCHOOL", ]
pie_chart(just_multischool_df, bar_x, title_graph, output_folder_name)

# bar graph of number of attempts
bar_x = "attempts_how_many_searche"
title_graph = "overall-count-attempts"
pie_chart(merged_df, bar_x, title_graph, output_folder_name)

# bar graph of ease
bar_x = "ease_how_easily_were_you_"
title_graph = "overall-ease"
pie_chart(merged_df, bar_x, title_graph, output_folder_name)

# bar graph of usability issues
bar_x = "ux_did_you_encounter_any_"
title_graph = "overall-UX"
pie_chart(merged_df, bar_x, title_graph, output_folder_name)
