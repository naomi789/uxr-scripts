library(readr)
library(janitor)
library(tidyr)
library(dplyr)
library(ggplot2)

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

# MERGE CLEAN DATA
any_satisfaction <- read_csv("ANY-SATISFACTION-COMMUNICATING-2023-12.csv")
df <- any_satisfaction
# very_or_satisfied <- read_csv("VERYSATISFIED_OR_SATISFIED-2023-12.csv")
# verynot_or_notsatisfied <- read_csv("VERYNOTSATISFIED_OR_NOT_SATISFIED-2023-12.csv")
# all_responses <- bind_rows(very_or_satisfied, verynot_or_notsatisfied, any_satisfaction)
# df <- all_responses

# SATISFACTION
select_on = "How satisfied are you currently with the quality of your child's TEACHER? Why?"
p <- one_stacked_bar(df, select_on)
p
select_on = "How satisfied are you currently with the quality of your child's SCHOOL? Why?"
p <- one_stacked_bar(df, select_on)
p
select_on = "How satisfied are you currently with the quality of your child's school DISTRICT? Why?"
p <- one_stacked_bar(df, select_on)
p

# HAVE RELATIONSHIP?
select_on = "Do you have a relationship with your child's K-12 SCHOOL? Please explain what the relationship is like."
p <- one_stacked_bar(df, select_on)
p
select_on = "Do you have a relationship with your child's K-12 school DISTRICT? Please explain what the relationship is like."
p <- one_stacked_bar(df, select_on)
p
# FREQUENCY
select_on = "How do you feel about the FREQUENCY your child's school communicates with you?"
p <- one_stacked_bar(df, select_on)
p
select_on = "How do you feel about the FREQUENCY your child's school district communicates with you?"
p <- one_stacked_bar(df, select_on)
p
# METHOD
select_on = "How do you feel about the METHOD that your child's school uses to communicates with you?"
p <- one_stacked_bar(df, select_on)
p
select_on = "How do you feel about the METHOD that your child's school district uses to communicates with you?"
p <- one_stacked_bar(df, select_on)
p
# TOPICS
select_on = "How do you feel about the TOPICS that your child's school communicates with you?"
p <- one_stacked_bar(df, select_on)
p
select_on = "How do you feel about the TOPICS that your child's school district communicates with you?"
p <- one_stacked_bar(df, select_on)
p

