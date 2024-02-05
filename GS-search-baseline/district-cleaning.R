# setwd("~/Documents/uxr-scripts/GS-search-baseline")
# install.packages("readxl")
library(readxl)
# install.packages("janitor")
library(janitor)

main_clean_district_data <- function(excel_path, file_name, remote_school_name, community_row_num) {
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
  
  # NOTE: DATA IS TOO MESSY FOR THIS TIME
  # "In the past 12 months, have you looked at any rating or ranking data about K-12 schools in the US?"
  # looked_data = details[60,] # 44
  # looked_data[1] <- "Has looked at data?" 
  # not_looked_data = details[61,] # 45
  # not_looked_data[1] <- "Has not looked at data?"
  
  # "Do you currently have kid(s) in:"
  es_kids = details[49,] # 47
  es_kids[1] <- "Has elementary schoolers?"
  ms_kids = details[50,] # 48
  ms_kids[1] <- "Has middle schoolers?"
  hs_kids = details[51,] # 49
  hs_kids[1] <- "Has high schoolers?"
  
  # ALSO TOO MESSY
  # half of responses are in 2-3 rows and the other half are in other 2-3 rows
  # "Are any of your kid(s) currently attending a different K-12 school than they were attending 12 months ago?"
  # changed = details[52,]
  # not_changed = details[53,]
  # not_changed[1] <- "Has not changed K-12 schools?"
  
  # NOW LOOKING AT METRICS SHEET
  # "Next, please think of your youngest child who is currently in K-12 school. What is the name of their school?"
  multiple_campuses = metrics[19,][1:16]
  school_name = metrics[23,][1:16]
  
  # metrics
  # time = metrics[X,][1:16]
  # clicks = metrics[X,][1:16]
  # pages = metrics[X,][1:16]
  # unique_pages = metrics[X,][1:16]
  
  # responses from user
  set_location = metrics[47,][1:16]
  district_link = metrics[51,][1:16]
  success = metrics[54,][1:16]
  attempts = metrics[58,][1:16]
  ease = metrics[62,][1:16]
  loading = metrics[66,][1:16]
  ux = metrics[70,][1:16]
  has_accessibility = metrics[74,][1:16]
  accessibility = metrics[78,][1:16]
  relevance = metrics[82,][1:16]
  filter_usage = metrics[86,][1:16]
  filters_tools = metrics[90,][1:16]
  
  # REMOTE
  # and the responses
  remote_set_location = metrics[108,][1:16]
  remote_set_location[1] <- paste("Remote: ", remote_set_location[[1]])
  remote_success = metrics[112,][1:16]
  remote_success[1] <- paste("Remote: ", remote_success[[1]])
  remote_attempts = metrics[116,][1:16]
  remote_attempts[1] <- paste("Remote: ", remote_attempts[[1]])
  remote_ease = metrics[120,][1:16]
  remote_ease[1] <- paste("Remote: ", remote_ease[[1]])
  
  # remote_district_link = metrics[105,][1:16]
  # remote_district_link[1] <- paste("Remote: ", remote_district_link[[1]])
  
  remote_loading = metrics[124,][1:16]
  remote_loading[1] <- paste("Remote: ", remote_loading[[1]])
  remote_ux = metrics[128,][1:16]
  remote_ux[1] <- paste("Remote: ", remote_ux[[1]])
  remote_has_accessibility = metrics[132,][1:16]
  remote_has_accessibility[1] <- paste("Remote: ", remote_has_accessibility[[1]])
  remote_accessibility = metrics[136,][1:16]
  remote_accessibility[1] <- paste("Remote: ", remote_accessibility[[1]])
  remote_relevance = metrics[140,][1:16]
  remote_relevance[1] <- paste("Remote: ", remote_relevance[[1]])
  remote_filter_usage = metrics[144,][1:16]
  remote_filter_usage[1] <- paste("Remote: ", remote_filter_usage[[1]])
  remote_filters_tools = metrics[148,][1:16]
  remote_filters_tools[1] <- paste("Remote: ", remote_filters_tools[[1]])
  # final question
  prior_usage = metrics[152,][1:16]
  
  
  
  
  # then make a dataframe
  # method: https://www.programiz.com/r/examples/convert-list-to-dataframe
  
  # (username, test_id, time_completed, video_link, es_kids, ms_kids, hs_kids, looked_data, not_looked_data, kids, device, income, community,school_name, time, clicks, pages, unique_pages,relevance, accuracy, location, filters_tools, loading, ux, accessibility, district_link)
  # remote_school_name, remote_time, remote_clicks, remote_pages, remote_unique_pages, remote_relevance, remote_accuracy, remote_location, remote_filters_tools, remote_loading,remote_ux, remote_accessibility, remote_district_link
  
  list_data <- list(unlist(username), unlist(test_id), unlist(time_completed), 
                    unlist(video_link), unlist(kids), unlist(device), unlist(income), 
                    unlist(community), 
                    # unlist(looked_data), unlist(not_looked_data), 
                    unlist(es_kids), unlist(ms_kids), unlist(hs_kids), 
                    # unlist(changed), unlist(not_changed), 
                    unlist(multiple_campuses), unlist(school_name), 
                    # datapoints
                    # unlist(time), unlist(clicks), unlist(pages), unlist(unique_pages), 
                    # user responses
                    # unlist(set_location), 
                    unlist(success), unlist(attempts), unlist(ease),
                    # unlist(location), 
                    unlist(district_link), unlist(loading), unlist(ux), 
                    unlist(accessibility), unlist(relevance), unlist(filter_usage), 
                    unlist(filters_tools), 
                    # remote data points
                    # unlist(remote_time), unlist(remote_clicks), unlist(remote_pages), unlist(remote_unique_pages), 
                    # and for remote section
                    unlist(remote_set_location), unlist(remote_success), unlist(remote_attempts), unlist(remote_ease),
                    # unlist(remote_location), 
                    # unlist(remote_district_link), 
                    unlist(remote_loading), unlist(remote_ux), 
                    unlist(remote_accessibility), unlist(remote_relevance), unlist(remote_filter_usage), 
                    unlist(remote_filters_tools), 
                    # final question
                    unlist(prior_usage))
  
  df <- as.data.frame(list_data)
  
  # unique_values_list <- list()
  # for (value in df[1,]) {
  #   if (!(value %in% unique_values_list)) {
  #     unique_values_list <- c(unique_values_list, value)
  #   }  
  #   else {
  #     print(value)
  #   }
  # }
  
  # use first row as column names
  df <- df %>% row_to_names(row_number = 1)
  df <- clean_names(df)
  
  write.csv(df, file_name, row.names=FALSE)
  return(df)
}

# MAIN: calling the function
# how to read multiple xlsx worksheets within one file
# https://rpubs.com/tf_peterson/readxl_import 

# FOR BOTH RURALS
remote_school_name = rep(list("Wenatchee School District"), 16)
community_row_num = 34
# FOR RURAL MOBILE
excel_path <- "original-data/district/UserTesting-Test_Metrics-4898561-RURAL-MOBILE-DISTRICT-ED-SEARC-2024-01-08-132203.xlsx"
file_name = "cleaned-data/RURAL-MOBILE-DISTRICT-QA-2024-01.csv"
df <- main_clean_district_data(excel_path, file_name, remote_school_name, community_row_num)
# FOR RURAL DESKTOP
excel_path <- "original-data/district/UserTesting-Test_Metrics-4895729-RURAL-DESKTOP-DISTRICT-ED-SEAR-2024-01-08-132148.xlsx"
file_name = "cleaned-data/RURAL-DESKTOP-DISTRICT-QA-2024-01.csv"
df <- main_clean_district_data(excel_path, file_name, remote_school_name, community_row_num)

# FOR BOTH SUBURBANS
remote_school_name = rep(list("Kent School District"), 16)
community_row_num = 35
# FOR SUBURBAN MOBILE
excel_path <- "original-data/district/UserTesting-Test_Metrics-4958971-SUBURBAN-MOBILE-DISTRICT-ED-SE-2024-01-08-145340.xlsx"
file_name = "cleaned-data/SUBURBAN-MOBILE-DISTRICT-QA-2024-01.csv"
df <- main_clean_district_data(excel_path, file_name, remote_school_name, community_row_num)
# FOR SUBURBAN DESKTOP
excel_path <- "original-data/district/UserTesting-Test_Metrics-4958981-SUBURBAN-DESKTOP-DISTRICT-ED-S-2024-01-08-145448.xlsx"
file_name = "cleaned-data/SUBURBAN-DESKTOP-DISTRICT-QA-2024-01.csv"
df <- main_clean_district_data(excel_path, file_name, remote_school_name, community_row_num)

# FOR BOTH URBANS
remote_school_name = rep(list("Seattle Public Schools"), 16)
community_row_num = 36
# FOR URBAN MOBILE
excel_path <- "original-data/district/UserTesting-Test_Metrics-4898560-URBAN-MOBILE-DISTRICT-ED-2024-01-08-131937.xlsx"
file_name = "cleaned-data/URBAN-MOBILE-DISTRICT-QA-2024-01.csv"
df <- main_clean_district_data(excel_path, file_name, remote_school_name, community_row_num)
# FOR URBAN DESKTOP
excel_path <- "original-data/district/UserTesting-Test_Metrics-4898559-URBAN-DESKTOP-DISTRICT-ED-2024-01-08-131819.xlsx"
file_name = "cleaned-data/URBAN-DESKTOP-DISTRICT-QA-2024-01.csv"
df <- main_clean_district_data(excel_path, file_name, remote_school_name, community_row_num)


