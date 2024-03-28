# EDLPS 568
# 2014-2022 dataset
# https://data.wa.gov/education/Report-Card-SQSS-from-2014-15-to-2021-22-School-Ye/inqc-k3vt/about_data


import pandas as pd
import matplotlib.pyplot as plt


def main():
    df_original = clean_data()
    df_state_level = df_original[df_original['OrganizationLevel'] == 'State']
    df_district_level = df_original[df_original['OrganizationLevel'] == 'District']
    df_school_level = cleaner(df_original)

    # ignore subgroups of students
    df_aggregate = df_school_level[df_school_level['StudentGroupType'] == 'AllStudents']
    per_school(df_aggregate, 'GraphEachSchool/')
    state_avg(df_aggregate, 'GraphStateAverage/')

    # visualize each subgroup
    aggregates = ['Gender', 'FederalRaceEthnicity', 'EnglishLearner', 'Foster', 'HiCAP', 'Homeless',
                  'Income', 'Migrant', 'MilitaryFamily', 'Section504', 'SWD']
    measurements = ['Ninth Grade on Track', 'Regular Attendance']
    per_group_of_students(measurements, aggregates, df_school_level)

    # per district
    df_district_level = df_district_level[df_district_level['StudentGroup'] == 'All Students']
    df_king_county_only = df_district_level[df_district_level['County'] == 'King']
    visualize_district(df_king_county_only, measurements, 'DistrictName')
    df_public_districts = df_district_level[df_district_level[''] == '']

def visualize_district(df, measurements, line_name):
    x_axis = 'SchoolYear'
    y_axis = 'ValueMeasurement'
    folder = 'ComparingDistricts/'
    for measurement in measurements:
        title = 'DistrictLevel' + measurement.replace(" ", "")
        df_option = df[df['Measures'] == measurement]
        df_option = df_option[df_option['GradeLevel'] == 'All Grades']
        df_option = df_option[df_option['StudentGroupType'] == 'AllStudents']
        line_graph(df_option, x_axis, y_axis, line_name, title, folder)


def per_group_of_students(measurements, aggregates, df):
    x_axis = 'SchoolYear'
    y_axis = 'ValueMeasurement'
    folder = 'ComparingSubgroupsOfStudents/'
    for measurement in measurements:
        for option in aggregates:
            title = (option + measurement).replace(" ", "")
            df_option = df[df['StudentGroupType'] == option]
            df_option = df_option[df_option['Measures'] == measurement]
            df_with_avg = df_option.groupby(['SchoolYear', 'StudentGroup'])['ValueMeasurement'].mean().reset_index()
            df_pivot = df_with_avg.pivot(index='SchoolYear', columns='StudentGroup', values='ValueMeasurement')
            aggregate_line_graph(df_pivot, x_axis, y_axis, title, folder)


def aggregate_line_graph(df, x_axis, y_axis, title, folder):
    df.plot(marker='o')
    # Set plot labels and title
    plt.xlabel(x_axis)
    plt.ylabel(y_axis)
    plt.title('{} vs {} ({})'.format(y_axis, x_axis, title))
    # Show the plot
    plt.legend()
    # plt.show()
    title = folder + title + '.png'
    plt.savefig(title)

def clean_data():
    csv_file_path = 'Report_Card_SQSS_from_2014-15_to_2021-22_School_Year_20240318.csv'
    df = pd.read_csv(csv_file_path)
    # cast to int
    df['SchoolYear'] = df['SchoolYear'].str.split('-').str[1].astype(int) + 2000
    # drop if 'Numerator' or 'Denominator' is NAN
    df.dropna(subset=['Numerator'], inplace=True)
    df.dropna(subset=['Denominator'], inplace=True)
    # add new column
    df.loc[:, 'ValueMeasurement'] = df['Numerator'] / df['Denominator']
    return df

def cleaner(df):
    # ignore subgroups by grade
    df = df[df['GradeLevel'] == 'All Grades']
    # only keep if row contains SchoolName
    df.dropna(subset=['SchoolName'], inplace=True)
    # df.loc[df['SchoolName'].notnull(), :]  # Selecting rows where 'SchoolName' is not null
    # df.dropna(subset=['SchoolName'], inplace=True)  # Dropping rows inplace
    # only keep if SchoolCode is not NAN
    df.dropna(subset=['SchoolCode'], inplace=True)
    # df.loc[df['SchoolCode'].notnull(), :]  # Selecting rows where 'SchoolName' is not null
    # df.dropna(subset=['SchoolCode'], inplace=True)  # Dropping rows inplace
    return df

def line_graph(df, x_axis, y_axis, line_name, title, folder):
    grouped_data = df.groupby(line_name)
    # make graph
    plt.figure()
    for name, group in grouped_data:
        plt.plot(group[x_axis], group[y_axis], label=name)

    # Set labels and title
    plt.xlabel(x_axis)
    plt.ylabel(y_axis)
    plt.title('{} vs {} ({})'.format(y_axis, x_axis, line_name))
    plt.legend()

    title = folder + title + '.png'
    plt.savefig(title)


def basic_line_graph(df, x_axis, y_axis, title, folder):
    plt.figure()
    plt.plot(df[x_axis], df[y_axis], label=y_axis) #
    plt.xlabel(x_axis)
    plt.ylabel(y_axis)
    plt.title('{} vs {} ({})'.format(y_axis, x_axis, title))
    plt.legend()
    title = folder + title + '.png'
    plt.savefig(title)

def per_school(df, folder):
    # 9TH GRADE ON-TRACK
    line_name = 'SchoolName'
    x_axis = 'SchoolYear'
    y_axis = 'ValueMeasurement'
    df_9 = df[df['Measures'] == 'Ninth Grade on Track']
    title = '9GradePerSchool'
    line_graph(df_9, x_axis, y_axis, line_name, title, folder)

    # REGULAR ATTENDANCE
    line_name = 'SchoolName'
    x_axis = 'SchoolYear'
    y_axis = 'ValueMeasurement'
    df_attendance = df[df['Measures'] == 'Regular Attendance']
    title = 'RegAttendancePerSchool'
    line_graph(df_attendance, x_axis, y_axis, line_name, title, folder)


def state_avg(df, folder):
    # 9TH GRADE ON TRACK
    x_axis = 'SchoolYear'
    y_axis = 'AverageValueMeasurement'
    title = '9GradeAverage'
    df_9 = df[df['Measures'] == 'Ninth Grade on Track']
    average_value_measurement = df_9.groupby('SchoolYear')['ValueMeasurement'].mean()
    new_df = average_value_measurement.reset_index(name='AverageValueMeasurement')
    basic_line_graph(new_df, x_axis, y_axis, title, folder)

    # REGULAR ATTENDANCE
    x_axis = 'SchoolYear'
    y_axis = 'AverageValueMeasurement'
    title = 'RegAttendanceAverage'
    df_attendance = df[df['Measures'] == 'Regular Attendance']
    average_value_measurement = df_attendance.groupby('SchoolYear')['ValueMeasurement'].mean()
    new_df = average_value_measurement.reset_index(name='AverageValueMeasurement')
    basic_line_graph(new_df, x_axis, y_axis, title, folder)


main()

# TRASH
# unique = df[''].unique()
# unique_names = df['SchoolName'].unique()
# print(unique_names)

# print(df.columns)
# Index(['SchoolYear', 'OrganizationLevel', 'County', 'ESDName',
#        'ESDOrganizationID', 'DistrictCode', 'DistrictName',
#        'DistrictOrganizationId', 'SchoolCode', 'SchoolName',
#        'SchoolOrganizationid', 'CurrentSchoolType', 'StudentGroupType',
#        'StudentGroup', 'GradeLevel', 'Measures', 'Suppression', 'Numerator',
#        'Denominator', 'NumberTakingAP', 'PercentTakingAP', 'NumberTakingIB',
#        'PercentTakingIB', 'NumberTakingCollegeInTheHighSchool',
#        'PercentTakingCollegeInTheHighSchool', 'NumberTakingCambridge',
#        'PercentTakingCambridge', 'NumberTakingRunningStart',
#        'PercentTakingRunningStart', 'NumberTakingCTETechPrep',
#        'PercentTakingCTETechPrep', 'DataAsOf'],
#       dtype='object')

# df_original['StudentGroupType'].unique()
# ['AllStudents' 'EnglishLearner' 'FederalRaceEthnicity' 'Foster' 'Gender'
#  'HiCAP' 'Homeless' 'Income' 'Migrant' 'MilitaryFamily' 'Section504' 'SWD']

# na_count_measures = df['Measures'].isna().sum()
# print(na_count_measures)

# # check if duplicates of school names
# unique_years = df_9['SchoolYear'].unique()
# unique_names = df['SchoolName'].unique()
# count_rows = df_9.shape[0]
# print(unique_years, unique_names, count_rows)
# df_9 = df_9[df_9['DistrictName'] == 'Seattle School District No. 1']
# df_9.to_csv('df_9.csv', index=False)