import re
import pandas as pd
import requests
from tqdm import tqdm
import argparse

def parse_args():
    parser = argparse.ArgumentParser(description="Construct and follow GreatSchools redirect URLs.")
    parser.add_argument('--input', default='input_urls.csv', help='Path to input CSV file')
    parser.add_argument('--output', default='output_constructed_urls.csv', help='Path to output CSV file')
    return parser.parse_args()

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
            return None
    except Exception:
        return None

def add_constructed_urls(df):
    """
    Takes a DataFrame with a 'url' column and adds a 'constructed_url' column
    with reconstructed URLs.
    """
    df['constructed_url'] = df['url'].apply(construct_url)
    return df

def follow_redirect(url):
    """
    Follows a URL and returns the final redirected URL and any error encountered.
    """
    try:
        response = requests.get(url, allow_redirects=True, timeout=10)
        return response.url, None
    except requests.RequestException as e:
        return None, str(e)

def add_redirected_urls(df):
    """
    Takes a DataFrame with a 'constructed_url' column and adds:
    - 'redirected_url': the final destination after redirects
    - 'error': any error encountered during the request
    """
    redirected_urls = []
    errors = []

    for url in tqdm(df['constructed_url'], desc="Following redirects"):
        if not url:
            redirected_urls.append(None)
            errors.append("Invalid constructed URL")
            continue

        redirected_url, error = follow_redirect(url)
        redirected_urls.append(redirected_url)
        errors.append(error)

    df['redirected_url'] = redirected_urls
    df['error'] = errors
    return df

def main():
    args = parse_args()
    df = get_data(args.input)
    df = add_constructed_urls(df)
    df = add_redirected_urls(df)
    df.to_csv(args.output, index=False)
    print(f"\n✅ Finished! Output saved to '{args.output}'.")

if __name__ == "__main__":
    main()
