library(readxl)
library(janitor)
library(tidyr)
library(ggplot2)

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

# GET DATA FROM SURVEYMONKEY
excel_path <- "School-Choice-For-CCNY-2023-11-30-4pm.xlsx"

# grabbing info from file
df <- read_excel(path = excel_path)

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

p <- ggplot(count_df_long, aes(x = `Aspect of K-12 School`, y = Count, fill = Response)) +
  geom_bar(stat = "identity") +
  labs(title = "Stacked Bar Chart",
       x = "Aspect of K-12 School",
       y = "Count") +
  theme_minimal()

print(p)

# shorten titles of columns
# remove second row??
# pie chart of column L: "During the past 12 months, how seriously have you considered enrolling your child/children in a different K-12 school in the US?"

# HYPOTHESIS
# parents who have already picked (v. not-picked-school parents) feel that various data/info is harder to find
# 