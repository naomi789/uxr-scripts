import re
import pandas as pd
import requests
from tqdm import tqdm  # For progress bar

def get_data(input_csv):
    """
    Reads a CSV file and returns a DataFrame.
    Ensures it has a 'url' column.
    """
    df = pd.read_csv(input_csv)
    if 'url' not in df.columns:
        raise ValueError("Input CSV must have a column named 'url'")
    return df

def construct_url(original_url):
    """
    Extracts the state and schoolid from the original URL query parameters
    and returns the constructed GreatSchools-style URL.
    """
    try:
        state_match = re.search(r"state=([a-z]{2})", original_url)
        schoolid_match = re.search(r"schoolid=([0-9]+)", original_url)

        if state_match and schoolid_match:
            state = state_match.group(1)
            schoolid = schoolid_match.group(1)
            return f"https://www.greatschools.org/{state}/x/{schoolid}-x/"
        else:
            return "Error: Missing state or schoolid"
    except Exception as e:
        return f"Error: {e}"


def add_constructed_urls(df):
    """
    Takes a DataFrame with a 'url' column and adds a 'constructed_url' column
    with reconstructed URLs.
    """
    constructed_urls = []
    for url in tqdm(df['url'], desc="Constructing URLs"):
        constructed_url = construct_url(url)
        constructed_urls.append(constructed_url)

    df['constructed_url'] = constructed_urls
    return df

def add_redirected_urls(df):
    """
    Takes a DataFrame with a 'constructed_url' column and adds a 'redirected_url' column
    with redirected URLs.
    """
    redirected_urls = []
    for url in tqdm(df['constructed_url'], desc="Finding what the URL redictects to"):
        try:
            response = requests.get(url, allow_redirects=True, timeout=10)
            redirected_urls.append(response.url)
        except requests.RequestException as e:
            redirected_urls.append(f"Error: {e}")

    df['redirected_urls'] = redirected_urls
    return df

def main():
    df = get_data(input_csv='input_urls.csv')
    df_url = add_constructed_urls(df)
    df_redirected_urls = add_redirected_urls(df_url)
    output_csv = 'output_constructed_urls.csv'
    df_redirected_urls.to_csv(output_csv, index=False)
    print(f"Finished. Output saved to '{output_csv}'.")



if __name__ == "__main__":
    main()

