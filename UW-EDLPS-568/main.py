# EDLPS 568
# 2014-2022 dataset
# https://data.wa.gov/education/Report-Card-SQSS-from-2014-15-to-2021-22-School-Ye/inqc-k3vt/about_data


import pandas as pd
import matplotlib.pyplot as plt


def main():
   og_df = clean_data()
   df = og_df

   # visualize 'PercentTakingAP' scores for 'SchoolName' across 'SchoolYear'
   line_name = 'SchoolName'
   x_axis = 'SchoolYear'
   y_axis = 'PercentTakingAP'


   # TODO: temp only considering RHS scores
   # df = df[df['SchoolName'].str.contains('Roosevelt High School', case=False)].copy()
   # only high schools
   df = df[df['SchoolName'].str.contains('High', case=False)].copy()
   # only SPS # DistrictName
   df = df[df['DistrictName'].str.contains('Seattle', case=False)].copy()
    # drop NA in AP column
   df.dropna(subset=['PercentTakingAP'], inplace=True)

   # only consider 'AllGrades'
   df = df[df['GradeLevel'] == 'All Grades']
   print(df.head())
   line_graph(df, x_axis, y_axis, line_name)


def clean_data():
    csv_file_path = 'Report_Card_SQSS_from_2014-15_to_2021-22_School_Year_20240318.csv'
    df = pd.read_csv(csv_file_path)

    df['SchoolYear'] = df['SchoolYear'].str.split('-').str[1].astype(int) + 2000

    df_full_schools = df[df['StudentGroupType'] == 'AllStudents']
    return df_full_schools

def line_graph(df, x_axis, y_axis, line_name):
    grouped_data = df.groupby(line_name)

    # Create a line plot for each group
    for name, group in grouped_data:
        # print(name, group)
        # plt.plot(group[x_axis], group[y_axis], label=name)
        plt.scatter(group[x_axis], group[y_axis], label=name)


    # Set labels and title
    plt.xlabel(x_axis)
    plt.ylabel(y_axis)
    plt.title('{} vs {}'.format(y_axis, x_axis))
    plt.legend()

    # Show the plot
    plt.show()

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
