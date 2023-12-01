library(readxl)
library(janitor)
library(tidyr)
library(ggplot2)
library(stringr)

# FUNCTIONS
many_bars_stacked <- function(subset_df, graph_title, name_x_axis, name_y_axis, name_key) {
  subset_df_long <- subset_df %>%
    gather(key = "Category", value = "Response")
  
  # Plotting stacked bar chart
  p <- ggplot(subset_df_long, aes(x = Category, fill = Response)) +
    geom_bar(position = "stack") +
    labs(title = graph_title,
         x = name_x_axis,
         y = name_y_axis, 
         fill = name_key) +
    theme_minimal()
  
  return(p)
}

plot_histo <- function(df, title_graph, x_vals) {
  ggplot(df, aes(x = !!rlang::sym(x_vals))) +
    geom_bar() +
    labs(title = title_graph,
         x = x_vals,
         y = "Count") +
    theme_minimal() + 
    theme(axis.text.x = element_text(angle = 20, hjust = 1))
}

# GET DATA FROM SURVEYMONKEY
excel_path <- "School-Choice-For-CCNY-2023-11-30-4pm.xlsx"
df <- read_excel(path = excel_path)

# CLEANING DATA
# if I need to see the sub-questions, they're missing bc I intentially removed them
df <- df[-1, , drop = FALSE]
# let's drop everyone who said "1..." or "2..." for seriousness of search
column_name="During the past 12 months, how seriously have you considered enrolling your child/children in a different K-12 school in the US?"
df <- df %>%
  filter(!(column_name == "1 - I did not consider switching schools" | 
             column_name == "2 - I considered switching, but decided not to switch, so I did not research schools"))
# and drop everyone who said they didn't have K-12 kids
column_name="Are you a parent or guardian of school-aged (K-12) child/children currently living in the US?"
df <- df %>%
  filter(!(column_name == "No"))

# PARTICIPANTS
# household income (self-reported); BG aka 59
# re-order the values
custom_order <- c("$0 - 25,000/year", "$25,000 - 50,000/year", "$50,000 - 75,000/year", "$75,000-100,000/year", "$100,000/year or more", "I prefer not to disclose", "NA")
df$`What is your household’s range of income?` <- factor(df$`What is your household’s range of income?`, levels = custom_order)
title_graph = "Household Income Distribution"
x_vals = "What is your household’s range of income?"
plot_histo(df, title_graph, x_vals)

# racial identity (self-reported); BH-BO aka 60-67
# source (SurveyMonkey or UT?)
# important_to_succeed_at; BE aka 56
x_vals = "I believe the most important thing for my child/children to succeed at is:"
title_graph <- x_vals
plot_histo(df, title_graph, x_vals)

# skill_or_mindset_to_develop; BF aka 57
x_vals = "I believe the most skill or mindset for my child/children to develop is:"
title_graph <- x_vals
plot_histo(df, title_graph, x_vals)

# grades of kid(s) (enrolled in:not enrolled; K-5; 6-8; 9-12)
# searching of what types of schools? 
# completed v. not completed
# did not switch v. will switch v. already switch
# reason to switch
# seriousness of switching
# planning to move? where? 
# feeder school

# VISUALIZATION
# one giant set of stacked bar graphs for AM-BD (18 columns)
# just get relevant columns
subset_df <- df[, 39:56, drop = FALSE]
# Rename columns to first row; remove that row
colnames(subset_df) <- subset_df[1, ]
subset_df <- subset_df[-1, ]
subset_df <- subset_df[complete.cases(subset_df), ]
# Check if there are any NA values in subset_df & print
# has_na <- any(is.na(subset_df))
# print(has_na)
graph_title = "Ease/difficulty finding info on aspects of K-12 school"
name_y_axis = "Count"
name_key = "Difficulty finding info"
name_x_axis = "Aspects of K-12 school"
many_bars_stacked(subset_df, graph_title, name_x_axis, name_y_axis, name_key)
# making custom graph for each column
for (col in colnames(subset_df)) {
  subset_df_long <- subset_df %>%
    select(col) %>%
    gather(key = "Category", value = "Response")
  p <- ggplot(subset_df_long, aes(x = Category, fill = Response)) +
    geom_bar(position = "stack") +
    labs(title = col,
         x = "Category",
         y = "Count") +
    theme_minimal()
  print(p)
}

count_df <- data.frame(column_name = character(0), "NA - Did not consider this" = integer(0), "Other Values" = integer(0), stringsAsFactors = FALSE)

# Loop through each column in the original data frame
for (column_to_analyze in colnames(subset_df)) {
  # Count occurrences
  counts <- table(subset_df[[column_to_analyze]])
  
  # Extract counts for "NA - Did not consider this" and other values
  na_count <- counts["NA - Did not consider this"]
  other_count <- sum(counts[setdiff(names(counts), "NA - Did not consider this")])
  
  # Append the results to the count_df
  count_df <- rbind(count_df, c(column_name = column_to_analyze, "NA - Did not consider this" = na_count, "Other Values" = other_count))
}
# now graph considered/not considered
colnames(count_df) <- c("Aspect of K-12 School", "Did not consider", "Other")
count_df_long <- tidyr::gather(count_df, key = "Response", value = "Count", -"Aspect of K-12 School")
count_df_long$Count <- as.numeric(count_df_long$Count)
count_df_long$`Aspect of K-12 School` <- factor(count_df_long$`Aspect of K-12 School`, levels = unique(count_df_long$`Aspect of K-12 School`))
count_df_long$label <- substr(count_df_long$`Aspect of K-12 School`, 1, 65)

p <- ggplot(count_df_long, aes(x = `Aspect of K-12 School`, y = Count, fill = Response)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = ifelse(Response == "Did not consider", Count, "")),
            position = position_stack(vjust = 0.5), color = "white") +  # Add labels of "Count" for "Did not consider"
  geom_text(aes(label = ifelse(Response == "Other", Count, "")),
            position = position_stack(vjust = 0.95), color = "white") +  # Add labels for "Other"
  geom_text(aes(label = ifelse(Response == "Other", label, "")),
            position = position_stack(vjust = 0.02), color = "black", size = 3, angle = 90, hjust = 0) +
  
  
  labs(title = "Stacked Bar Chart",
       x = "Aspect of K-12 School",
       y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_blank())  # Remove x-axis labels
print(p)

# shorten titles of columns
# remove second row??
# pie chart of column L: "During the past 12 months, how seriously have you considered enrolling your child/children in a different K-12 school in the US?"

# HYPOTHESIS
# parents who have already picked (v. not-picked-school parents) feel that various data/info is harder to find
# 