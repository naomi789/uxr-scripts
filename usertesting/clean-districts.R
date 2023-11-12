# install.packages("readxl")
library(readxl)
# install.packages("janitor")
library(janitor)

# how to read multiple xlsx worksheets within one file
# https://rpubs.com/tf_peterson/readxl_import 

# FOR RURAL MOBILE
excel_path <- "UserTesting-Test_Metrics-4888412-RURAL-MOBILE-DISTRICT-QA-EDITED-2023-11-09-085638.xlsx"
file_name = "RURAL-MOBILE-DISTRICT-QA-2023-11.csv"
# FOR RURAL DESKTOP
# excel_path <- "UserTesting-Test_Metrics-4888007-RURAL-DESKTOP-DISTRICT-QA-EDITE-2023-11-09-085708.xlsx"
# file_name = "RURAL-DESKTOP-DISTRICT-QA-2023-11.csv"
# FOR BOTH RURALS
remote_school_name = rep(list("Wenatchee School District"), 16)
community_row_num = 34

# FOR SUBURBAN MOBILE
# excel_path <- "UserTesting-Test_Metrics-4888685-SUBURBAN-MOBILE-DISTRICT-QA-EDI-2023-11-09-085658.xlsx"
# file_name = "SUBURBAN-MOBILE-DISTRICT-QA-2023-11.csv"
# FOR SUBURBAN DESKTOP
# excel_path <- "UserTesting-Test_Metrics-4888681-SUBURBAN-DESKTOP-DISTRICT-QA-ED-2023-11-09-085603.xlsx"
# file_name = "SUBURBAN-DESKTOP-DISTRICT-QA-2023-11.csv"
# FOR BOTH SUBURBANS
# remote_school_name = rep(list("Kent School District"), 16)
# community_row_num = 35

# FOR URBAN MOBILE
# excel_path <- "UserTesting-Test_Metrics-4888686-URBAN-MOBILE-DISTRICT-QA-EDITED-2023-11-12-124114.xlsx"
# file_name = "URBAN-MOBILE-DISTRICT-QA-2023-11.csv"
# FOR URBAN DESKTOP
# excel_path <- "UserTesting-Test_Metrics-4888688-URBAN-DESKTOP-DISTRICT-QA-EDITE-2023-11-12-124106.xlsx"
# file_name = "URBAN-DESKTOP-DISTRICT-QA-2023-11.csv"
# FOR BOTH URBANS
# remote_school_name = rep(list("Seattle Public Schools"), 16)
# community_row_num = 36

# grabbing info from file
details <- read_excel(path = excel_path, sheet = "Session details")
metrics <- read_excel(path = excel_path, sheet = "Metrics")

# DETAILS
username = details[7,]
test_id = details[9,]
time_completed = details[12,]
video_link = details[13,]
# "Children"
kids = details[17,]
# "Device"
device = details[18,]
# Annual household income
income = details[20,]
# "How would you describe the community you live in?"
community = details[community_row_num,]
community[1] <- "How would you describe the community you live in?"

# "In the past 12 months, have you looked at any rating or ranking data about K-12 schools in the US?"
looked_data = details[44,]
looked_data[1] <- "Has looked at data?"
not_looked_data = details[45,]
not_looked_data[1] <- "Has not looked at data?"

# "Do you currently have kid(s) in:"
es_kids = details[47,]
es_kids[1] <- "Has elementary schoolers?"
ms_kids = details[48,]

ms_kids[1] <- "Has middle schoolers?"
hs_kids = details[49,]
hs_kids[1] <- "Has high schoolers?"

# "Are any of your kid(s) currently attending a different K-12 school than they were attending 12 months ago?"
changed = details[52,]
not_changed = details[53,]
not_changed[1] <- "Has not changed K-12 schools?"
# NOW LOOKING AT METRICS SHEET
# "Next, please think of your youngest child who is currently in K-12 school. What is the name of their school?"
multiple_campuses = metrics[15,][1:16]
school_name = metrics[19,][1:16]
# metrics
time = metrics[23,][1:16]
clicks = metrics[24,][1:16]
pages = metrics[25,][1:16]
unique_pages = metrics[26,][1:16]
# responses from user
set_location = metrics[29,][1:16]
success = metrics[33,][1:16]
attempts = metrics[36,][1:16]
ease = metrics[40,][1:16]
location = metrics[43,][1:16]
school_link = metrics[46,][1:16]
loading = metrics[49,][1:16]
ux = metrics[52,][1:16]
accessibility = metrics[56,][1:16]
relevance = metrics[60,][1:16]
filter_usage = metrics[64,][1:16]
filters_tools = metrics[68,][1:16]

# note Qs that are remote
remote_time = metrics[80,][1:16]
remote_time[1] <- paste("Remote: ", remote_time[[1]])
remote_clicks = metrics[81,][1:16]
remote_clicks[1] <- paste("Remote: ", remote_clicks[[1]])
remote_pages = metrics[82,][1:16]
remote_pages[1] <- paste("Remote: ", remote_pages[[1]])
remote_unique_pages = metrics[83,][1:16]
remote_unique_pages[1] <- paste("Remote: ", remote_unique_pages[[1]])
# and the responses
remote_set_location = metrics[86,][1:16]
remote_set_location[1] <- paste("Remote: ", remote_set_location[[1]])
remote_success = metrics[90,][1:16]
remote_success[1] <- paste("Remote: ", remote_success[[1]])
remote_attempts = metrics[93,][1:16]
remote_attempts[1] <- paste("Remote: ", remote_attempts[[1]])
remote_ease = metrics[97,][1:16]
remote_ease[1] <- paste("Remote: ", remote_ease[[1]])
remote_location = metrics[101,][1:16]
remote_location[1] <- paste("Remote: ", remote_location[[1]])
remote_school_link = metrics[105,][1:16]
remote_school_link[1] <- paste("Remote: ", remote_school_link[[1]])
remote_loading = metrics[108,][1:16]
remote_loading[1] <- paste("Remote: ", remote_loading[[1]])
remote_ux = metrics[112,][1:16]
remote_ux[1] <- paste("Remote: ", remote_ux[[1]])
remote_accessibility = metrics[116,][1:16]
remote_accessibility[1] <- paste("Remote: ", remote_accessibility[[1]])
remote_relevance = metrics[120,][1:16]
remote_relevance[1] <- paste("Remote: ", remote_relevance[[1]])
remote_filter_usage = metrics[124,][1:16]
remote_filter_usage[1] <- paste("Remote: ", remote_filter_usage[[1]])
remote_filters_tools = metrics[128,][1:16]
remote_filters_tools[1] <- paste("Remote: ", remote_filters_tools[[1]])
# final question
prior_usage = metrics[132,][1:16]




# then make a dataframe
# method: https://www.programiz.com/r/examples/convert-list-to-dataframe

# (username, test_id, time_completed, video_link, es_kids, ms_kids, hs_kids, looked_data, not_looked_data, kids, device, income, community,school_name, time, clicks, pages, unique_pages,relevance, accuracy, location, filters_tools, loading, ux, accessibility, school_link)
# remote_school_name, remote_time, remote_clicks, remote_pages, remote_unique_pages, remote_relevance, remote_accuracy, remote_location, remote_filters_tools, remote_loading,remote_ux, remote_accessibility, remote_school_link

list_data <- list(unlist(username), unlist(test_id), unlist(time_completed), 
                  unlist(video_link), unlist(kids), unlist(device), unlist(income), 
                  unlist(community), unlist(looked_data), unlist(not_looked_data), 
                  unlist(es_kids), unlist(ms_kids), unlist(hs_kids), unlist(changed), 
                  unlist(not_changed), unlist(multiple_campuses), unlist(school_name), 
                  # datapoints
                  unlist(time), unlist(clicks), unlist(pages), unlist(unique_pages), 
                  # user responses
                  unlist(set_location), unlist(success), unlist(attempts), unlist(ease),
                  unlist(location), unlist(school_link), unlist(loading), unlist(ux), 
                  unlist(accessibility), unlist(relevance), unlist(filter_usage), 
                  unlist(filters_tools), 
                  # remote data points
                  unlist(remote_time), unlist(remote_clicks), unlist(remote_pages), unlist(remote_unique_pages), 
                  # and for remote section
                  unlist(remote_set_location), unlist(remote_success), unlist(remote_attempts), unlist(remote_ease),
                  unlist(remote_location), unlist(remote_school_link), unlist(remote_loading), unlist(remote_ux), 
                  unlist(remote_accessibility), unlist(remote_relevance), unlist(remote_filter_usage), 
                  unlist(remote_filters_tools), 
                  # final question
                  unlist(prior_usage))

df <- as.data.frame(list_data)

# use first row as column names
df <- df %>% row_to_names(row_number = 1)

write.csv(df, file_name, row.names=FALSE)

