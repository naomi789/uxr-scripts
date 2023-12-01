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

plot_stacked <- function(df, key_col, count_responses, title_graph, preferred_order) {
  df <- tidyr::gather(df, key = key_col, value = "Value")
  df$key_col <- factor(df$key_col, levels = preferred_order)
  p <- ggplot(df, aes(x = key_col, fill = factor(Value))) +
    geom_bar(stat = "count") +
    labs(title = paste("Some parents (n =", count_responses, ") ", title_graph),
         x = key_col,
         y = "Count") +
    # scale_fill_manual(values = c("TRUE" = "lightgreen", "FALSE" = "grey")) +  # Customize colors
    theme_minimal()
  return(p)
}

one_stacked_graph <- function(df, col) {
  df_long <- df %>%
    select(col) %>%
    gather(key = "Category", value = "Response")
  p <- ggplot(df_long, aes(x = Category, fill = Response)) +
    geom_bar(position = "stack") +
    labs(title = col,
         x = "Category",
         y = "Count") +
    theme_minimal()
  return(p)
}


# GET DATA FROM SURVEYMONKEY
excel_path <- "School-Choice-For-CCNY-2023-11-30-4pm.xlsx"
df <- read_excel(path = excel_path)

# CLEANING DATA
# storing the sub-questions (and then intentionally removing them)
df_sub_questions <- slice(df, 1)
df <- df[-1, , drop = FALSE]
# let's drop everyone who said "1..." or "2..." for seriousness of search
column_name <- "During the past 12 months, how seriously have you considered enrolling your child/children in a different K-12 school in the US?"

df <- df %>%
  filter(!(str_trim(df[[column_name]]) %in% c("1 - I did not consider switching schools", 
                                              "2 - I considered switching, but decided not to switch, so I did not research schools", 
                                              "2 - I considered switching, but decided to not switch, so I did not research schools")))

# and drop everyone who said they didn't have K-12 kids
column_name="Are you a parent or guardian of school-aged (K-12) child/children currently living in the US?"
df <- df %>%
  filter(!(str_trim(df[[column_name]]) %in% c("No", 
                                              "No ")))

# PARTICIPANTS
# HOUSEHOLD INCOME; BG aka 59
# re-order the values
income_df <-df[,59, drop = FALSE]
custom_order <- c("$0 - 25,000/year", "$25,000 - 50,000/year", "$50,000 - 75,000/year", "$75,000-100,000/year", "$100,000/year or more", "I prefer not to disclose", "NA")
income_df$`What is your household’s range of income?` <- factor(df$`What is your household’s range of income?`, levels = custom_order)
# remove folks who did not share an answer
income_df <- income_df[rowSums(is.na(income_df)) != ncol(income_df), ]
# graph it
title_graph = "Household Income Distribution"
x_vals = "What is your household’s range of income?"
plot_histo(income_df, title_graph, x_vals)

# RACIAL IDENTITY; BH-BO aka 60-67
visualize_split_col <-df[,60:67, drop = FALSE]
split_col_name <- df_sub_questions[,60:67, drop = FALSE]
colnames(visualize_split_col) <- split_col_name
# drop folks who did not select a racial identity
visualize_split_col <- visualize_split_col[rowSums(is.na(visualize_split_col)) != ncol(visualize_split_col), ]

# then set variables and graph bar (white v. not-white; Black v. not-Black, etc)
key_col = "racial_identity"
preferred_order = c("American Indian or Alaska Native", "Asian", "Black or African American", 
                    "Middle Eastern or North African (e.g. Arab, Kurd, Persian. Turkish)", 
                    "Native Hawaiian and Pacific Islander", "White (e.g. German, Irish, English, American, Italian, Polish)", 
                    "I prefer not to answer", "My identity is not on the list")
title_graph = "reported their race"
plot_stacked(visualize_split_col, key_col, count_responses, title_graph, preferred_order)
# HOW TO: check number of options selected per respodent
# visualize_split_col$responded <-rowSums(!is.na(visualize_split_col))

# SOURCE; (SurveyMonkey or UT?)
# TODO: make pie chart

# KIDS' GRADES DURING SEARCH; X~AK aka 23-37
subset_df <- df[, 24:37, drop = FALSE]
subset_df$non_na_count <- rowSums(!is.na(subset_df))
subset_df$elem <- rowSums(!is.na(df[, 24:30])) > 0
subset_df$mid <- rowSums(!is.na(df[, 31:33])) > 0
subset_df$high <- rowSums(!is.na(df[, 34:37])) > 0
sum_reported_kids_grade <- sum(rowSums(subset_df[, c("elem", "mid", "high")]) > 0)
elem_mid_high_df <- subset_df %>% select("elem", "mid", "high")
preferred_order <- c("elem", "mid", "high")
key_col <- "Grade_Level"
plot_stacked(elem_mid_high_df, key_col, sum_reported_kids_grade, "reported kids' grade during search", preferred_order)


# searching of what types of schools? 
# completed v. not completed
# did not switch v. will switch v. already switch
# reason to switch
# SERIOUSNESS OF SWITCHING
seriousness_df <- df[,12]
one_stacked_graph(seriousness_df)
# planning to move? where? 
# feeder school


# important_to_succeed_at; BE aka 56
x_vals = "I believe the most important thing for my child/children to succeed at is:"
title_graph <- x_vals
plot_histo(df, title_graph, x_vals)

# skill_or_mindset_to_develop; BF aka 57
x_vals = "I believe the most skill or mindset for my child/children to develop is:"
title_graph <- x_vals
plot_histo(df, title_graph, x_vals)


# VISUALIZATION
# one giant set of stacked bar graphs for AM-BD (18 columns)
# just get relevant columns
subset_df <- df[, 39:56, drop = FALSE]
# Rename columns to first row; remove that row
subset_col_name <- df_sub_questions[, 39:56, drop = FALSE]
colnames(subset_df) <- subset_col_name
# drop folks who didn't answer any of these questions
subset_df <- subset_df[rowSums(is.na(subset_df)) != ncol(subset_df), ]
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
  print(one_stacked_graph(subset_df, col))
}
# find count of folks who reponded "did not consider" for any given question
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