library(readxl)
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

excel_path <- "UserTesting-Test_Metrics-4942714-Understand_their_kid_has_a_sch-2023-12-18-100334.xlsx"
details <- read_excel(path = excel_path, sheet = "Session details")
metrics <- read_excel(path = excel_path, sheet = "Metrics")
file_name = "SATISFACTION-WITH-COMMUNICATING-2023-11.csv"

income = details[20,][1:10]
final_persona = metrics[18,][1:10]
satis_district = metrics[22,][1:10]
satis_school = metrics[26,][1:10]
satis_teacher = metrics[30,][1:10]
school_relationship = metrics[38,][1:10]
school_freq = metrics[42,][1:10]
school_method = metrics[59,][1:10]
school_topics = metrics[63,][1:10]
district_relationship = metrics[67,][1:10]
district_freq = metrics[75,][1:10]
district_method = metrics[92,][1:10]
district_topics = metrics[96,][1:10]
district_url = metrics[116,][1:10]

list_data <- list(unlist(income), unlist(final_persona), unlist(satis_district), 
                  unlist(satis_school), unlist(satis_teacher), unlist(school_relationship), 
                  unlist(school_freq), unlist(school_method), unlist(school_topics), 
                  unlist(district_relationship), unlist(district_freq),
                  unlist(district_method), unlist(district_topics), unlist(district_url))
                  

df <- as.data.frame(list_data)

# use first row as column names
df <- df %>% row_to_names(row_number = 1)

write.csv(df, file_name, row.names=FALSE)

# SATISFACTION
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
