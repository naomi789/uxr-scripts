# setwd("~/Documents/uxr-scripts/GS-search-baseline")
# install.packages("readxl")
library(readxl)
# install.packages("janitor")
library(janitor)
library(readr)
library(tidyverse)
library(ggplot2)
library(likert) 
library(assertthat)


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

# NOW CLEAN ALL THAT DATA
merging_df <- function() {
  # read in data
  rural_mobile_district <- read_csv("cleaned-data-district/RURAL-MOBILE-DISTRICT-QA-2024-01.csv") %>% janitor::clean_names()
  colnames(rural_mobile_district) <- lapply(names(rural_mobile_district), function(x) substr(x, start = 1, stop = 32))
  rural_desktop_district <- read_csv("cleaned-data-district/RURAL-DESKTOP-DISTRICT-QA-2024-01.csv")  %>% 
    mutate(`remote_attempts_how_many_searches_or_queries_did_you_make_before_you_found_the_correct_district_for_example_if_you_typed_in_nyps_and_couldnt_find_the_district_but_typed_new_york_public_schools_and_found_it_then_select_2`
           =as.character(`remote_attempts_how_many_searches_or_queries_did_you_make_before_you_found_the_correct_district_for_example_if_you_typed_in_nyps_and_couldnt_find_the_district_but_typed_new_york_public_schools_and_found_it_then_select_2`)) %>% 
    janitor::clean_names()
  colnames(rural_desktop_district) <- lapply(names(rural_desktop_district), function(x) substr(x, start = 1, stop = 32))
  rural_df <- bind_rows(rural_desktop_district, rural_mobile_district)
  
  suburban_mobile_district <- read_csv("cleaned-data-district/SUBURBAN-MOBILE-DISTRICT-QA-2024-01.csv") %>% janitor::clean_names()
  colnames(suburban_mobile_district) <- lapply(names(suburban_mobile_district), function(x) substr(x, start = 1, stop = 32))
  suburban_desktop_district <- read_csv("cleaned-data-district/SUBURBAN-DESKTOP-DISTRICT-QA-2024-01.csv") %>% janitor::clean_names()
  colnames(suburban_desktop_district) <- lapply(names(suburban_desktop_district), function(x) substr(x, start = 1, stop = 32))
  suburban_df <- bind_rows(suburban_mobile_district, suburban_desktop_district)
  
  urban_mobile_district <- read_csv("cleaned-data-district/URBAN-MOBILE-DISTRICT-QA-2024-01.csv") %>% janitor::clean_names()
  colnames(urban_mobile_district) <- lapply(names(urban_mobile_district), function(x) substr(x, start = 1, stop = 32))
  urban_desktop_district <- read_csv("cleaned-data-district/URBAN-DESKTOP-DISTRICT-QA-2024-01.csv") %>% janitor::clean_names()
  colnames(urban_desktop_district) <- lapply(names(urban_desktop_district), function(x) substr(x, start = 1, stop = 32))
  urban_df <- bind_rows(urban_mobile_district, urban_desktop_district)
  
  # combine them into one big df
  full_df <- bind_rows(suburban_df, urban_df, rural_df)
}

tidy_merged_df_and_save <- function(full_df, final_file_name) {
  # DO NOT USE - this is the syntax to remove NA
  # full_df <- full_df[!is.na(full_df$username),]
  
  # to stack the remote and local questions
  # find remote ones
  local_df <- full_df %>% select(-contains("remote_"))
  # note which answers were for local schools
  local_df$search_type <- "local"
  # write.csv(local_df, "local_df.csv")
  # next, get all the remote columns (in this case, last 11) AND the columns with participant data (first 11)
  remote_df <- full_df[c(1:11, 25:34)]
  remote_df$search_type <- "remote"
  # write.csv(remote_df, "remote_df.csv")
  
  # if column name contains "remote_*" then rename it to "*"
  remote_df <- remote_df %>%
    rename_with(~ sub("^remote_", "", .), starts_with("remote_"))
  colnames(remote_df) <- lapply(names(remote_df), function(x) substr(x, start = 1, stop = 25))
  
  
  # then shorten all local_df colnames to be the same length
  colnames(local_df) <- lapply(names(local_df), function(x) substr(x, start = 1, stop = 25))
  # write.csv(local_df, "local_df_but_shorter_names.csv")
  
  # make sure all columns are char not double
  local_df <- local_df %>% mutate(ease_how_easily_were_you_ = as.character(ease_how_easily_were_you_))
  local_df <- local_df %>% mutate(loading_how_satisfied_wer = as.character(loading_how_satisfied_wer))
  remote_df <- remote_df %>% mutate(ease_how_easily_were_you_ = as.character(ease_how_easily_were_you_))
  remote_df <- remote_df %>% mutate(loading_how_satisfied_wer = as.character(loading_how_satisfied_wer))
  
  
  # then combine the two into one df
  df <- bind_rows(local_df, remote_df)
  
  # last fix??? 
  # if the "device" is "Smartphone (unconfirmed)" then rename it to "Smartphone"
  df <- df %>% mutate(device = ifelse(device == "Smartphone (unconfirmed)", "Smartphone", device))
  
  # and save it
  write.csv(df, final_file_name)
  
  return(df)
}

quality_assurance <- function(df) {
  # should be 15*6 unique completed tests. Ideally that many unique usernames, too. 
  assert_that(length(unique(df$test_id_number)) == 90, msg = "ERROR: wrong number of completed tests\n\n\n\n\n")
  assert_that(length(unique(df$username)) == 90, msg = "ERROR: wrong number of unique participant usernames\n\n\n\n\n")
  
  # should be 15*6*2 rows of data
  assert_that(nrow(df) == 180, msg = "ERROR: wrong number of rows")
  
  # should be 50/50 "device"="Smartphone" and "device"="Computer"
  assert_that(sum(df$device == "Smartphone") == 90, sum(df$device == "Computer") == 90, msg = "ERROR: wrong number of device(s)")
  
  # should be exactly 33/33/33 "how_would_you_describe_th"=["Urban", Suburban", "Rural"]
  assert_that(sum(df$how_would_you_describe_th == "Urban") == 60, msg = "ERROR: wrong number of urban")
  assert_that(sum(df$how_would_you_describe_th == "Suburban") == 60, msg = "ERROR: wrong number of suburban")
  assert_that(sum(df$how_would_you_describe_th == "Rural") == 60, msg = "ERROR: wrong number of rural")
  
  # at least 33% should be not NA "has_elementary_schoolers"; "has_middle_schoolers"; "has_high_schoolers"
  assert_that(sum(!is.na(df$has_elementary_schoolers)) >= 60, msg = "ERROR: wrong number of ES")
  assert_that(sum(!is.na(df$has_middle_schoolers)) >= 60, msg = "ERROR: wrong number of MS")
  assert_that(sum(!is.na(df$has_high_schoolers)) >= 60, msg = "ERROR: wrong number of HS")
}


# MAIN: calling the function
# how to read multiple xlsx worksheets within one file
# https://rpubs.com/tf_peterson/readxl_import 

# FOR BOTH RURALS
remote_school_name = rep(list("Wenatchee School District"), 16)
community_row_num = 34
# FOR RURAL MOBILE
excel_path <- "original-data-all/district/UserTesting-Test_Metrics-4898561-RURAL-MOBILE-DISTRICT-ED-SEARC-2024-01-08-132203.xlsx"
file_name = "cleaned-data-district/RURAL-MOBILE-DISTRICT-QA-2024-01.csv"
df <- main_clean_district_data(excel_path, file_name, remote_school_name, community_row_num)
# FOR RURAL DESKTOP
excel_path <- "original-data-all/district/UserTesting-Test_Metrics-4895729-RURAL-DESKTOP-DISTRICT-ED-SEAR-2024-01-08-132148.xlsx"
file_name = "cleaned-data-district/RURAL-DESKTOP-DISTRICT-QA-2024-01.csv"
df <- main_clean_district_data(excel_path, file_name, remote_school_name, community_row_num)

# FOR BOTH SUBURBANS
remote_school_name = rep(list("Kent School District"), 16)
community_row_num = 35
# FOR SUBURBAN MOBILE
excel_path <- "original-data-all/district/UserTesting-Test_Metrics-4958971-SUBURBAN-MOBILE-DISTRICT-ED-SE-2024-01-08-145340.xlsx"
file_name = "cleaned-data-district/SUBURBAN-MOBILE-DISTRICT-QA-2024-01.csv"
df <- main_clean_district_data(excel_path, file_name, remote_school_name, community_row_num)
# FOR SUBURBAN DESKTOP
excel_path <- "original-data-all/district/UserTesting-Test_Metrics-4958981-SUBURBAN-DESKTOP-DISTRICT-ED-S-2024-01-08-145448.xlsx"
file_name = "cleaned-data-district/SUBURBAN-DESKTOP-DISTRICT-QA-2024-01.csv"
df <- main_clean_district_data(excel_path, file_name, remote_school_name, community_row_num)

# FOR BOTH URBANS
remote_school_name = rep(list("Seattle Public Schools"), 16)
community_row_num = 36
# FOR URBAN MOBILE
excel_path <- "original-data-all/district/UserTesting-Test_Metrics-4898560-URBAN-MOBILE-DISTRICT-ED-2024-01-08-131937.xlsx"
file_name = "cleaned-data-district/URBAN-MOBILE-DISTRICT-QA-2024-01.csv"
df <- main_clean_district_data(excel_path, file_name, remote_school_name, community_row_num)
# FOR URBAN DESKTOP
excel_path <- "original-data-all/district/UserTesting-Test_Metrics-4898559-URBAN-DESKTOP-DISTRICT-ED-2024-01-08-131819.xlsx"
file_name = "cleaned-data-district/URBAN-DESKTOP-DISTRICT-QA-2024-01.csv"
df <- main_clean_district_data(excel_path, file_name, remote_school_name, community_row_num)

# NOW MERGE ALL SIX DF
full_df <- merging_df()
# AND DO LAST TIDY OF THEM
df <- tidy_merged_df_and_save(full_df, "cleaned-data-district/no_unconfirmed-smartphones-combined-both-local-and-remote.csv")
#QUALITY ASSURANCE
quality_assurance(df)
  

