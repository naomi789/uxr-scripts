import pandas as pd
import matplotlib.pyplot as plt


def main():
    # Convert CSVs to DataFrames
    collectors = csv_to_df("CSV/CollectorList.csv")
    collector_dict = collectors.set_index("CollectorID")["Title"].to_dict()

    collectors_to_drop = ["GreatSchools"]
    df = csv_to_df("CSV/IndividualResponses.csv")
    responses = clean_data(df, collector_dict, collectors_to_drop)

    # Q2 - What percent of respondents considered only in-system schools? Considered any out-of-system schools? Considered both in-system and OOS schools?
    considered_schools = get_data_considered_school_types(responses)
    bar_graph(considered_schools, ["only OOS", "only IS", "both"],
              'Percentage of respondents who considered different school types')

    # Q2 - For what percent of respondents is each school type available?


def bar_graph(df, bars, title):
    percent = {bar: (df[bar].mean()) * 100 for bar in bars}
    fig, ax = plt.subplots()
    bars_plot = ax.bar(percent.keys(), percent.values())
    ax.bar_label(bars_plot, fmt='%.1f%%', padding=5, fontsize=10)
    ax.set_ylim(0, 100)

    ax.set_ylabel('Percentage')
    ax.set_title(title)

    plt.show()


#     percent = {}
#     for bar in bars:
#         percent[bar] = (df[bar].mean()) * 100
#
#     plt.bar(percent.keys(), percent.values())
#     plt.ylim(0, 100)
#     plt.xlabel('Columns')
#     plt.ylabel('Percentage')
#     plt.title(title)
#     plt.show()


def get_data_considered_school_types(responses):
    selected_columns = [
                           "Which of the following kinds of schools and learning opportunities did you consider/are you considering for you kid(s)? Select all that apply."] + [
                           f"Unnamed: {i}" for i in range(11, 22)]
    df_selected = responses.loc[:, responses.columns.isin(selected_columns)]

    # Set the second row as the column names, drop that row, reset index
    df_selected.columns = df_selected.iloc[0]
    df_selected = df_selected[1:]
    df_selected.reset_index(drop=True, inplace=True)

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

    all_schools = df_selected.apply(lambda row: row.tolist(), axis=1)

    df_selected["considered OOS"] = all_schools.apply(
        lambda schools: [school for school in schools if is_out_of_system.get(school) == "OOS"]
    )
    df_selected["considered IS"] = all_schools.apply(
        lambda schools: [school for school in schools if
                         is_out_of_system.get(school) != "OOS" and school in is_out_of_system]
    )

    # Create boolean columns for OOS and IS; remove no-responses
    df_selected['OOS'] = df_selected['considered OOS'].apply(bool)
    df_selected['IS'] = df_selected['considered IS'].apply(bool)
    df_selected = df_selected[~((df_selected['OOS'] == False) & (df_selected['IS'] == False))]
    df_selected['both'] = (df_selected['OOS'] & df_selected['IS'])
    df_selected['only OOS'] = (df_selected['OOS'] & ~df_selected['IS'])
    df_selected['only IS'] = (~df_selected['OOS'] & df_selected['IS'])

    return df_selected


def clean_data(df, collector_dict, collectors_to_drop):
    columns_to_drop = ["Start Date", "First Name", "Last Name", "Custom Data 1", "Email Address"]
    df = df.drop(columns=columns_to_drop,
                 errors='ignore')

    # Only keep data where respondent is a parent/caregiver
    filter_column = "Are you a parent or caregiver (e.g., step parent, foster parent, guardian) of a K-12 aged student in the US?"
    df = df[df[filter_column] != "No"]

    # Update to use the names of collectors (not unique IDs)
    df["Collector ID"] = df["Collector ID"].map(collector_dict)
    df = df[~df["Collector ID"].isin(collectors_to_drop)]

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
