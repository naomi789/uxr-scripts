# install.packages("readxl")
library(readxl)
# install.packages("janitor")
library(janitor)
library(tidyr)


# how to read multiple xlsx worksheets within one file
# https://rpubs.com/tf_peterson/readxl_import 

# FOR RURAL MOBILE
treatment_excel_path <- "usertesting/TREATMENT-4911864-2023-11-29-112711.xlsx"
control_excel_path <- "usertesting/CONTROL-4915906-2023-11-29-112627.xlsx"

# grabbing info from file
t_details <- read_excel(path = treatment_excel_path, sheet = "Session details")
t_metrics <- read_excel(path = treatment_excel_path, sheet = "Metrics")
c_details <- read_excel(path = control_excel_path, sheet = "Session details")
c_metrics <- read_excel(path = control_excel_path, sheet = "Metrics")

# for treatment: 
details <- t_details
metrics <- t_metrics
file_name <- "usertesting/treatment.csv"
study_version = rep(list("Treatment"), 16)

# for control
# details <- c_details
# metrics <- c_metrics
# file_name <- "usertesting/control.csv"
# study_version = rep(list("Control"), 16)

# DETAILS
username = details[7,]
test_id = details[9,]
time_completed = details[12,]
# video_link = details[13,]
age = details[16,]
device = details[18,]
# Annual household income
income = details[20,]
gender = details[24,]
employment_status = details[28,]
industry = details[29,]
job_function = details[30,]
seniority = details[31,]

# SCREENER
worked_in_medicine = details[35,]

# Q3 - How often do you use ChatGPT?
raw_freq_chatgpt_usage = details[46:50,]
df_long_freq <- raw_freq_chatgpt_usage %>%
  gather(key = "column", value = "value", na.rm = TRUE)
# find OG order
original_order <- names(raw_freq_chatgpt_usage)
# Spread the data back to wide format
df_wide_freq <- df_long_freq %>%
  tidyr::spread(key = "column", value = "value")
# Reorder the columns based on the original order
freq_chatgpt_usage <- df_wide_freq[, original_order]

# Q4 - What is the highest level of education you have completed?
raw_highest_education = details[52:59,]
df_long_ed <- raw_highest_education %>%
  gather(key = "column", value = "value", na.rm = TRUE)
# find OG order
original_order <- names(raw_highest_education)
# Spread the data back to wide format
df_wide_ed <- df_long_ed %>%
  tidyr::spread(key = "column", value = "value")
# Reorder the columns based on the original order
highest_education <- df_wide_ed[, original_order]

# Q5 - Consent
consent = details[61,]

# METRICS
a_accuracy = metrics[11,][1:16]
a_accuracy[1, 1] <- "1 - Allergies: The information provided is accurate."
a_make_decisions = metrics[15,][1:16]
a_make_decisions[1, 1] <- "1 - Allergies: make decisions without further research."

b_accuracy = metrics[19,][1:16]
b_accuracy[1, 1] <- "2 - COVID/flu: The information provided is accurate."
b_make_decisions = metrics[23,][1:16]
b_make_decisions[1, 1] <- "2 - COVID/flu: make decisions without further research."

c_accuracy = metrics[27,][1:16]
c_accuracy[1, 1] <- "3 - New job: The information provided is accurate."
c_make_decisions = metrics[31,][1:16]
c_make_decisions[1, 1] <- "3 - New job: make decisions without further research."

# reflection questions
future_self_diagnoses = metrics[42,][1:16]
a_citations = metrics[46,][1:16]
a_citations[1, 1] <- "Citations (1 - Allergies)"
b_citations = metrics[48,][1:16]
b_citations[1, 1] <- "Citations (2 - COVID/flu)"
c_citations = metrics[49,][1:16]
c_citations[1, 1] <- "Citations (3 - New job)"
no_citations = metrics[50,][1:16]
familiar_hallucitations = metrics[53,][1:16]

# check item types
print(class(a_accuracy))    # Should print "list"


list_data <- list(unlist(username), unlist(test_id), unlist(time_completed), 
                  # unlist(video_link), 
                  unlist(age), unlist(device), unlist(income), 
                  unlist(gender), unlist(employment_status), unlist(industry), 
                  unlist(job_function), unlist(seniority), unlist(worked_in_medicine), 
                  unlist(freq_chatgpt_usage), unlist(highest_education), unlist(consent), 
                  # reflection questions
                  unlist(a_accuracy), unlist(a_make_decisions), unlist(b_accuracy), 
                  unlist(b_make_decisions), unlist(c_accuracy), unlist(c_make_decisions), 
                  unlist(future_self_diagnoses), unlist(a_citations), unlist(b_citations),
                  unlist(c_citations), unlist(no_citations), unlist(familiar_hallucitations), 
                  unlist(study_version))
# convert to df
df <- as.data.frame(list_data)
# use first row as column names # TODO: BUG: same Q asked for diff scenarios
df <- df %>% row_to_names(row_number = 1)
# save to a file
write.csv(df, file_name, row.names=FALSE)

