import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from pyzipcode import ZipCodeDatabase
import folium



def main():
    run_everything = False
    # Convert CSVs to DataFrames
    collectors = csv_to_df("CSV/CollectorList.csv")
    collector_dict = collectors.set_index("CollectorID")["Title"].to_dict()

    collectors_to_drop = ["GreatSchools"]
    df = csv_to_df("CSV/IndividualResponses.csv")
    responses = clean_data(df, collector_dict, collectors_to_drop)

    # SET CONSTANTS
    short_school_types_dict = {
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
    short_reason_dict = {
        "Academic excellence (e.g., high test scores, college acceptance ratios)": "Academic excellence",
        "Classes, curriculums, programs (e.g., electives, sports, language immersion, STEM, AP/IB classes)": "Classes, curriculums, programs",
        "Excellent teachers (based on reviews, credentials, or reputation)": "Excellent teachers",
        "Financial factors (e.g., affordability of tuition or extracurriculars, financial aid, scholarships)": "Financial factors",
        "Location (convenience, safety, transportation)": "Location",
        "School culture & safety (e.g., bullying prevention, disciplinary policies, diversity & inclusion, mental health support, sense of community)": "Culture & safety",
        "Recommendation from a trusted source (e.g., family, friends, educators)": "Recommendations",
        "Smaller class sizes or individualized attention": "Class sizes",
        "Special services or support (e.g., IEP/504 policies, resources, specialists)": "Special services",
        "Teaching styles or philosophies (e.g., Montessori, Waldorf, unschooling, project-based learning)": "Teaching styles",
        "Values-based education (e.g., cultural instruction, religious education)": "Values-based instruction"
    }

    if run_everything:
        time_df = responses[["Collector ID", "End Date"]]
        # collector_type_time(time_df, "Week")
        crazyegg_df = time_df[time_df["Collector ID"] == "CrazyEgg"]
        # time_responses(crazyegg_df, "Date")
        # time_responses(crazyegg_df, "Week")
        box_whisker(crazyegg_df, "days")
        box_whisker(df, "hours")

    #  What percent of respondents considered only in-system schools? Considered any out-of-system schools? Considered both in-system and OOS schools?
    if run_everything:
        considered_schools = get_considered_school_types(responses)
        bar_graph(considered_schools, 'bool', ["only OOS", "only IS", "both"],
                  'Percentage of respondents who considered different school types')

    #  For what percent of respondents is each school type available?
    if run_everything:
        available_schools = get_available_schools(responses)
        school_types = available_schools.columns.tolist()
        school_types.remove("Respondent ID")
        school_types.remove("None of the above")
        bar_graph(available_schools, 'strings', school_types,
                  "Percentage of respondents who reported this school type was available", short_school_types_dict)

    #  Are the respondents who are more satisfied with available info the respondents who had more info available?
    if run_everything:
        available_data = get_availability_info(responses)
        x = 'Count'
        y = 'Satisfaction'
        histogram2d(available_data[[x, y]], x, y, '2D Histogram of Count vs Satisfaction')

    #  Comparing school type vs. reason to pick school type
    if run_everything:  # run_everything
        school_type_and_reasons = get_school_type_and_reasons(responses)
        # Given reason(s), what school type was picked?
        given_type_graph_reasons(school_type_and_reasons, short_school_types_dict)
        # given school type, what were the reasons?
        given_reasons_graph_type(school_type_and_reasons, short_reason_dict)

    #  Are respondents who pick a given school type more likely to say it was easy/hard to pick their school?
    if run_everything:
        school_type_choice_ease = get_type_ease(responses)
        x = 'Numeric School Type'
        y = 'Ease'
        school_type_choice_ease[x] = pd.Categorical(school_type_choice_ease['School Type']).codes
        x_axis_key = dict(enumerate(pd.Categorical(school_type_choice_ease['School Type']).categories))

        histogram2d(school_type_choice_ease[[x, y]], x, y, '2D Histogram of School Type vs Ease of Choice', x_axis_key)

    #  Are respondents who pick a given school type more likely to be more/less satisfied with the amount of information?
    if run_everything:
        type_satisfaction = get_type_satisfaction(responses)
        x = 'Numeric School Type'
        y = 'Satisfaction'
        type_satisfaction[x] = pd.Categorical(type_satisfaction['School Type']).codes
        categorical_key = dict(enumerate(pd.Categorical(type_satisfaction['School Type']).categories))
        histogram2d(type_satisfaction[[x, y]], x, y, '2D Histogram of School Type vs Satisfaction with Info',
                    categorical_key)

    # Make the original graphs, but with cleaned data
    if run_everything:
        update_survey_monkey_graphs(responses, short_school_types_dict)

    if run_everything:
        zip_data_viz(responses)

    if run_everything:
        df_type_impression = get_choice_impression(responses)
        visualize_type_impression(df_type_impression, "selected school", short_school_types_dict)

    # TODO: [STILL NEED TO GRAPH: any correlation between school type picked & confidence in choice?]
    long_question = "Do you feel confident that you made the right choice? If you have more than one K-12 aged child, please think about your oldest."
    short_question = "confidence picking"


def visualize_type_impression(df, col_name, label_dict):
    df_answers = df.drop(columns=['Respondent ID'])

    # chart of what public school parents said
    school_type = "Public schools"
    df_public = df_answers[df_answers[col_name] == school_type]
    df_public = df_public.drop(columns=[col_name])
    grid_response_graph(df_public, col_name, label_dict, f"What parents of students at {school_type} schools said")

    # chart of what non-public school parents said
    df_non_public = df_answers[df_answers[col_name] != "Public schools"]
    df_non_public = df_non_public.drop(columns=[col_name])
    school_type = "Non Public"
    grid_response_graph(df_non_public, col_name, label_dict, f"What parents of students at {school_type} schools said")

    # chart of what % of users said [some answer] for their impression of each school
    df_answers = df.drop(columns=['Respondent ID', col_name])
    for impression in ["1 - Negative", "2 - Neutral", "3 - Positive", "N/A - I don’t know", ]:
        graph_title = f"Said '{impression}' when asked about their impression of these schools"
        impression_viz(df_answers, col_name, graph_title, impression, label_dict)


def impression_viz(df, school_type, graph_title, impression, label_dict):
    # Count occurrences of a given impression in each column
    counts = df.apply(lambda col: col[col == impression].count())
    df_counts = counts.to_frame().rename(columns={0: 'Count'})
    row_count = len(df)
    df_counts['Percentage'] = (df_counts['Count'] / row_count * 100).round(1)
    df_counts['Percentage'] = pd.to_numeric(df_counts['Percentage'])
    # create a new column using the index, then re-index
    df_counts[school_type] = df_counts.index
    bar_graph3(df_counts, school_type, "kinds of schools",
               graph_title, label_dict)


def get_choice_impression(df):
    long_choice = "What kind of school does your K-12 aged child currently attend? If you have more than one K-12 aged children, pick the option that applies for your oldest child."
    long_impression = "What is your impression of the following kinds of K-12 schools:"
    selected_columns = ['Respondent ID', long_choice, long_impression,
                                    'Unnamed: 63', 'Unnamed: 64', 'Unnamed: 65', 'Unnamed: 66',
                                    'Unnamed: 67', 'Unnamed: 68', 'Unnamed: 69', 'Unnamed: 70',
                                    'Unnamed: 71', 'Unnamed: 72']
    short_choice = "selected school"
    short_impression = "impression school types"
    small_df = df.loc[:, df.columns.isin(selected_columns)]
    # Set the second row as the column names, drop that row, reset index
    small_df.columns = small_df.iloc[0]
    small_df = small_df[1:]
    small_df.columns.values[0] = 'Respondent ID'
    small_df.columns.values[1] = short_choice

    # drop rows with 3+ empty strings
    small_df = small_df[small_df.apply(lambda row: (row == '').sum() < 3, axis=1)]
    # replace "[Insert text from Other]" with "Other"
    small_df[short_choice] = small_df[short_choice].replace("[Insert text from Other]", "Other")
    small_df.reset_index(drop=True, inplace=True)
    return small_df




def zip_data_viz(responses):
    zcdb = ZipCodeDatabase()
    long_title = 'What is your zip code?'
    responses['is_zip'] = responses[long_title].apply(lambda value: bool(zcdb.get(value, None)))
    responses['valid zips'] = responses.apply(lambda row: row[long_title] if row['is_zip'] else np.nan, axis=1)
    valid_zips = responses[responses['valid zips'].notna()]['valid zips']

    lat_lon_df = valid_zips.apply(lambda zip_code: get_lat_long(zip_code, zcdb)).apply(pd.Series)
    lat_lon_df.columns = ['Latitude', 'Longitude']

    # Combine lat/lon with original data
    responses_with_lat_lon = pd.concat([responses, lat_lon_df], axis=1)

    # Filter out rows with missing lat/lon values
    valid_locations = responses_with_lat_lon.dropna(subset=['Latitude', 'Longitude'])

    # Create a map centered around the first location
    m = folium.Map(location=[valid_locations['Latitude'].iloc[0], valid_locations['Longitude'].iloc[0]], zoom_start=6)

    # Add markers for each location
    for _, row in valid_locations.iterrows():
        folium.Marker([row['Latitude'], row['Longitude']], popup=row[long_title]).add_to(m)

    # Show map
    m.save('zip_code_map.html')

def get_lat_long(zip_code, zcdb):
    try:
        zip_info = zcdb[zip_code]
        return zip_info.latitude, zip_info.longitude
    except:
        return None, None


def update_survey_monkey_graphs(original_df, short_school_types_dict):
    survey_monkey_short_titles = {
        "Which of the following kinds of schools and learning opportunities did you consider/are you considering for you kid(s)? Select all that apply.": "types of schools considered",
        "Aside from the options you considered, does your community have any other kinds of K-12 schools or learning opportunities that you are aware of? Select all that apply.": "other available schools",
        "What kind of school does your K-12 aged child currently attend? If you have more than one K-12 aged children, pick the option that applies for your oldest child.": "selected school",
        "What were the primary reasons you selected this kind of school? If you have more than one K-12 aged child, please think about your oldest.": "primary reasons",
        "How was your experience PICKING this school? If you have more than one K-12 aged child, please think about your oldest.": "ease picking",
        "Do you feel confident that you made the right choice? If you have more than one K-12 aged child, please think about your oldest.": "confidence picking",
        "What information is available to you about K-12 schools? Select all that apply.": "available info",
        "How satisfied are you with the information available to you about the kinds of schools that you considered for your kid(s)?": "satisfaction info",
        "'What is your impression of the following kinds of K-12 schools:": "impression school types",
        "Do any of your K-12 aged kids identify as part of a marginalized community at school? If so, which ones?": "marginalized community",
        "Which of the following kinds of K-12 accommodations have you navigated with your kids (s)? Select all that apply": "accomodations"
    }
    survey_monkey_groupings = {
        "types of schools considered": [
            'Which of the following kinds of schools and learning opportunities did you consider/are you considering for you kid(s)? Select all that apply.',
            'Unnamed: 11', 'Unnamed: 12', 'Unnamed: 13', 'Unnamed: 14', 'Unnamed: 15', 'Unnamed: 16', 'Unnamed: 17',
            'Unnamed: 18', 'Unnamed: 19', 'Unnamed: 20', 'Unnamed: 21', ],
        "other available schools": [
            'Aside from the options you considered, does your community have any other kinds of K-12 schools or learning opportunities that you are aware of? Select all that apply.',
            'Unnamed: 23', 'Unnamed: 24', 'Unnamed: 25', 'Unnamed: 26',
            'Unnamed: 27', 'Unnamed: 28', 'Unnamed: 29', 'Unnamed: 30',
            'Unnamed: 31', 'Unnamed: 32', 'Unnamed: 33', 'Unnamed: 34',
            'Unnamed: 35'],
        "primary reasons": [
            'What were the primary reasons you selected this kind of school? If you have more than one K-12 aged child, please think about your oldest.',
            'Unnamed: 38', 'Unnamed: 39', 'Unnamed: 40', 'Unnamed: 41',
            'Unnamed: 42', 'Unnamed: 43', 'Unnamed: 44', 'Unnamed: 45',
            'Unnamed: 46', 'Unnamed: 47', 'Unnamed: 48'],
        "available info": ['What information is available to you about K-12 schools? Select all that apply.',
                           'Unnamed: 52', 'Unnamed: 53', 'Unnamed: 54', 'Unnamed: 55',
                           'Unnamed: 56', 'Unnamed: 57', 'Unnamed: 58', 'Unnamed: 59',
                           'Unnamed: 60'],
        "impression school types": ['What is your impression of the following kinds of K-12 schools:',
                                    'Unnamed: 63', 'Unnamed: 64', 'Unnamed: 65', 'Unnamed: 66',
                                    'Unnamed: 67', 'Unnamed: 68', 'Unnamed: 69', 'Unnamed: 70',
                                    'Unnamed: 71', 'Unnamed: 72'],
        "marginalized community": [
            'Do any of your K-12 aged kids identify as part of a marginalized community at school? If so, which ones?',
            'Unnamed: 76', 'Unnamed: 77', 'Unnamed: 78', 'Unnamed: 79',
            'Unnamed: 80', 'Unnamed: 81', 'Unnamed: 82', 'Unnamed: 83',
            'Unnamed: 84', 'Unnamed: 85'],
        "accomodations": [
            'Which of the following kinds of K-12 accommodations have you navigated with your kids (s)? Select all that apply.',
            'Unnamed: 87', 'Unnamed: 88', 'Unnamed: 89', 'Unnamed: 90',
            'Unnamed: 91', 'Unnamed: 92', 'Unnamed: 93']

    }
    for long_title, short_title in survey_monkey_short_titles.items():
        df = original_df
        value = survey_monkey_groupings.get(short_title, None)
        if value is None:
            # then there is only one column of data
            filtered = df[df[long_title] != ""]
            filtered = filtered[1:]
            count_df = filtered[long_title].value_counts().reset_index()
            count_df.columns = [short_title, "Count"]
            count_df['Percentage'] = (count_df['Count'] / count_df['Count'].sum() * 100).round(1)

            count_df['Percentage'] = pd.to_numeric(count_df['Percentage'])

            count_df = count_df.sort_values(short_title, ascending=True)
            count_df[short_title] = count_df[short_title].replace("[Insert text from Other]", "Other")
            if short_title == "selected school":
                bar_graph3(count_df, short_title, "kinds of schools",
                           "percent of respondents who picked different school types", short_school_types_dict)
            elif short_title == "confidence picking":
                bar_graph3(count_df, short_title, "level of confidence",
                           "percent of respondents who reported certain levels of confidence that they made the right choice",
                           None)
            elif short_title == "ease picking":
                bar_graph3(count_df, short_title, "ease of selecting a school",
                           "percent of respondents who felt their choice was easy/hard",
                           None)

            elif short_title == "satisfaction info":
                bar_graph3(count_df, short_title, "satisfaction with amount of info",
                           "how  satisfied participants were with the amount of info",
                           None)
        else:
            print(f"about to graph: '{short_title}'")
            columns_to_keep = survey_monkey_groupings[short_title]
            df = df[columns_to_keep]
            df.columns = df.iloc[0]
            df = df[1:]
            df = df[df.apply(lambda row: not all(row == ''), axis=1)]
            df.reset_index(drop=True, inplace=True)
            if short_title == "impression school types":
                grid_response_graph(df, short_title, short_school_types_dict, "Responses for Different School Types")
            else:
                calculate_count_percentage(df, short_title, short_school_types_dict)


def grid_response_graph(df, short_title, label_dict, title):
    unique_responses = df.stack().unique()
    response_counts = {}
    for response in unique_responses:
        response_counts[response] = (df == response).sum()
    plot_data = pd.DataFrame(response_counts)
    plot_data = plot_data[sorted(plot_data.columns)]

    cmap = plt.get_cmap('Blues')

    # Normalize the color range to match the number of categories
    norm = plt.Normalize(vmin=0, vmax=len(plot_data.columns) - 1)

    # Create a list of colors using the colormap
    colors = [cmap(norm(i)) for i in range(len(plot_data.columns))]

    ax = plot_data.plot(kind='bar', figsize=(10, 6), width=0.8, color=colors)
    ax.set_xlabel('School Types')
    ax.set_ylabel('Percent of Responses')
    ax.set_title(title)
    ax.set_xticklabels([label_dict.get(label, label) for label in plot_data.index], rotation=90, va='top',
                       fontsize=10,
                       ha='right')
    ax.tick_params(axis='x', which='both', length=0, pad=-350)

    ax.set_ylim(0, 100)
    plt.tight_layout()
    plt.show()


def calculate_count_percentage(df, subject, short_school_types_dict):
    count_series = (df != "").sum()
    count_df = count_series.to_frame()
    count_df.columns = ["Count"]
    count_df['Percentage'] = (count_df['Count'] / count_df['Count'].sum() * 100).round(1)
    count_df['Percentage'] = pd.to_numeric(count_df['Percentage'])
    count_df[subject] = count_df.index
    count_df = count_df.sort_values(subject, ascending=True)
    count_df.reset_index(drop=True, inplace=True)
    if subject == "types of schools considered":
        # def bar_graph3(counts_df, graph_this, x_axis_title, graph_title, label_dict):
        bar_graph3(count_df, subject, "kinds of schools",
                   "Respondents considered these school types", short_school_types_dict)
    elif subject == "other available schools":
        bar_graph3(count_df, subject, "kinds of schools",
                   "respondents did not consider  these available school types", short_school_types_dict)
    elif subject == "primary reasons":
        # create a dict where the key is the values in count_df[subject] and the value up until the open parenthesis, if there is an open parenthesis
        label_dict = {
            row[subject]: row[subject].split('(')[0][:-1] if '(' in row[subject] else row[subject]
            for _, row in count_df.iterrows()
        }
        bar_graph3(count_df, subject, "reasons",
                   "respondents' reasons for picking their kids' school",
                   label_dict)
    elif subject == "available info":
        label_dict = {
            row[subject]: row[subject].split('(')[0][:-1] if '(' in row[subject] else row[subject]
            for _, row in count_df.iterrows()
        }
        bar_graph3(count_df, subject, subject,
                   "information available to respondents",
                   label_dict)
    elif subject == "marginalized community":
        bar_graph3(count_df, subject, subject,
                   "percent of respondents with kids in marginalized community/ies",
                   None)
    elif subject == "accomodations":
        label_dict = {
            row[subject]: row[subject].split('(')[0][:-1] if '(' in row[subject] else row[subject]
            for _, row in count_df.iterrows()
        }
        bar_graph3(count_df, subject, subject,
                   "accomodations",
                   label_dict)
    else:
        print("Unknown error")


def bar_graph3(counts_df, graph_this, x_axis_title, graph_title, label_dict):
    fig, ax = plt.subplots()
    bars = plt.bar(counts_df[graph_this], counts_df['Percentage'])
    plt.title(graph_title)
    plt.xlabel(x_axis_title)
    plt.ylabel('Percentage (%)')
    plt.ylim(0, 100)

    if label_dict == None:
        ax.set_xticklabels([label for label in counts_df[graph_this]], rotation=90, va='top',
                           fontsize=10,
                           ha='center')
    else:
        ax.set_xticklabels([label_dict.get(label, label) for label in counts_df[graph_this]], rotation=90, va='top',
                           fontsize=10,
                           ha='center')
    ax.tick_params(axis='x', which='both', length=0, pad=-250)

    # for index, value in enumerate(counts_df['Percentage']):
    #     plt.text(index, value + 1, f"{value}%", ha='center', fontsize=10)
    #     print(index, value)

    for bar in bars:
        yval = bar.get_height()  # Get the height (percentage) of the bar
        ax.text(bar.get_x() + bar.get_width() / 2, yval + 1,  # Position the text above the bar
                f'{yval}%', ha='center', va='bottom', fontsize=10)

    plt.tight_layout()
    plt.show()


def get_type_satisfaction(responses):
    school_type = 'What kind of school does your K-12 aged child currently attend? If you have more than one K-12 aged children, pick the option that applies for your oldest child.'
    satisfaction = 'How satisfied are you with the information available to you about the kinds of schools that you considered for your kid(s)?'
    columns_to_keep = ['Respondent ID', school_type, satisfaction]
    df = responses[columns_to_keep]
    df = df.iloc[1:]  # gets rid of surveymonkey data
    df = df[df[[school_type, satisfaction]].apply(lambda row: all(row != ''), axis=1)]
    df['Satisfaction'] = pd.to_numeric(df[satisfaction].astype(str).str[0], errors='coerce').astype('Int64')
    df = df.rename(columns={school_type: 'School Type'})
    df = df.drop(columns=['Respondent ID', satisfaction])
    df.reset_index(drop=True, inplace=True)

    return df


def get_type_ease(df):
    school_type = 'What kind of school does your K-12 aged child currently attend? If you have more than one K-12 aged children, pick the option that applies for your oldest child.'
    choice_ease = 'How was your experience PICKING this school? If you have more than one K-12 aged child, please think about your oldest.'
    columns_to_keep = ['Respondent ID', school_type, choice_ease]
    df = df[columns_to_keep]

    df = df.iloc[1:]  # gets rid of surveymonkey data
    df = df[df[[school_type, choice_ease]].apply(lambda row: all(row != ''), axis=1)]
    df['Ease'] = pd.to_numeric(df[choice_ease].astype(str).str[0], errors='coerce').astype('Int64')
    df = df.rename(columns={school_type: 'School Type'})
    df = df.drop(columns=['Respondent ID', choice_ease])
    df.reset_index(drop=True, inplace=True)
    return df


def given_type_graph_reasons(school_type_and_reasons, label_dict):
    x_axis_title = 'School Type'
    reasons = school_type_and_reasons.columns.tolist()
    reasons.remove(x_axis_title)
    for reason in reasons:
        filtered_df = school_type_and_reasons[school_type_and_reasons[reason] != '']
        counts = filtered_df[x_axis_title].value_counts()
        counts_df = pd.DataFrame(counts)
        counts_df = counts_df.rename_axis(x_axis_title).rename(
            columns={x_axis_title: 'Count'})
        bar_graph2(counts_df, x_axis_title, reason, label_dict)


def given_reasons_graph_type(school_type_and_reasons, label_dict):
    x_axis_title = 'Reason'
    school_types = school_type_and_reasons['School Type'].unique()
    for school_type in school_types:
        filtered_df = school_type_and_reasons[school_type_and_reasons['School Type'] == school_type]
        reason_counts = {}
        for column in filtered_df.columns:
            if column != 'School Type':
                count = filtered_df[filtered_df[column] != ''].shape[0]
                if count > 0:
                    reason_counts[column] = count

        reason_df = pd.DataFrame(list(reason_counts.items()), columns=['Reason', 'Count'])

        reason_df = reason_df.set_index('Reason')
        bar_graph2(reason_df, x_axis_title, school_type, label_dict)


def bar_graph2(counts_df, x_axis_title, graph_title, label_dict):
    counts_df['Percentage'] = (counts_df['Count'] / counts_df['Count'].sum() * 100).round(1)
    counts_df['Percentage'] = pd.to_numeric(counts_df['Percentage'])
    fig, ax = plt.subplots()
    plt.bar(counts_df.index, counts_df['Percentage'])
    plt.ylim(0, 100)
    plt.title(graph_title, fontsize=16)
    plt.xlabel(x_axis_title, fontsize=12)
    plt.ylabel('Percentage (%)', fontsize=12)
    # print(label_dict)
    ax.set_xticklabels([label_dict.get(label, label) for label in counts_df.index], rotation=90, va='top',
                       fontsize=10,
                       ha='center')
    ax.tick_params(axis='x', which='both', length=0, pad=-250)

    for index, value in enumerate(counts_df['Percentage']):
        plt.text(index, value + 1, f"{value}%", ha='center', fontsize=10)
        print(index, value)
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
    df.columns.values[1] = 'School Type'
    df = df.drop(columns=['Respondent ID'])
    df = df.drop(columns=['Other (please specify)'])
    df.reset_index(drop=True, inplace=True)

    return df


def histogram2d(df, x_col, y_col, title, x_axis_dict=None):
    fig, ax = plt.subplots()  # Create a figure and axis
    H, xedges, yedges, _ = plt.hist2d(df[x_col], df[y_col], cmap='Blues', bins=(11, 5))
    # X
    plt.xlabel(x_col)
    if x_axis_dict is None:
        x_labels = sorted(df[x_col].unique())
        ax.set_xticks(range(len(x_labels)))
        ax.set_xticklabels(x_labels, va='bottom', fontsize=10, ha='left')
        ax.tick_params(axis='x', which='both', length=0, pad=20)
    else:
        x_labels = [x_axis_dict[key] for key in sorted(df[x_col].unique())]
        ax.set_xticks(range(len(x_labels)))
        ax.set_xticklabels(x_labels, rotation=90, va='top', fontsize=10, ha='center')
        ax.tick_params(axis='x', which='both', length=0, pad=-250)

    # Y
    plt.yticks(ticks=range(int(min(yedges)), int(max(yedges)) + 1))
    plt.ylabel(y_col)
    plt.title(title)
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

    # Convert to date time format
    df["End Date"] = pd.to_datetime(df["End Date"])

    return df


def csv_to_df(file_path):
    try:
        return pd.read_csv(file_path)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None


def collector_type_time(df, time_frame):
    if time_frame == "Week":
        df["Week"] = df["End Date"].dt.to_period("W")

    grouped = df.groupby([time_frame, "Collector ID"]).size().reset_index(name="Count")
    pivot = grouped.pivot(index=time_frame, columns="Collector ID", values="Count").fillna(0)
    pivot.plot(kind="bar", stacked=True, figsize=(10, 6))
    plt.title("Responses by Collector ID Over Time")
    plt.xlabel(time_frame)
    plt.ylabel("Count")
    plt.xticks(rotation=45)
    plt.legend(title="Collector ID")
    plt.tight_layout()
    plt.show()


def time_responses(df, time_frame):
    if time_frame == "Date":
        df[time_frame] = df["End Date"].dt.date
    elif time_frame == "Week":
        df[time_frame] = df["End Date"].dt.to_period("W").dt.start_time
    else:
        raise ValueError("Invalid time_frame. Choose either 'Daily' or 'Weekly'.")
    counts = df.groupby(time_frame).size().reset_index(name="Count")

    plt.figure(figsize=(10, 6))
    plt.plot(counts.iloc[:, 0], counts["Count"], marker="o", label=f"Responses ({time_frame})")
    plt.title(f"Count of Responses ({time_frame})")
    plt.xlabel("Time")
    plt.ylabel("Count of Responses")
    plt.xticks(rotation=45)
    plt.grid(True, linestyle="--", alpha=0.6)
    plt.legend()
    plt.tight_layout()
    plt.show()


def box_whisker(df, group_by):
    df["End Date"] = pd.to_datetime(df["End Date"])

    if group_by == "days":
        df["Day of Week"] = df["End Date"].dt.day_name()
        counts = df.groupby([df["End Date"].dt.date, "Day of Week"]).size().reset_index(name="Response Count")
        boxplot_data = [counts[counts["Day of Week"] == day]["Response Count"] for day in
                        ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]]

        labels = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        xlabel = "Day of the Week"
        title = "Distribution of Response Counts by Day of the Week"

    elif group_by == "hours":
        df["Hour of Day"] = df["End Date"].dt.hour
        counts = df.groupby([df["End Date"].dt.date, "Hour of Day"]).size().reset_index(name="Response Count")

        boxplot_data = [counts[counts["Hour of Day"] == hour]["Response Count"] for hour in range(24)]

        labels = [str(hour) for hour in range(24)]
        xlabel = "Hour of the Day"
        title = "Distribution of Response Counts by Hour of the Day"

    else:
        raise ValueError("Invalid value for group_by. Use 'days' or 'hours'.")

    # Create the box-and-whisker plot
    plt.figure(figsize=(10, 6))
    plt.boxplot(boxplot_data,
                labels=labels,
                patch_artist=True, boxprops=dict(facecolor="lightblue", color="blue"),
                medianprops=dict(color="red"), whiskerprops=dict(color="blue"))

    # Add title and labels
    plt.title(title, fontsize=14)
    plt.xlabel(xlabel, fontsize=12)
    plt.ylabel("Response Count", fontsize=12)
    plt.grid(axis="y", linestyle="--", alpha=0.7)
    plt.tight_layout()

    # Display the plot
    plt.show()


main()
