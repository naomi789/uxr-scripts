# install.packages("readxl")
library(readxl)
# install.packages("janitor")
library(janitor)

# how to read multiple xlsx worksheets within one file
# https://rpubs.com/tf_peterson/readxl_import 

hotfix_naming_issue_in_ease <- function(df) {
  # yes it sucks this much, UserTesting had "very easily" as 1/5 
  df <- df %>%
    mutate(ease_how_easily_were_you_ = case_when(
      ease_how_easily_were_you_ == "Very easily" ~ "5 - Very easily", 
      ease_how_easily_were_you_ == "Somewhat easily" ~ "4 - Somewhat easily",
      ease_how_easily_were_you_ == "Neutral" ~ "3 - Neutral",
      ease_how_easily_were_you_ == "Somewhat difficult" ~ "2 - Somewhat difficult",
      ease_how_easily_were_you_ == "Very difficult" ~ "1 - Very difficult",
      ease_how_easily_were_you_ == "5" ~ "1 - Very difficult", 
      ease_how_easily_were_you_ == "4" ~ "2 - Somewhat difficult",
      ease_how_easily_were_you_ == "3" ~ "3 - Neutral",
      ease_how_easily_were_you_ == "2" ~ "4 - Somewhat easily",
      ease_how_easily_were_you_ == "1" ~ "5 - Very easily",
      ease_how_easily_were_you_ == "NA" ~ "NA - I was not able to find it"
    ))
  
}

main_clean_1school_data <- function(excel_path, file_name, remote_school_name, community_row_num) {
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
} 

merging_df <- function() {
  # read in data
  rural_desktop_one <- read_csv("cleaned-data-1school/RURAL-DESKTOP-1SCHOOL-QA-2024-02.csv")  %>% 
    mutate(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
           =as.character(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`), 
           `ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
           =as.character(`ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`)) %>% 
    janitor::clean_names()
  colnames(rural_desktop_one) <- lapply(names(rural_desktop_one), function(x) substr(x, start = 1, stop = 32))
  
  rural_mobile_one <- read_csv("cleaned-data-1school/RURAL-MOBILE-1SCHOOL-QA-2024-02.csv") %>% 
    mutate(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
           =as.character(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`), 
           `ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
           =as.character(`ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`)) %>% 
    janitor::clean_names()
  colnames(rural_mobile_one) <- lapply(names(rural_mobile_one), function(x) substr(x, start = 1, stop = 32))
  
  suburban_mobile_one <- read_csv("cleaned-data-1school/SUBURBAN-MOBILE-1SCHOOL-QA-2024-02.csv") %>% 
    mutate(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
           =as.character(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`), 
           `ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
           =as.character(`ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`)) %>% 
    janitor::clean_names()
  colnames(suburban_mobile_one) <- lapply(names(suburban_mobile_one), function(x) substr(x, start = 1, stop = 32))
  
  suburban_desktop_one <- read_csv("cleaned-data-1school/SUBURBAN-DESKTOP-1SCHOOL-QA-2024-02.csv") %>% 
    mutate(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
           =as.character(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`), 
           `ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
           =as.character(`ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`)) %>% 
    janitor::clean_names()
  colnames(suburban_desktop_one) <- lapply(names(suburban_desktop_one), function(x) substr(x, start = 1, stop = 32))
  
  urban_mobile_one <- read_csv("cleaned-data-1school/URBAN-MOBILE-1SCHOOL-QA-2024-02.csv") %>% 
    mutate(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
           =as.character(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`), 
           `ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
           =as.character(`ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`)) %>% 
    janitor::clean_names()
  colnames(urban_mobile_one) <- lapply(names(urban_mobile_one), function(x) substr(x, start = 1, stop = 32))
  
  urban_desktop_one <- read_csv("cleaned-data-1school/URBAN-DESKTOP-1SCHOOL-QA-2024-02.csv") %>% 
    mutate(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
           =as.character(`Remote:  ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`), 
           `ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`
           =as.character(`ATTEMPTS: How many searches or queries did you make before you found the correct school? For example, if you typed in "SMS" and couldn't find the school, but typed "Springfield Middle School" and found the school, then select "2".`)) %>% 
    janitor::clean_names()
  colnames(urban_desktop_one) <- lapply(names(urban_desktop_one), function(x) substr(x, start = 1, stop = 32))
  
  # combine them into one big df
  rural_df <- bind_rows(rural_desktop_one, rural_mobile_one)
  suburban_df <- bind_rows(suburban_mobile_one, suburban_desktop_one)
  urban_df <- bind_rows(urban_mobile_one, urban_desktop_one)
  full_df <- bind_rows(rural_df, suburban_df, urban_df)
  return(full_df)
}

tidy_merged_df_and_save <- function(full_df, final_file_name) {
  # stack remote and local questions
  local_df <- full_df %>% select(-contains("remote_"))
  # note that these answers are for local schools
  local_df$search_type <- "local"
  # write.csv(local_df, "local_df.csv")
  
  
  # next, get all the remote ones AND the first 15 columns
  remote_df <- full_df[c(1:15, 34:50)]
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
  
  
  # then combine the two columns into one df
  df <- bind_rows(local_df, remote_df)
  
  #HOTFIXES
  df <- hotfix_naming_issue_in_ease(df)
  
  # if the "device" is "Smartphone (unconfirmed)" then rename it to "Smartphone"
  df <- df %>% mutate(device = ifelse(device == "Smartphone (unconfirmed)", "Smartphone", device))
  
  # and save it
  write.csv(df, final_file_name)
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

# FOR BOTH RURALS
remote_school_name = rep(list("Wenatchee High School"), 16)
community_row_num = 34
# FOR RURAL MOBILE
excel_path <- "original-data-all/1school/UserTesting-Test_Metrics-4888412-RURAL-MOBILE-1SCHOOL-QA-EDITED-2024-01-08-142937.xlsx"
file_name = "cleaned-data-1school/RURAL-MOBILE-1SCHOOL-QA-2024-02.csv"
main_clean_1school_data(excel_path, file_name, remote_school_name, community_row_num)
# FOR RURAL DESKTOP
excel_path <- "original-data-all/1school/UserTesting-Test_Metrics-4888007-RURAL-DESKTOP-1SCHOOL-QA-EDITE-2024-01-08-132621.xlsx"
file_name = "cleaned-data-1school/RURAL-DESKTOP-1SCHOOL-QA-2024-02.csv"
main_clean_1school_data(excel_path, file_name, remote_school_name, community_row_num)


# FOR BOTH SUBURBANS
remote_school_name = rep(list("Kentwood High School"), 16)
community_row_num = 35
# FOR SUBURBAN MOBILE
excel_path <- "original-data-all/1school/UserTesting-Test_Metrics-4888685-SUBURBAN-MOBILE-1SCHOOL-QA-EDI-2024-01-08-143249.xlsx"
file_name = "cleaned-data-1school/SUBURBAN-MOBILE-1SCHOOL-QA-2024-02.csv"
main_clean_1school_data(excel_path, file_name, remote_school_name, community_row_num)
# FOR SUBURBAN DESKTOP
excel_path <- "original-data-all/1school/UserTesting-Test_Metrics-4888681-SUBURBAN-DESKTOP-1SCHOOL-QA-ED-2024-01-08-143232.xlsx"
file_name = "cleaned-data-1school/SUBURBAN-DESKTOP-1SCHOOL-QA-2024-02.csv"
main_clean_1school_data(excel_path, file_name, remote_school_name, community_row_num)

# FOR BOTH URBANS
remote_school_name = rep(list("Cleveland High School"), 16)
community_row_num = 36
# FOR URBAN MOBILE
excel_path <- "original-data-all/1school/UserTesting-Test_Metrics-4888686-URBAN-MOBILE-1SCHOOL-QA-EDITED-2024-01-08-132555.xlsx"
file_name = "cleaned-data-1school/URBAN-MOBILE-1SCHOOL-QA-2024-02.csv"
main_clean_1school_data(excel_path, file_name, remote_school_name, community_row_num)
# FOR URBAN DESKTOP
excel_path <- "original-data-all/1school/UserTesting-Test_Metrics-4888688-URBAN-DESKTOP-1SCHOOL-QA-EDITE-2024-01-08-132531.xlsx"
file_name = "cleaned-data-1school/URBAN-DESKTOP-1SCHOOL-QA-2024-02.csv"
main_clean_1school_data(excel_path, file_name, remote_school_name, community_row_num)

# NOW MERGE ALL SIX DF
full_df <- merging_df()
# AND DO LAST TIDY OF THEM
df <- tidy_merged_df_and_save(full_df, "cleaned-data-1school/1school_no_unconfirmed-smartphones-combined-local-remote.csv")
#QUALITY ASSURANCE
quality_assurance(df)





  

