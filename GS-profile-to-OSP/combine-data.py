import pandas as pd
from pii import TARGET_EMAIL

def csv_to_df(file_path):
    try:
        return pd.read_csv(file_path)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None

def clean_data(df_sm, df_gs, collector_dict, collectors_to_drop):
    df_sm.columns = df_sm.columns.str.strip()  # Remove leading/trailing spaces
    columns_to_drop = ["Start Date", "IP Address", "Custom Data 1", "Custom Data 2"]
    df_sm = df_sm.drop(columns=columns_to_drop,
                 errors='ignore')

    # Update collectors, only keep if they are not prohibited
    df_sm["Collector ID"] = df_sm["Collector ID"].map(collector_dict)
    df_sm = df_sm[~df_sm["Collector ID"].isin(collectors_to_drop)]

    # Only keep data if they answered Q1
    filter_column = "My primary job at my K-12 school is ____________."
    df_sm = df_sm.dropna(subset=[filter_column])
    # AND made it to the end of the second page, answering Q8
    filter_column = "How much of your job involves your school's online reputation?"
    df_sm = df_sm.dropna(subset=[filter_column])

    # if more than two values in a row are "Response", then remove the row
    response_count = (df_sm == "Response").sum(axis=1)
    df_sm = df_sm[response_count <= 2]

    # capitalize state acronyms
    df_gs['State'] = df_gs['State'].astype(str).str.upper()
    df_sm['Custom Data 6'] = df_sm['Custom Data 6'].astype(str).str.upper()

    # If same school ID and same state
    merged_by_id = pd.merge(
        df_gs,
        df_sm,
        left_on=['School ID', 'State'],
        right_on=['Custom Data 3', 'Custom Data 6'],
        how='inner',
        suffixes=('_gs', '_sm')
    )

    match_counts = merged_by_id['School ID'].value_counts()
    assert (match_counts == 1).all(), "Not all matches occur exactly once."
    single_match_keys = set(zip(merged_by_id['School ID'], merged_by_id['State']))
    df_gs = df_gs[~df_gs.apply(lambda row: (row['School ID'], row['State']) in single_match_keys, axis=1)]
    df_sm = df_sm[~df_sm.apply(lambda row: (row['Custom Data 3'], row['Custom Data 6']) in single_match_keys, axis=1)]

    # single_match_ids = match_counts.index
    # # this didn't work because the ID is only unique in each state
    # assert df_gs['School ID'].is_unique, "Duplicate School IDs found in df_gs!"
    # df_gs = df_gs[~df_gs['School ID'].isin(single_match_ids)]
    # df_sm = df_sm[~df_sm['Custom Data 3'].isin(single_match_ids)]

    # if the state is identical AND school name are identical
    merged_by_name = pd.merge(
        df_gs,
        df_sm,
        left_on=['School Name', 'State'],
        right_on=['Custom Data 4', 'Custom Data 6'],
        how='inner',
        suffixes=('_gs', '_sm')
    )
    # deal with one participant who has two schools and filled it out twice
    email_rows = merged_by_name[merged_by_name["Email"] == TARGET_EMAIL]
    earliest_row = email_rows.sort_values("End Date").head(1)
    merged_by_name = merged_by_name[merged_by_name["Email"] != TARGET_EMAIL]
    merged_by_name = pd.concat([merged_by_name, earliest_row], ignore_index=True)
    match_counts = merged_by_name['School Name'].value_counts()
    assert (match_counts == 1).all(), "Not all matches occur exactly once."
    matched = match_counts.index
    df_gs = df_gs[~df_gs['School Name'].isin(matched)]
    df_sm = df_sm[~df_sm['Custom Data 4'].isin(matched)]

    merged_all = pd.concat([merged_by_id, merged_by_name], ignore_index=True)
    print('ahh')

    # TODO: check for first & last name matching
    # TODO: check 

    # TODO: check for bad data
    # Remove data from bad actors
    # columns_to_check = ["", ""]
    # values_to_drop = ["", "", ""]
    # df_sm = df_sm[~df_sm[columns_to_check].apply(lambda row: row.isin(values_to_drop).any(), axis=1)]
    # df_sm.reset_index(drop=True, inplace=True)
    # df_sm = df_sm.fillna("")

    # Convert to date time format
    # df_sm["End Date"] = pd.to_datetime(df_sm["End Date"])

    return df_sm, df_gs, merged_all

def main():
    run_everything = False
    # Convert CSVs to DataFrames
    collectors = csv_to_df("CSV/CollectorList.csv")
    collector_dict = collectors.set_index("CollectorID")["Title"].to_dict()
    collectors_to_drop = ["UserTesting", "Test to Naomi"]
    df_sm = csv_to_df("CSV/IndividualResponses.csv")
    df_gs = csv_to_df("CSV/GreatSchools.csv")
    df_sm, df_gs, merged = clean_data(df_sm, df_gs, collector_dict, collectors_to_drop)
    df_sm.to_csv("df_sm.csv", index=False)
    df_gs.to_csv("df_gs.csv", index=False)
    merged.to_csv("merged.csv", index=False)
    print('done')



main()