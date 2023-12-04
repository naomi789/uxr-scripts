library(readxl)
library(janitor)
library(tidyr)
library(ggplot2)
library(stringr)
library(viridis)
library(dplyr)


# FUNCTIONS
many_bars_stacked <- function(subset_df, title_graph, name_x_axis, name_y_axis, name_for_key) {
  subset_df_long <- subset_df %>%
    gather(key = "Category", value = "Response")
  # Plotting stacked bar chart
  p <- ggplot(subset_df_long, aes(x = Category, fill = Response)) +
    geom_bar(position = "stack") +
    geom_text(
      # aes(label = ifelse(Value == "TRUE", str_to_upper(as.character(key_col)), Value)),
      aes(label = paste("n =", after_stat(count))),
      stat = "count",
      position = position_stack(vjust = 0.5), angle = 90, # adjust the vertical position of labels
      size = 3 # adjust the size of labels
    ) +
    labs(title = title_graph,
         x = name_x_axis,
         y = name_y_axis, 
         fill = name_for_key) +
    theme_minimal()
  
  return(p)
}


one_stacked_bar <- function(df, select_on) {
  df_long <- df %>%
    select(select_on) %>%
    gather(key = "Category", value = "Response")
  p <- ggplot(df_long, aes(x = Category, fill = Response)) +
    geom_bar(position = "stack") +
    geom_text(
      aes(label = Response),
      # aes(label = paste("n =", after_stat(count))),
      stat = "count",
      position = position_stack(vjust = 0.5), # adjust the vertical position of labels
      size = 3 # adjust the size of labels
    ) +
    labs(title = select_on,
         x = "Category",
         y = "Count") +
    theme_minimal()
  return(p)
}
# 09_The most important factor of my school search was.png
show_missing_stacked_graph <- function(df, select_on, alphabetized_values) {
  summary_table <- table(df[[select_on]])
  summary_df <- as.data.frame(table(factor(df[[select_on]], levels = alphabetized_values)))
  
  # nice_colors <- viridis_pal()(20)
  p <- ggplot(summary_df, aes(x = "", y = Freq, fill = factor(str_sub(Var1, end = 20)))) +
    geom_bar(stat = "identity") +
    geom_text(
      aes(label = Var1),
      # aes(label = paste("n =", Freq)),
      # aes(label = Freq),
      stat = "identity",  # Use stat = "identity" when supplying labels directly
      position = position_stack(vjust = 0.5), # adjust the vertical position of labels
      size = 3 # adjust the size of labels
    ) +
    labs(title = "Factor Counts",
         x = "",
         # fill= "",
         y = "Count") +
    # scale_fill_manual(values = nice_colors) +
    theme_minimal() +
    theme(legend.position="top")  

  return(p)
}

# cleaning data for AM-BD (18 columns)
considered_v_did_not_consider <- function(subset_df) {
  # find count of folks who responded "did not consider" for any given question
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
    geom_text(aes(label = ifelse(Response == "Other", label, "Considered")),
              position = position_stack(vjust = 0.02), color = "black", size = 3, angle = 90, hjust = 0) +
    
    
    labs(title = "Stacked Bar Chart",
         x = "Aspect of K-12 School",
         y = "Count") +
    theme_minimal() +
    theme(axis.text.x = element_blank())  # Remove x-axis labels
  return(p)
}


# simple histogram
plot_histo <- function(df, title_graph, x_vals) {
  p <- ggplot(df, aes(x = !!rlang::sym(x_vals))) +
    geom_bar() +
    geom_text(
      # aes(label = after_stat(count)),
      # aes(label = Value)),
      aes(label = paste("n =", after_stat(count))),
      stat = "count",
      color = "white",
      position = position_stack(vjust = 0.5), # adjust the vertical position of labels
      size = 3 # adjust the size of labels
    ) +
    labs(title = title_graph,
         x = x_vals,
         y = "Count") +
    theme_minimal() + 
    theme(axis.text.x = element_text(angle = 20, hjust = 1))
  return(p)
}


# convert multi-col data to TRUE/FALSE and then visualize
plot_stacked <- function(df, key_col, count_responses, title_graph, preferred_order) {
  df <- tidyr::gather(df, key = key_col, value = "Value")
  df$key_col <- factor(df$key_col, levels = preferred_order)
  
  p <- ggplot(df, aes(x = key_col, fill = factor(Value))) +
    geom_bar(stat = "count") +
    geom_text(
      # aes(label = ifelse(Value == "TRUE", str_to_upper(as.character(key_col)), Value)),
      aes(label = paste("n =", after_stat(count))),
      stat = "count",
      position = position_stack(vjust = 0.5), angle = 90, # adjust the vertical position of labels
      size = 3 # adjust the size of labels
    ) +
    labs(title = paste("Some parents (n =", count_responses, ") ", title_graph),
         x = key_col,
         y = "Count") +
    theme_minimal()
  
  return(p)
}


# GET DATA FROM SURVEYMONKEY
clean_df <- read_excel(path = "School-Choice-For-CCNY-2023-12-03-10pm.xlsx")

# CLEANING DATA
# storing the sub-questions (and then intentionally removing them)
df_sub_questions <- slice(clean_df, 1)
clean_df <- clean_df[-1, , drop = FALSE]

#REMOVING BAD APPLES
# drop everyone who said they didn't have K-12 kids
column_name="Are you a parent or guardian of school-aged (K-12) child/children currently living in the US?"
clean_df <- clean_df %>%
  filter(!(str_trim(clean_df[[column_name]]) %in% c("No", 
                                              "No ")))
# or didn't answer (if parent)
clean_df <- clean_df[!is.na(clean_df[[column_name]]), ]
# check
print(unique(clean_df[column_name]))

# drop folks who weren't serious about switching
column_name <- "During the past 12 months, how seriously have you considered enrolling your child/children in a different K-12 school in the US?"
# select_on = "During the past 12 months, how seriously have you considered enrolling your child/children in a different K-12 school in the US?"
# one_stacked_bar(clean_df, select_on)
clean_df <- clean_df %>%
  filter(!(str_trim(clean_df[[column_name]]) %in% c("1 - I did not consider switching schools", 
                                                    "2 - I considered switching, but decided not to switch, so I did not research schools", 
                                                    "2 - I considered switching, but decided to not switch, so I did not research schools", 
                                                    "NA - I do not have kids in K-12 schools in the US")))

# or didn't answer (serious about switching)
clean_df <- clean_df[!is.na(clean_df[[column_name]]), ]
# check
# print(unique(clean_df[column_name]))


# SET DF TO CLEAN DATA
df <- clean_df

# PARTICIPANTS
# SERIOUSNESS OF SWITCHING
select_on = "During the past 12 months, how seriously have you considered enrolling your child/children in a different K-12 school in the US?"
one_stacked_bar(df, select_on)


# REASON TO BEGIN SWITCH
select_on = "Which best describes why you began researching K-12 schools for your child to attend?"
title_graph = "Reasons to start school search"
plot_histo(df, title_graph, select_on)

# PLANNING TO MOVE? 
select_on = "During your K-12 school search, were you planning on moving?"
moving_df <- df[,15]
moving_df <- moving_df[rowSums(is.na(moving_df)) != ncol(moving_df), ]
title_graph = "If moving was reason for search: they are moving..."
plot_histo(moving_df, title_graph, select_on)

# CHILD GRADUATING/READY TO START ES, MS, HS
grad_df <- df[,16]
select_on = 'In many school districts, most graduates of one school all go to an assigned "feeder" school together (eg, elementary students are "fed" into the same middle school, middle school students are "fed" into the same high school) unless parents choose otherwise. Will your child be attending their assigned feeder school?'
grad_df <- grad_df[rowSums(is.na(grad_df)) != ncol(grad_df), ]
title_graph = "If graduating was reason for search:their kid is..."
plot_histo(grad_df, title_graph, select_on)

# CURRENT PHASE IN SCHOOL CHOICE JOURNEY
# "Where are you at with your K-12 school search?"
# current_phase_df <- df[,17]
# current_phase_df <- current_phase_df[rowSums(is.na(current_phase_df)) != ncol(current_phase_df), ]
select_on = "Where are you at with your K-12 school search?"
title_graph = "Current phase in school search journey"
plot_histo(df, title_graph, select_on)

# SCHOOL TYPE
# What kind of K-12 school were you considering? Select all that apply.
type_school_df <- df[,18:23]
correct_school_types <- df_sub_questions[,18:23, drop = FALSE]
colnames(type_school_df) <- correct_school_types
name_x_axis = "What kind of K-12 school were you considering? Select all that apply."
name_y_axis = "Count"
title_graph = "Did/did not consider schools of these types"
name_for_key = "yes or no"
many_bars_stacked(type_school_df, title_graph, name_x_axis, name_y_axis, name_for_key)
  

# KIDS' GRADES DURING SEARCH; X~AK aka 23-37
grade_level_df <- df[, 24:37, drop = FALSE]
colnames(grade_level_df) <- df_sub_questions[, 24:37, drop = FALSE]

# prep for school level graphing
grade_level_df$non_na_count <- rowSums(!is.na(grade_level_df))
grade_level_df$elem <- rowSums(!is.na(df[, 24:30])) > 0
grade_level_df$mid <- rowSums(!is.na(df[, 31:33])) > 0
grade_level_df$high <- rowSums(!is.na(df[, 34:37])) > 0
# set up function call
elem_mid_high_df <- grade_level_df %>% select("elem", "mid", "high")
key_col <- "Grade_Level"
sum_reported_kids_grade <- sum(rowSums(grade_level_df[, c("elem", "mid", "high")]) > 0)
title_graph <- "students' grade level during search"
preferred_order <- c("elem", "mid", "high")
# df <- grade_level_df %>% select("elem", "mid", "high")
# key_col <- "Grade_Level"
# count_responses <- sum(rowSums(grade_level_df[, c("elem", "mid", "high")]) > 0)
# title_graph <- "reported kids' grade during search"
# preferred_order <- c("elem", "mid", "high")
plot_stacked(elem_mid_high_df, key_col, sum_reported_kids_grade, title_graph, preferred_order)

preferred_order <- c("Not yet enrolled (pre-K, day care, etc)", "Kingergarten", "1", 
                     "2", "3", "4", "5", "6",  "7", "8", "9", "10", "11",  "12")
plot_stacked(grade_level_df[,1:14], key_col, sum_reported_kids_grade, title_graph, preferred_order)


# PARENTS' MOST IMPORTANT FACTOR OF MY SEARCH; AL aka
# "The most important factor of my school search was"
important_search_factor <- df[,38]
important_search_factor <- important_search_factor[rowSums(is.na(important_search_factor)) != ncol(important_search_factor), ]
select_on = "The most important factor of my school search was"
title_graph = "Most important factor of my school search was:"
# plot_histo(important_search_factor, title_graph, select_on)
alphabetized_values <- sort(unlist(df_sub_questions[, 39:56, drop = FALSE][1,]))
show_missing_stacked_graph(important_search_factor, select_on, alphabetized_values)
# then step back from narrow to broad categories
broad_df <- important_search_factor %>%
  mutate(broad_categories = str_extract(important_search_factor[[select_on]], "\\w+"))
colnames(broad_df) <- c("OG stuff", select_on)
one_stacked_bar(broad_df, select_on)


# MOST IMPORTANT TO SUCCEED AT; BE aka 56
x_vals = "I believe the most important thing for my child/children to succeed at is:"
title_graph <- x_vals
plot_histo(df, title_graph, x_vals)

# MOST IMPORTANT SKILL OR MINDSET; BF aka 57
x_vals = "I believe the most skill or mindset for my child/children to develop is:"
title_graph <- x_vals
plot_histo(df, title_graph, x_vals)


# HOUSEHOLD INCOME; BG aka 59
# re-order the values
income_df <-df [,59, drop = FALSE]
custom_order <- c("$0 - 25,000/year", "$25,000 - 50,000/year", "$50,000 - 75,000/year", "$75,000-100,000/year", "$100,000/year or more", "I prefer not to disclose", "NA")
income_df$`What is your household’s range of income?` <- factor(df$`What is your household’s range of income?`, levels = custom_order)
# graph it
title_graph = "Household Income Distribution"
x_vals = "What is your household’s range of income?"
plot_histo(income_df, title_graph, x_vals)


# RACIAL IDENTITY; BH-BO aka 60-67
race_df <-df[,60:67, drop = FALSE]
colnames(race_df) <- df_sub_questions[,60:67, drop = FALSE]
race_df <- race_df[rowSums(is.na(race_df)) != ncol(race_df), ]
key_col = "racial_identity"
preferred_order = c("American Indian or Alaska Native", "Asian", "Black or African American", 
                    "Middle Eastern or North African (e.g. Arab, Kurd, Persian. Turkish)", 
                    "Native Hawaiian and Pacific Islander", "White (e.g. German, Irish, English, American, Italian, Polish)", 
                    "I prefer not to answer", "My identity is not on the list")
title_graph = "reported their race"
count_responses = as.numeric(length(rowSums(!is.na(race_df))))
race_df <- replace(race_df, is.na(race_df), "FALSE")
race_df <- replace(race_df, race_df != "FALSE", "TRUE")
plot_stacked(race_df, key_col, count_responses, title_graph, preferred_order)


# SOURCE; (SurveyMonkey or UT?)
# TODO: visualize


# DIFFICULTY FINDING INFO ON FACTORS
# one giant set of stacked bar graphs for AM-BD (18 columns)
subset_df <- df[, 39:56, drop = FALSE]
colnames(subset_df) <- df_sub_questions[, 39:56, drop = FALSE]
subset_df <- subset_df[rowSums(is.na(subset_df)) != ncol(subset_df), ]
title_graph = "Ease/difficulty finding info on aspects of K-12 school"
name_y_axis = "Count"
name_for_key = "Difficulty finding info"
name_x_axis = "Aspects of K-12 school"
many_bars_stacked(subset_df, title_graph, name_x_axis, name_y_axis, name_for_key)

# making custom graph for each column
for (col in colnames(subset_df)) {
  print(one_stacked_bar(subset_df, col))
}

# visualize considered v. did not consider
considered_v_did_not_consider(subset_df)

