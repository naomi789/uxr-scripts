library(readr)
library(dplyr)
library(ggplot2)


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

# Function to get the first character as numeric
get_first_char_as_numeric <- function(x) {x
  as.numeric(substr(x, 1, 1))
}


# SET VARIABLES
agree_color_scale <- c("5 - Strongly agree" = "darkgreen", 
                       "4 - Agree" = "lightgreen", 
                       "3 - Somewhat agree" = "grey", 
                       "2 - Disagree" = "yellow", 
                       "1 - Strongly disagree" = "red")
likely_color_scale <- c("5 - Very likely" = "darkgreen", 
                        "4 - Likely" = "lightgreen", 
                        "3 - Somewhat likely" = "grey", 
                        "2 - Not likely" = "yellow", 
                        "1 - Not at all likely" = "red", 
)

# GET THE DATA
t_file <- "usertesting/treatment.csv"
t_df <- read_csv(t_file) %>% janitor::clean_names()

c_file <- "usertesting/control.csv"
c_df <- read_csv(c_file) %>% janitor::clean_names()

# combine them together
df <- bind_rows(
  mutate(c_df, study_version = control),
  mutate(t_df, study_version = treatment)) %>% 
  select(-control, -na, -treatment)

# PARTICIPANTS
# age
bar_x = "age"
title_graph = "comparing age across study type"
comparing_on = "study_version"
compare_histogram(df, bar_x, comparing_on, title_graph, 10)
# academic background
# household income
# industry
# freq of chatgpt use

# STUDY ANALYSIS
# cast to numbers
df <- df %>%
  mutate(
    "x1_accurate_info" = sapply(df$x1_allergies_the_information_provided_is_accurate, get_first_char_as_numeric),
    "x2_accurate_info" = sapply(df$x2_covid_flu_the_information_provided_is_accurate, get_first_char_as_numeric),
    "x3_accurate_info" = sapply(df$x3_new_job_the_information_provided_is_accurate, get_first_char_as_numeric)
  )
# average the score across ACCURACY
df$avg_accurate_info <- round(rowMeans(df[, c("x1_accurate_info", "x2_accurate_info", "x3_accurate_info")], na.rm = TRUE), 2)
  
# look at accuracy
bar_x = "study_version"
bar_fill = "x1_accurate_info"
title_graph = paste("across\"", bar_x, "\", the response to: \"", bar_fill, "\"", sep = " ")
stacked_bar(df, bar_x, bar_fill, title_graph)

bar_fill = "x2_accurate_info"
title_graph = paste("across\"", bar_x, "\", the response to: \"", bar_fill, "\"", sep = " ")
stacked_bar(df, bar_x, bar_fill, title_graph)

bar_fill = "x3_accurate_info"
title_graph = paste("across\"", bar_x, "\", the response to: \"", bar_fill, "\"", sep = " ")
stacked_bar(df, bar_x, bar_fill, title_graph)

# average the score across WO FURTHER RESEARCH
# cast to numbers
df <- df %>%
  mutate(
    "x1_without_further_research" = sapply(df$x1_allergies_make_decisions_without_further_research, get_first_char_as_numeric),
    "x2_without_further_research" = sapply(df$x2_covid_flu_make_decisions_without_further_research, get_first_char_as_numeric),
    "x3_without_further_research" = sapply(df$x3_new_job_make_decisions_without_further_research, get_first_char_as_numeric)
  )
# find the average
df$avg_without_further_research <- round(rowMeans(df[, c("x1_without_further_research", "x2_without_further_research", "x3_without_further_research")], na.rm = TRUE), 2)
# look at wo
bar_x = "study_version"
bar_fill = "x1_without_further_research"
title_graph = paste("across\"", bar_x, "\", the response to: \"", bar_fill, "\"", sep = " ")
stacked_bar(df, bar_x, bar_fill, title_graph)

bar_fill = "x2_without_further_research"
title_graph = paste("across\"", bar_x, "\", the response to: \"", bar_fill, "\"", sep = " ")
stacked_bar(df, bar_x, bar_fill, title_graph)

bar_fill = "x3_without_further_research"
title_graph = paste("across\"", bar_x, "\", the response to: \"", bar_fill, "\"", sep = " ")
stacked_bar(df, bar_x, bar_fill, title_graph)

