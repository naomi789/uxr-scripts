library(readxl)

# EVERYTHING TOGETHER
excel_path <- "UserTesting-Test_Metrics-4942714-Understand_their_kid_has_a_sch-2023-12-18-100334.xlsx"
details <- read_excel(path = excel_path, sheet = "Session details")
metrics <- read_excel(path = excel_path, sheet = "Metrics")
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
df <- df %>% row_to_names(row_number = 1)
file_name = "ANY-SATISFACTION-COMMUNICATING-2023-12.csv"
write.csv(df, file_name, row.names=FALSE)

# SATISFIED/VERY SATISFIED
excel_path <- "UserTesting-Test_Metrics-4942704-Very_satisfiedsatisfied_with_d-2023-12-18-104626.xlsx"
details <- read_excel(path = excel_path, sheet = "Session details")
metrics <- read_excel(path = excel_path, sheet = "Metrics")
income = details[20,][1:12]
satis_district = metrics[18,][1:12]
satis_school = metrics[22,][1:12]
satis_teacher = metrics[26,][1:12]
district_relationship = metrics[30,][1:12]
district_freq = metrics[34,][1:12]
district_method = metrics[51,][1:12]
district_topics = metrics[55,][1:12]
school_relationship = metrics[63,][1:12]
school_freq = metrics[67,][1:12]
school_method = metrics[84,][1:12]
school_topics = metrics[88,][1:12]
district_url = metrics[128,][1:12]
list_data <- list(unlist(income), unlist(satis_district), 
                  unlist(satis_school), unlist(satis_teacher), unlist(school_relationship), 
                  unlist(school_freq), unlist(school_method), unlist(school_topics), 
                  unlist(district_relationship), unlist(district_freq),
                  unlist(district_method), unlist(district_topics), unlist(district_url))
df <- as.data.frame(list_data)
df <- df %>% row_to_names(row_number = 1)
file_name = "VERYSATISFIED_OR_SATISFIED-2023-12.csv"
write.csv(df, file_name, row.names=FALSE)


# NOT SATISFIED/VERY NOT SATISFIED
excel_path <- "UserTesting-Test_Metrics-4941153-Not_satisfied_with_districts_c-2023-12-18-104612.xlsx"
details <- read_excel(path = excel_path, sheet = "Session details")
metrics <- read_excel(path = excel_path, sheet = "Metrics")
income = details[20,][1:12]
satis_district = metrics[18,][1:12]
satis_school = metrics[22,][1:12]
satis_teacher = metrics[26,][1:12]
district_relationship = metrics[30,][1:12]
district_freq = metrics[34,][1:12]
district_method = metrics[51,][1:12]
district_topics = metrics[55,][1:12]
school_relationship = metrics[63,][1:12]
school_freq = metrics[67,][1:12]
school_method = metrics[84,][1:12]
school_topics = metrics[88,][1:12]
district_url = metrics[128,][1:12]
list_data <- list(unlist(income), unlist(satis_district), 
                  unlist(satis_school), unlist(satis_teacher), unlist(school_relationship), 
                  unlist(school_freq), unlist(school_method), unlist(school_topics), 
                  unlist(district_relationship), unlist(district_freq),
                  unlist(district_method), unlist(district_topics), unlist(district_url))
df <- as.data.frame(list_data)
df <- df %>% row_to_names(row_number = 1)
file_name = "VERYNOTSATISFIED_OR_NOT_SATISFIED-2023-12.csv"
write.csv(df, file_name, row.names=FALSE)

