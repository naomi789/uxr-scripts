# EDLPS 568
# 2014-2022 dataset
# https://data.wa.gov/education/Report-Card-SQSS-from-2014-15-to-2021-22-School-Ye/inqc-k3vt/about_data


import pandas as pd
import matplotlib.pyplot as plt


def main():
   df_original = clean_data()

   # ignore subgroups of students
   df_aggregate = df_original[df_original['StudentGroupType'] == 'AllStudents']
   per_school(df_aggregate)
   state_avg(df_aggregate)

   # visualize each subgroup
   aggregates = ['Gender']
   measurements = ['Ninth Grade on Track', 'Regular Attendance']
   x_axis = 'SchoolYear'
   y_axis = 'ValueMeasurement'
   for measurement in measurements:
       for option in aggregates:
           title = measurement + option
           df = df_original[df_original['StudentGroupType'] == option]
           df = df[df['Measures'] == measurement]
           df_avg = df.groupby(['SchoolYear', 'StudentGroup'])['ValueMeasurement'].mean().reset_index()
           df_pivot = df_avg.pivot(index='SchoolYear', columns='StudentGroup', values='ValueMeasurement')
           aggregate_line_graph(df_pivot, x_axis, y_axis, title)




def aggregate_line_graph(df, x_axis, y_axis, title):
    df.plot(marker='o')
    # Set plot labels and title
    plt.xlabel(x_axis)
    plt.ylabel(y_axis)
    plt.title('{} vs {} ({})'.format(y_axis, x_axis, title))
    # Show the plot
    plt.legend()
    # plt.show()
    title = title + '.png'
    plt.savefig(title)

def clean_data():
    csv_file_path = 'Report_Card_SQSS_from_2014-15_to_2021-22_School_Year_20240318.csv'
    df = pd.read_csv(csv_file_path)
    # cast to int
    df['SchoolYear'] = df['SchoolYear'].str.split('-').str[1].astype(int) + 2000

    # ignore subgroups by grade
    df = df[df['GradeLevel'] == 'All Grades']
    # only keep if row contains SchoolName
    df.dropna(subset=['SchoolName'], inplace=True)
    # only keep if SchoolCode is not NAN
    df.dropna(subset=['SchoolCode'], inplace=True)
    # drop if 'Numerator' or 'Denominator' is NAN
    df.dropna(subset=['Numerator'], inplace=True)
    df.dropna(subset=['Denominator'], inplace=True)

    # add new column
    df.loc[:, 'ValueMeasurement'] = df['Numerator'] / df['Denominator']

    return df

def line_graph(df, x_axis, y_axis, line_name, title):
    grouped_data = df.groupby(line_name)
    for name, group in grouped_data:
        plt.plot(group[x_axis], group[y_axis], label=name)

    # Set labels and title
    plt.figure()
    plt.xlabel(x_axis)
    plt.ylabel(y_axis)
    plt.title('{} vs {} ({})'.format(y_axis, x_axis, line_name))
    plt.legend()

    title = title + '.png'
    plt.savefig(title)


def basic_line_graph(df, x_axis, y_axis, title):
    plt.figure()
    plt.plot(df[x_axis], df[y_axis]) #
    plt.xlabel(x_axis)
    plt.ylabel(y_axis)
    plt.title('{} vs {} ({})'.format(y_axis, x_axis, title))
    plt.legend()
    title = title + '.png'
    plt.savefig(title)

def per_school(df):
    # 9TH GRADE ON-TRACK
    line_name = 'SchoolName'
    x_axis = 'SchoolYear'
    y_axis = 'ValueMeasurement'
    df_9 = df[df['Measures'] == 'Ninth Grade on Track']
    title = '9GradePerSchool'
    line_graph(df_9, x_axis, y_axis, line_name, title)

    # REGULAR ATTENDANCE
    line_name = 'SchoolName'
    x_axis = 'SchoolYear'
    y_axis = 'ValueMeasurement'
    df_attendance = df[df['Measures'] == 'Regular Attendance']
    title = 'RegAttendancePerSchool'
    line_graph(df_attendance, x_axis, y_axis, line_name, title)


def state_avg(df):
    # 9TH GRADE ON TRACK
    x_axis = 'SchoolYear'
    y_axis = 'AverageValueMeasurement'
    title = '9GradeAverage'
    df_9 = df[df['Measures'] == 'Ninth Grade on Track']
    average_value_measurement = df_9.groupby('SchoolYear')['ValueMeasurement'].mean()
    new_df = average_value_measurement.reset_index(name='AverageValueMeasurement')
    basic_line_graph(new_df, x_axis, y_axis, title)

    # REGULAR ATTENDANCE
    x_axis = 'SchoolYear'
    y_axis = 'AverageValueMeasurement'
    title = 'RegAttendanceAverage'
    df_attendance = df[df['Measures'] == 'Regular Attendance']
    average_value_measurement = df_attendance.groupby('SchoolYear')['ValueMeasurement'].mean()
    new_df = average_value_measurement.reset_index(name='AverageValueMeasurement')
    basic_line_graph(new_df, x_axis, y_axis, title)


main()

# TRASH
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


# na_count_measures = df['Measures'].isna().sum()
# print(na_count_measures)

# # check if duplicates of school names
# unique_years = df_9['SchoolYear'].unique()
# unique_names = df['SchoolName'].unique()
# count_rows = df_9.shape[0]
# print(unique_years, unique_names, count_rows)
# df_9 = df_9[df_9['DistrictName'] == 'Seattle School District No. 1']
# df_9.to_csv('df_9.csv', index=False)