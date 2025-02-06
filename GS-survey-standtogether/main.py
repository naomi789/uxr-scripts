import pandas as pd
import matplotlib.pyplot as plt
from collections import defaultdict


def main():
    run_everything = False
    # Convert CSVs to DataFrames
    collectors = csv_to_df("CSV/CollectorList.csv")
    collector_dict = collectors.set_index("CollectorID")["Title"].to_dict()

    collectors_to_drop = ["GreatSchools"]
    df = csv_to_df("CSV/IndividualResponses.csv")
    responses = clean_data(df, collector_dict, collectors_to_drop)

    # SET CONSTANTS
    label_dict = {
        "Apprenticeship program": "Apprenticeship program",
        "Charter schools": "Charter school(s)",
        "Collaborative learning center": "Collaborative learning center",
        "Collegiate model school (e.g., college-level classes, dual-enrollment)": "Collegiate Model (e.g., dual-enrollment)",
        "Homeschool, homeschooling collective": "Homeschooling",
        "Hybrid school, online school": "Hybrid/Online",
        "Independent study program": "Independent study program",
        "Learning pod, microschool, one-room schoolhouse": "Learning pod, Microschool, etc.",
        "Private schools": "Private school(s)",
        "Public schools": "Public",
        "Study abroad or travel-based learning": "Study abroad, etc. "}

    # Q2 - What percent of respondents considered only in-system schools? Considered any out-of-system schools? Considered both in-system and OOS schools?
    if run_everything:
        considered_schools = get_considered_school_types(responses)
        bar_graph(considered_schools, 'bool', ["only OOS", "only IS", "both"],
                  'Percentage of respondents who considered different school types')

    # Q2 - For what percent of respondents is each school type available?
    if run_everything:
        available_schools = get_available_schools(responses)
        school_types = available_schools.columns.tolist()
        school_types.remove("Respondent ID")
        school_types.remove("None of the above")
        bar_graph(available_schools, 'strings', school_types,
                  "Percentage of respondents who reported this school type was available", label_dict)

    # Are the respondents who are more satisfied with available info the respondents who had more info available?
    if run_everything:
        available_data = get_availability_info(responses)
        histogram2d(available_data[['Count', 'Satisfaction']])

    # Are respondents looking for a given school attribute picking similar kinds of schools?
    school_type_and_reasons = get_school_type_and_reasons(responses)
    flow_chart(school_type_and_reasons, label_dict)
    # For people who pick a given school type, what were their reasons?






def flow_chart(school_type_and_reasons, label_dict):
    df = school_type_and_reasons.drop(columns=['Respondent ID'])
    school_type = 'What kind of school does your K-12 aged child currently attend? If you have more than one K-12 aged children, pick the option that applies for your oldest child.'
    reasons = df.columns.tolist()
    reasons.remove(school_type)
    reasons.remove('Other (please specify)')
    for reason in reasons:
        filtered_df = df[df[reason] != '']
        counts = filtered_df[school_type].value_counts()
        counts_df = pd.DataFrame(counts)
        counts_df = counts_df.rename_axis('School Type').rename(
            columns={school_type: 'Count'})
        counts_df['Percentage'] = (counts_df['Count'] / counts_df['Count'].sum() * 100).round(1)
        counts_df['Percentage'] = pd.to_numeric(counts_df['Percentage'])

        fig, ax = plt.subplots()
        plt.bar(counts_df.index, counts_df['Percentage'])
        plt.ylim(0, 100)
        plt.title(reason, fontsize=16)
        plt.xlabel('School Type', fontsize=12)
        plt.ylabel('Percentage (%)', fontsize=12)
        ax.set_xticklabels([label_dict.get(label, label) for label in counts_df.index], rotation=90, va='top',
                           fontsize=10,
                           ha='center')
        ax.tick_params(axis='x', which='both', length=0, pad=-250)

        for index, value in enumerate(counts_df['Percentage']):
            plt.text(index, value + 1, f"{value}%", ha='center', fontsize=10)
        plt.tight_layout()
        plt.show()


def get_school_type_and_reasons(responses):
    school_type = 'What kind of school does your K-12 aged child currently attend? If you have more than one K-12 aged children, pick the option that applies for your oldest child.'
    reasons = 'What were the primary reasons you selected this kind of school? If you have more than one K-12 aged child, please think about your oldest.'
    columns_to_keep = ["Respondent ID", school_type,
                       reasons] + [
                          f"Unnamed: {i}" for i in range(38, 49)]
    df = responses[columns_to_keep]
    df = df[df[school_type] != '']
    # Set the second row as the column names, drop that row, reset index
    df.columns = df.iloc[0]
    df = df[1:]
    df.columns.values[0] = 'Respondent ID'
    df.columns.values[1] = school_type
    df.reset_index(drop=True, inplace=True)
    return df


def histogram2d(df):
    H, xedges, yedges, _ = plt.hist2d(df['Count'], df['Satisfaction'], bins=(11, 5), cmap='Blues')
    x_ticks = list(range(int(xedges.min()), int(xedges.max()) + 1))
    plt.xticks(x_ticks)
    plt.xlabel('Count')
    y_ticks = list(range(int(yedges.min()), int(yedges.max()) + 1))
    plt.yticks(y_ticks)
    plt.ylabel('Satisfaction')
    plt.title('2D Histogram of Count vs Satisfaction')
    plt.colorbar(label='Density')
    plt.show()


def get_availability_info(responses):
    og_satisfaction_column = "How satisfied are you with the information available to you about the kinds of schools that you considered for your kid(s)?"
    columns_to_keep = ["Respondent ID",
                       "What information is available to you about K-12 schools? Select all that apply.",
                       og_satisfaction_column] + [
                          f"Unnamed: {i}" for i in range(52, 61)]
    df = responses[columns_to_keep]
    df = df[df[og_satisfaction_column] != '']
    # Set the second row as the column names, drop that row, reset index
    df.columns = df.iloc[0]
    df = df[1:]
    df.columns.values[0] = 'Respondent ID'
    df.columns.values[2] = og_satisfaction_column
    df.reset_index(drop=True, inplace=True)

    school_info_types = df.columns.tolist()
    school_info_types.remove('Respondent ID')
    school_info_types.remove(og_satisfaction_column)

    df['Count'] = df[school_info_types].apply(lambda row: sum(1 for x in row if x != ""), axis=1)
    df['Satisfaction'] = df[og_satisfaction_column].str[0]
    df['Count'] = pd.to_numeric(df['Count'], errors='coerce').astype('Int64')
    df['Satisfaction'] = pd.to_numeric(df['Satisfaction'], errors='coerce').astype('Int64')

    return df


def bar_graph(df, data_type, bars, title, label_dict=None):
    percent = {}
    fig, ax = plt.subplots()
    if data_type == "bool":
        percent = {bar: (df[bar].mean()) * 100 for bar in bars}
        label_dict = {bar: bar for bar in bars}

    elif data_type == "strings":
        for bar in bars:
            value_counts = df[bar].value_counts(normalize=True) * 100
            percent[bar] = value_counts.get(bar, 0)

    bars_plot = ax.bar(percent.keys(), percent.values())
    ax.bar_label(bars_plot, fmt='%.0f%%', fontsize=10)

    # ax.set_xticklabels(percent.keys(), rotation=90, va='top', fontsize=10, ha='center')

    ax.set_xticklabels([label_dict.get(label, label) for label in percent.keys()], rotation=90, va='top', fontsize=10,
                       ha='center')
    ax.tick_params(axis='x', which='both', length=0, pad=-250)

    ax.set_ylim(0, 100)
    ax.set_ylabel('Percentage')
    ax.set_title(title)
    plt.show()


def get_available_schools(responses):
    selected_columns = [
                           "Respondent ID",
                           "Which of the following kinds of schools and learning opportunities did you consider/are you considering for you kid(s)? Select all that apply.",
                           "Aside from the options you considered, does your community have any other kinds of K-12 schools or learning opportunities that you are aware of? Select all that apply."] + [
                           f"Unnamed: {i}" for i in range(11, 36) if i != 22]
    small_df = responses.loc[:, responses.columns.isin(selected_columns)]
    # Set the second row as the column names, drop that row, reset index
    small_df.columns = small_df.iloc[0]
    small_df = small_df[1:]
    small_df.columns.values[0] = 'Respondent ID'
    small_df.reset_index(drop=True, inplace=True)

    small_df.drop(columns=["Other (please specify)", "[Insert text from Other]"], inplace=True)
    df_merged = small_df.groupby(small_df.columns, axis=1, sort=False).first()

    return df_merged


def get_considered_school_types(responses):
    selected_columns = [
                           "Which of the following kinds of schools and learning opportunities did you consider/are you considering for you kid(s)? Select all that apply."] + [
                           f"Unnamed: {i}" for i in range(11, 22)] + ["Respondent ID"]
    small_df = responses.loc[:, responses.columns.isin(selected_columns)]

    # Set the second row as the column names, drop that row, reset index
    small_df.columns = small_df.iloc[0]
    small_df = small_df[1:]
    small_df.columns.values[0] = 'Respondent ID'

    small_df.reset_index(drop=True, inplace=True)

    is_out_of_system = {
        "Apprenticeship program": "OOS",
        "Charter schools": "charter",
        "Collaborative learning center": "OOS",
        "Collegiate model school (e.g., college-level classes, dual-enrollment)": "OOS",
        "Homeschool, homeschooling collective": "OOS",
        "Hybrid school, online school": "OOS",
        "Independent study program": "OOS",
        "Learning pod, microschool, one-room schoolhouse": "OOS",
        "Private schools": "private",
        "Public schools": "public",
        "Study abroad or travel-based learning": "OOS",
        "Other (please specify)": "OOS"
    }

    # all_schools = df_selected.apply(lambda row: row.tolist(), axis=1)
    all_schools = small_df.drop(columns=['Respondent ID']).apply(lambda row: row.tolist(), axis=1)

    small_df["considered OOS"] = all_schools.apply(
        lambda schools: [school for school in schools if is_out_of_system.get(school) == "OOS"]
    )
    small_df["considered IS"] = all_schools.apply(
        lambda schools: [school for school in schools if
                         is_out_of_system.get(school) != "OOS" and school in is_out_of_system]
    )

    # Create boolean columns for OOS and IS; remove no-responses
    small_df['OOS'] = small_df['considered OOS'].apply(bool)
    small_df['IS'] = small_df['considered IS'].apply(bool)
    small_df = small_df[~((small_df['OOS'] == False) & (small_df['IS'] == False))]
    small_df['both'] = (small_df['OOS'] & small_df['IS'])
    small_df['only OOS'] = (small_df['OOS'] & ~small_df['IS'])
    small_df['only IS'] = (~small_df['OOS'] & small_df['IS'])

    return small_df


def clean_data(df, collector_dict, collectors_to_drop):
    df.columns = df.columns.str.strip()  # Remove leading/trailing spaces
    columns_to_drop = ["Start Date", "First Name", "Last Name", "Custom Data 1", "Email Address"]
    df = df.drop(columns=columns_to_drop,
                 errors='ignore')

    # Only keep data where respondent is a parent/caregiver
    filter_column = "Are you a parent or caregiver (e.g., step parent, foster parent, guardian) of a K-12 aged student in the US?"
    df = df[df[filter_column] != "No"]

    # only keep data if they answered the third question
    df = df.dropna(subset=[
        "What kind of school does your K-12 aged child currently attend? If you have more than one K-12 aged children, pick the option that applies for your oldest child."])

    # Update to use the names of collectors (not unique IDs)
    df["Collector ID"] = df["Collector ID"].map(collector_dict)
    df = df[~df["Collector ID"].isin(collectors_to_drop)]

    # Remove data from bad actors
    columns_to_check = ['Unnamed: 21', 'Unnamed: 35', 'Unnamed: 48', 'Unnamed: 60']
    values_to_drop = ['Spy', 'Spy Schools', 'BIG BLACK OILY MEN', 'BIG OILY MEN', 'My Project 65443', 'im a kid.', 'hi',
                      'drippy', 'alien school on mars', 'ZAKAYLA GILLESPIE', 'Swddv. SdssstszadrfsasdwqsZzz zx',
                      'other,pjap', 'College', 'no clue', 'ALIENS=EPIC', 'UFO AND ALIENS',
                      'you need rocket ship to go to mars']
    df = df[~df[columns_to_check].apply(lambda row: row.isin(values_to_drop).any(), axis=1)]
    df.reset_index(drop=True, inplace=True)
    df = df.fillna("")

    return df


def csv_to_df(file_path):
    try:
        return pd.read_csv(file_path)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None


main()
