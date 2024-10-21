import pandas as pd
from datetime import datetime
import numpy as np


# Function to clean dates
def clean_date(date_series):
    return pd.to_datetime(date_series, format='%d-%m-%y', errors='coerce').dt.strftime('%Y-%m-%d')

#birthday date
def clean_and_extract_year(birthday):
    # Try different formats to parse the date
    for fmt in ("%d-%m-%y", "%m/%d/%Y", "%m/%d/%y"):
        try:
            return datetime.strptime(birthday, fmt).year
        except ValueError:
            continue
    return None  # Return None if no format matches

# Define a function to clean and save data
def clean_and_save_csv(file_path, output_path, clean_funcs, missing_value_cols=None):
    df = pd.read_csv(file_path, encoding='ISO-8859-1' if 'Customers' in file_path else None)

    # Handle missing values separately if specified
    if missing_value_cols:
        for col in missing_value_cols:
            if col in df.columns:
                df[col] = df[col].fillna('Unknown')

    # Apply cleaning functions to each column
    for col, func in clean_funcs.items():
        if col in df.columns:
            df[col] = func(df[col])  # Apply func directly to the Series
        else:
            print(f"Column {col} not found in {file_path}")

    df.to_csv(output_path, index=False)
    print(f"{file_path} cleaned and saved to {output_path}")

# Function to standardize date formats
def parse_dates(date_str):
    if pd.isnull(date_str):
        return pd.NaT
    try:
        return pd.to_datetime(date_str, format='%m-%d-%y', errors='raise').date()
    except ValueError:
        return pd.to_datetime(date_str, format='%m/%d/%Y', errors='coerce').date()    

# Define cleaning functions for each dataset

store_clean_funcs = {
    'Open Date': clean_date,
    'Square Meters': lambda x: pd.to_numeric(x, errors='coerce', downcast='integer'),
    'State': lambda x: x.replace('Ã©', 'é').replace('Ã¨', 'è').replace('Ã³', 'ó').replace('Ã¢â‚¬Â¢', '•')
}

exchange_clean_funcs = {
    'Date': clean_date,
    'Currency': lambda x: x.str.upper(),
    'Exchange': lambda x: pd.to_numeric(x, errors='coerce')
}

sales_clean_funcs = {
    'Order Date': lambda x: x.apply(parse_dates).ffill(),
    'Delivery Date': lambda x: x.apply(parse_dates).ffill(),
    'Currency Code': lambda x: x.str.upper(),
    'Quantity': lambda x: pd.to_numeric(x, errors='coerce')
}

customer_clean_funcs = {
    'Name': lambda x: x.str.strip(),
    'City': lambda x: x.str.upper().str.strip(),
    'Continent': lambda x: x.str.strip(),
    'Zip Code': lambda x: x.astype(str).str.zfill(4),
    'Birthday': lambda x: x.apply(clean_and_extract_year) 
}

product_clean_funcs = {
    'Product Name': lambda x: x.str.strip(),
    'Brand': lambda x: x.str.strip(),
    'Color': lambda x: x.str.strip(),
    'Subcategory': lambda x: x.str.strip(),
    'Category': lambda x: x.str.strip(),
    'ProductKey': lambda x: x.astype(int),
    'SubcategoryKey': lambda x: x.astype(int),
    'CategoryKey': lambda x: x.astype(int),
    'Unit Cost USD': lambda x: x.str.replace('$', '').str.replace(',', '').astype(float),
    'Unit Price USD': lambda x: x.str.replace('$', '').str.replace(',', '').astype(float)
}

# Define missing value columns for each dataset
missing_value_cols = {
    'Customers.csv': ['Gender', 'State'],
}

# Paths for CSV files
paths = {
    'Stores.csv': 'cleaned_data_stores.csv',
    'Exchange_Rates.csv': 'cleaned_data_exchange_rates.csv',
    'Sales.csv': 'cleaned_data_sales.csv',
    'Customers.csv': 'cleaned_data_customers.csv',
    'Products.csv': 'cleaned_data_products.csv'
}

# Clean and save data
for file, output in paths.items():
    if file == 'Stores.csv':
        clean_and_save_csv(file, output, store_clean_funcs)
    elif file == 'Exchange_Rates.csv':
        clean_and_save_csv(file, output, exchange_clean_funcs)
    elif file == 'Customers.csv':
        clean_and_save_csv(file, output, customer_clean_funcs, missing_value_cols.get(file))
    elif file == 'Products.csv':
        clean_and_save_csv(file, output, product_clean_funcs)
    elif file == 'Sales.csv':
        clean_and_save_csv(file, output, sales_clean_funcs)    

print("Data cleaning complete.")



