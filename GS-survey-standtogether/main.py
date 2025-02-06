import pandas as pd
import matplotlib.pyplot as plt


def main():
    run_everything = True
    # Convert CSVs to DataFrames
    collectors = csv_to_df("CSV/CollectorList.csv")
    collector_dict = collectors.set_index("CollectorID")["Title"].to_dict()

    collectors_to_drop = ["GreatSchools"]
    df = csv_to_df("CSV/IndividualResponses.csv")
    responses = clean_data(df, collector_dict, collectors_to_drop)

    # Q2 - What percent of respondents considered only in-system schools? Considered any out-of-system schools? Considered both in-system and OOS schools?
    if run_everything:
        considered_schools = get_data_considered_school_types(responses)
        bar_graph(considered_schools, 'bool', ["only OOS", "only IS", "both"],
                  'Percentage of respondents who considered different school types')

    # Q2 - For what percent of respondents is each school type available?
    available_schools = get_data_available_schools(responses)
    school_types = available_schools.columns.tolist()
    school_types.remove("Respondent ID")
    school_types.remove("None of the above")
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
    bar_graph(available_schools, 'strings', school_types,
              "Percentage of respondents who reported this school type was available", label_dict)


def bar_graph(df, data_type, bars, title, label_dict = None):
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

    ax.set_xticklabels([label_dict.get(label, label) for label in percent.keys()], rotation=90, va='top', fontsize=10, ha='center')
    ax.tick_params(axis='x', which='both', length=0, pad=-250)


    ax.set_ylim(0, 100)
    ax.set_ylabel('Percentage')
    ax.set_title(title)
    plt.show()
    pass


def get_data_available_schools(responses):
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


def get_data_considered_school_types(responses):
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
    columns_to_check = ['Unnamed: 21', 'Unnamed: 35', 'Unnamed: 48']
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
