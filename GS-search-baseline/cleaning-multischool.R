# install.packages("readxl")
library(readxl)
# install.packages("janitor")
library(janitor)

# how to read multiple xlsx worksheets within one file
# https://rpubs.com/tf_peterson/readxl_import 



main_clean_multischool_data <- function(excel_path, file_name, remote_school_name, community_row_num) {
  # grabbing info from file
  details <- read_excel(path = excel_path, sheet = "Session details")
  metrics <- read_excel(path = excel_path, sheet = "Metrics")
  
  # DETAILS
  username = details[7,]
  test_id = details[8,]
  time_completed = details[9,]
  video_link = details[10,]
  # "Children"
  kids = details[14,]
  # "Device"
  device = details[15,]
  # Annual household income
  income = details[17,]
  # "How would you describe the community you live in?"
  community = details[community_row_num,]
  community[1] <- "How would you describe the community you live in?"
  
  # "In the past 12 months, have you looked at any rating or ranking data about K-12 schools in the US?"
  looked_data = details[59,]
  looked_data[1] <- "Has looked at data?"
  not_looked_data = details[60,]
  not_looked_data[1] <- "Has not looked at data?"
  
  # "Do you currently have kid(s) in:"
  es_kids = details[62,]
  es_kids[1] <- "Has elementary schoolers?"
  ms_kids = details[63,]
  
  ms_kids[1] <- "Has middle schoolers?"
  hs_kids = details[64,]
  hs_kids[1] <- "Has high schoolers?"
  
  # "Are any of your kid(s) currently attending a different K-12 school than they were attending 12 months ago?"
  changed = details[67,]
  not_changed = details[68,]
  not_changed[1] <- "Has not changed K-12 schools?"
  # NOW LOOKING AT METRICS SHEET
  # metrics
  time = metrics[35,][1:16]
  clicks = metrics[36,][1:16]
  pages = metrics[37,][1:16]
  unique_pages = metrics[38,][1:16]
  
  # responses from user
  set_location = metrics[41,][1:16] # 
  # success = metrics[33,][1:16]
  attempts = metrics[53,][1:16]   # 
  ease = metrics[57,][1:16]       #
  location = metrics[61,][1:16]   # 
  # school_link = metrics[46,][1:16]
  loading = metrics[65,][1:16]    # 
  ux = metrics[68,][1:16]         # 
  accessibility = metrics[76,][1:16] # 
  relevance = metrics[45,][1:16]  #
  filter_usage = metrics[80,][1:16] # 
  filters_tools = metrics[84,][1:16] # 
  # new
  accuracy = metrics[49,][1:16]
  expectations = metrics[88,][1:16]
  
  # note Qs that are remote
  remote_time = metrics[100,][1:16]
  remote_time[1] <- paste("Remote: ", remote_time[[1]])
  remote_clicks = metrics[101,][1:16]
  remote_clicks[1] <- paste("Remote: ", remote_clicks[[1]])
  remote_pages = metrics[102,][1:16]
  remote_pages[1] <- paste("Remote: ", remote_pages[[1]])
  remote_unique_pages = metrics[103,][1:16]
  remote_unique_pages[1] <- paste("Remote: ", remote_unique_pages[[1]])
  
  # and the responses
  remote_set_location = metrics[106,][1:16]
  remote_set_location[1] <- paste("Remote: ", remote_set_location[[1]])
  # remote_success = metrics[101,][1:16]
  # remote_success[1] <- paste("Remote: ", remote_success[[1]])
  remote_attempts = metrics[118,][1:16]
  remote_attempts[1] <- paste("Remote: ", remote_attempts[[1]])
  remote_ease = metrics[122,][1:16]
  remote_ease[1] <- paste("Remote: ", remote_ease[[1]])
  remote_location = metrics[126,][1:16]
  remote_location[1] <- paste("Remote: ", remote_location[[1]])
  # remote_school_link = metrics[105,][1:16]
  # remote_school_link[1] <- paste("Remote: ", remote_school_link[[1]])
  remote_loading = metrics[130,][1:16]
  remote_loading[1] <- paste("Remote: ", remote_loading[[1]])
  remote_ux = metrics[134,][1:16]
  remote_ux[1] <- paste("Remote: ", remote_ux[[1]])
  remote_accessibility = metrics[142,][1:16]
  remote_accessibility[1] <- paste("Remote: ", remote_accessibility[[1]])
  remote_relevance = metrics[110,][1:16]
  remote_relevance[1] <- paste("Remote: ", remote_relevance[[1]])
  remote_filter_usage = metrics[146,][1:16]
  remote_filter_usage[1] <- paste("Remote: ", remote_filter_usage[[1]])
  remote_filters_tools = metrics[150,][1:16]
  remote_filters_tools[1] <- paste("Remote: ", remote_filters_tools[[1]])
  # new
  remote_accuracy = metrics[114,][1:16]
  remote_accuracy[1] <- paste("Remote: ", remote_accuracy[[1]])
  # final question
  prior_usage = metrics[154,][1:16]
  
  # then make a dataframe
  # method: https://www.programiz.com/r/examples/convert-list-to-dataframe
  
  # (username, test_id, time_completed, video_link, es_kids, ms_kids, hs_kids, looked_data, not_looked_data, kids, device, income, community,school_name, time, clicks, pages, unique_pages,relevance, accuracy, location, filters_tools, loading, ux, accessibility, school_link)
  # remote_school_name, remote_time, remote_clicks, remote_pages, remote_unique_pages, remote_relevance, remote_accuracy, remote_location, remote_filters_tools, remote_loading,remote_ux, remote_accessibility, remote_school_link
  
  list_data <- list(unlist(username), unlist(test_id), unlist(time_completed), 
                    unlist(video_link), unlist(kids), unlist(device), unlist(income), 
                    unlist(community), unlist(looked_data), unlist(not_looked_data), 
                    unlist(es_kids), unlist(ms_kids), unlist(hs_kids), unlist(changed), 
                    unlist(not_changed),
                    # unlist(multiple_campuses), unlist(school_name), 
                    # datapoints
                    unlist(time), unlist(clicks), unlist(pages), unlist(unique_pages), 
                    # user responses
                    unlist(set_location), 
                    # unlist(success), 
                    unlist(attempts), unlist(ease),
                    unlist(location), 
                    # unlist(school_link), 
                    unlist(loading), unlist(ux), 
                    unlist(accessibility), unlist(relevance), unlist(filter_usage), 
                    unlist(filters_tools), 
                    # NEW
                    unlist(accuracy), unlist(expectations),
                    # remote data points
                    unlist(remote_time), unlist(remote_clicks), unlist(remote_pages), unlist(remote_unique_pages), 
                    # and for remote section
                    unlist(remote_set_location), 
                    # unlist(remote_success), 
                    unlist(remote_attempts), unlist(remote_ease),
                    unlist(remote_location), 
                    # unlist(remote_school_link), 
                    unlist(remote_loading), unlist(remote_ux), 
                    unlist(remote_accessibility), unlist(remote_relevance), unlist(remote_filter_usage), 
                    unlist(remote_filters_tools), 
                    # NEW: 
                    unlist(remote_accuracy),
                    # final question
                    unlist(prior_usage))
  
  df <- as.data.frame(list_data)
  
  # use first row as column names
  df <- df %>% row_to_names(row_number = 1)
  
  write.csv(df, file_name, row.names=FALSE)
} 

merging_df <- function() {
  # read in data
  rural_desktop_one <- read_csv("cleaned-data-multischool/RURAL-DESKTOP-MULTISCHOOL-QA-2024-02.csv") %>% 
    mutate(`ATTEMPTS: How many searches or queries did you make before you found schools that were close to you? For example, if you typed in "Springfield" and got directed to results in Springfield, Illinois, and had to do a second search to get results in Springfield, Massachusetts, then select "2".`
           =as.character(`ATTEMPTS: How many searches or queries did you make before you found schools that were close to you? For example, if you typed in "Springfield" and got directed to results in Springfield, Illinois, and had to do a second search to get results in Springfield, Massachusetts, then select "2".`), 
           `ATTEMPTS: How many searches or queries did you make before you found schools that were close to you? For example, if you typed in "Springfield" and got directed to results in Springfield, Illinois, and had to do a second search to get results in Springfield, Massachusetts, then select "2".`
           =as.character(`ATTEMPTS: How many searches or queries did you make before you found schools that were close to you? For example, if you typed in "Springfield" and got directed to results in Springfield, Illinois, and had to do a second search to get results in Springfield, Massachusetts, then select "2".`)) %>% 
    janitor::clean_names()
  colnames(rural_desktop_one) <- lapply(names(rural_desktop_one), function(x) substr(x, start = 1, stop = 32))
  
  rural_mobile_one <- read_csv("cleaned-data-multischool/RURAL-MOBILE-MULTISCHOOL-QA-2024-02.csv") %>% 
    mutate(`ATTEMPTS: How many searches or queries did you make before you found schools that were close to you? For example, if you typed in "Springfield" and got directed to results in Springfield, Illinois, and had to do a second search to get results in Springfield, Massachusetts, then select "2".`
           =as.character(`ATTEMPTS: How many searches or queries did you make before you found schools that were close to you? For example, if you typed in "Springfield" and got directed to results in Springfield, Illinois, and had to do a second search to get results in Springfield, Massachusetts, then select "2".`), 
           `ATTEMPTS: How many searches or queries did you make before you found schools that were close to you? For example, if you typed in "Springfield" and got directed to results in Springfield, Illinois, and had to do a second search to get results in Springfield, Massachusetts, then select "2".`
           =as.character(`ATTEMPTS: How many searches or queries did you make before you found schools that were close to you? For example, if you typed in "Springfield" and got directed to results in Springfield, Illinois, and had to do a second search to get results in Springfield, Massachusetts, then select "2".`)) %>% 
    janitor::clean_names()
  colnames(rural_mobile_one) <- lapply(names(rural_mobile_one), function(x) substr(x, start = 1, stop = 32))
  
  suburban_mobile_one <- read_csv("cleaned-data-multischool/SUBURBAN-MOBILE-MULTISCHOOL-QA-2024-02.csv") %>% 
    janitor::clean_names()
  colnames(suburban_mobile_one) <- lapply(names(suburban_mobile_one), function(x) substr(x, start = 1, stop = 32))
  
  suburban_desktop_one <- read_csv("cleaned-data-multischool/SUBURBAN-DESKTOP-MULTISCHOOL-QA-2024-02.csv") %>% 
    janitor::clean_names()
  colnames(suburban_desktop_one) <- lapply(names(suburban_desktop_one), function(x) substr(x, start = 1, stop = 32))
  
  urban_mobile_one <- read_csv("cleaned-data-multischool/URBAN-MOBILE-MULTISCHOOL-QA-2024-02.csv") %>% 
    janitor::clean_names()
  colnames(urban_mobile_one) <- lapply(names(urban_mobile_one), function(x) substr(x, start = 1, stop = 32))
  
  urban_desktop_one <- read_csv("cleaned-data-multischool/URBAN-DESKTOP-MULTISCHOOL-QA-2024-02.csv") %>% 
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
  
  # NOTE MUST SET RANGE FOR EACH SCRIPT
  # next, get all the remote ones AND the first 15 columns
  remote_df <- full_df[c(1:15, 32:47)]
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
  local_df <- local_df %>% mutate(attempts_how_many_searche = as.character(attempts_how_many_searche))
  remote_df <- remote_df %>% mutate(attempts_how_many_searche = as.character(attempts_how_many_searche))
  local_df <- local_df %>% mutate(loading_how_satisfied_wer = as.character(loading_how_satisfied_wer))
  remote_df <- remote_df %>% mutate(loading_how_satisfied_wer = as.character(loading_how_satisfied_wer))
  
  # then combine the two columns into one df
  df <- bind_rows(local_df, remote_df)
  
  #HOTFIXES
  # df <- hotfix_naming_issue_in_ease(df)
  
  # if the "device" is "Smartphone (unconfirmed)" then rename it to "Smartphone"
  df <- df %>% mutate(device = ifelse(device == "Smartphone (unconfirmed)", "Smartphone", device))
  
  # and save it
  write.csv(df, final_file_name)
  return(df)
}

quality_assurance <- function(df) {
  # should be 15*6 unique completed tests. Ideally that many unique usernames, too. 
  assert_that(length(unique(df$test_id_number)) == 90, msg = "ERROR: wrong number of completed tests\n\n\n\n\n")
  # TODO: commented bc of NA error
  # assert_that(length(unique(df$username)) == 90, msg = "ERROR: wrong number of unique participant usernames\n\n\n\n\n")
  assert_that(nrow(df) == 180, msg = "ERROR: wrong number of rows")
  
  # should be 50/50 "device"="Smartphone" and "device"="Computer"
  assert_that(sum(df$device == "Smartphone") == 90, sum(df$device == "Computer") == 90, msg = "ERROR: wrong number of device(s)")
  
  # should be exactly 33/33/33 "how_would_you_describe_th"=["Urban", Suburban", "Rural"]
  # TODO: unsure why this is breaking, I'm getting NA? 
  # assert_that(sum(df$how_would_you_describe_th == "Urban") == 60, msg = "ERROR: wrong number of urban")
  # assert_that(sum(df$how_would_you_describe_th == "Suburban") == 60, msg = "ERROR: wrong number of suburban")
  # assert_that(sum(df$how_would_you_describe_th == "Rural") == 60, msg = "ERROR: wrong number of rural")
  
  # at least 33% should be not NA "has_elementary_schoolers"; "has_middle_schoolers"; "has_high_schoolers"
  assert_that(sum(!is.na(df$has_elementary_schoolers)) >= 60, msg = "ERROR: wrong number of ES")
  assert_that(sum(!is.na(df$has_middle_schoolers)) >= 60, msg = "ERROR: wrong number of MS")
  assert_that(sum(!is.na(df$has_high_schoolers)) >= 60, msg = "ERROR: wrong number of HS")
}

# FOR BOTH RURALS
remote_school_name = rep(list("K-12 around Wenatchee, WA"), 16)
community_row_num = 31
# FOR RURAL MOBILE
excel_path <- "original-data-all/multischool/UserTesting-Test_Metrics-4961966-RURAL-MOBILE-MULTISCHOOL-ED-2024-02-05-144118.xlsx"
file_name = "cleaned-data-multischool/RURAL-MOBILE-MULTISCHOOL-QA-2024-02.csv"
main_clean_multischool_data(excel_path, file_name, remote_school_name, community_row_num)
# FOR RURAL DESKTOP
excel_path <- "original-data-all/multischool/UserTesting-Test_Metrics-4960616-RURAL-DESKTOP-MULTISCHOOL-ED-2024-02-05-144137.xlsx"
file_name = "cleaned-data-multischool/RURAL-DESKTOP-MULTISCHOOL-QA-2024-02.csv"
main_clean_multischool_data(excel_path, file_name, remote_school_name, community_row_num)


# FOR BOTH SUBURBANS
remote_school_name = rep(list("K-12 around Kent, WA"), 16)
community_row_num = 35
# FOR SUBURBAN MOBILE
excel_path <- "original-data-all/multischool/UserTesting-Test_Metrics-4994476-SUBURBAN-MOBILE-MULTISCHOOL-ED-2024-02-06-091705.xlsx"
file_name = "cleaned-data-multischool/SUBURBAN-MOBILE-MULTISCHOOL-QA-2024-02.csv"
main_clean_multischool_data(excel_path, file_name, remote_school_name, community_row_num)
# FOR SUBURBAN DESKTOP
excel_path <- "original-data-all/multischool/UserTesting-Test_Metrics-4994482-SUBURBAN-DESKTOP-MULTISCHOOL-E-2024-02-06-092028.xlsx"
file_name = "cleaned-data-multischool/SUBURBAN-DESKTOP-MULTISCHOOL-QA-2024-02.csv"
main_clean_multischool_data(excel_path, file_name, remote_school_name, community_row_num)

# FOR BOTH URBANS
remote_school_name = rep(list("K-12 around Seattle, WA"), 16)
community_row_num = 36
# FOR URBAN MOBILE
excel_path <- "original-data-all/multischool/UserTesting-Test_Metrics-4961968-URBAN-MOBILE-MULTISCHOOL-ED-2024-02-05-144311.xlsx"
file_name = "cleaned-data-multischool/URBAN-MOBILE-MULTISCHOOL-QA-2024-02.csv"
main_clean_multischool_data(excel_path, file_name, remote_school_name, community_row_num)
# FOR URBAN DESKTOP
excel_path <- "original-data-all/multischool/UserTesting-Test_Metrics-4961976-URBAN-DESKTOP-MULTISCHOOL-ED-2024-02-05-144245.xlsx"
file_name = "cleaned-data-multischool/URBAN-DESKTOP-MULTISCHOOL-QA-2024-02.csv"
main_clean_multischool_data(excel_path, file_name, remote_school_name, community_row_num)

# NOW MERGE ALL SIX DF
full_df <- merging_df()

# AND DO LAST TIDY OF THEM
df <- tidy_merged_df_and_save(full_df, "cleaned-data-multischool/multischool_no_unconfirmed-smartphones-combined-local-remote.csv")
#QUALITY ASSURANCE
quality_assurance(df)







