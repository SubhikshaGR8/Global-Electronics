import pandas as pd
import numpy as np

# Function to clean dates
def clean_date(date_str):
    try:
        return pd.to_datetime(date_str, format='%d-%m-%y', errors='coerce').strftime('%Y-%m-%d')
    except:
        return pd.to_datetime(date_str, errors='coerce').strftime('%Y-%m-%d')

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
            df[col] = df[col].apply(func)
        else:
            print(f"Column {col} not found in {file_path}")
    
    df.to_csv(output_path, index=False)
    print(f"{file_path} cleaned and saved to {output_path}")

# Define cleaning functions for each dataset
store_clean_funcs = {
    'OpenDate': clean_date,
    'SquareMeters': lambda x: pd.to_numeric(x, errors='coerce', downcast='integer'),
    'State': lambda x: x.replace('Ã©', 'é').replace('Ã¨', 'è').replace('Ã³', 'ó').replace('Ã¢â‚¬Â¢', '•').replace('Ã¼','ü')
}

exchange_clean_funcs = {
    'Date': clean_date,
    'Currency': lambda x: x.upper(),  # Use str.upper() directly
    'ExchangeRate': lambda x: pd.to_numeric(x, errors='coerce')
}

sales_clean_funcs = {
    'OrderDate': clean_date,
    'CurrencyCode': lambda x: x.upper(),  # Use str.upper() directly
    'Quantity': lambda x: pd.to_numeric(x, errors='coerce')
}

customer_clean_funcs = {
    'Name': lambda x: x.strip(),
    'City': lambda x: x.upper().strip(),
    'Continent': lambda x: x.strip(),
    'ZipCode': lambda x: str(x).zfill(4),
    'Birthday': clean_date
}

product_clean_funcs = {
    'ProductName': lambda x: x.strip(),
    'Brand': lambda x: x.strip(),
    'Color': lambda x: x.strip(),
    'Subcategory': lambda x: x.strip(),
    'Category': lambda x: x.strip(),
    'ProductKey': lambda x: int(x),
    'SubcategoryKey': lambda x: int(x),
    'CategoryKey': lambda x: int(x),
    'UnitCostUSD': lambda x: float(x.replace('$', '').replace(',', '')),
    'UnitPriceUSD': lambda x: float(x.replace('$', '').replace(',', ''))
}

# Define missing value columns for each dataset
missing_value_cols = {
    'Customers.csv': ['Gender', 'State'],
    # Add missing columns for other datasets if needed
    # 'Stores.csv': ['SomeColumn'],
    # 'Exchange_Rates.csv': ['SomeColumn'],
    # 'Sales.csv': ['SomeColumn'],
    # 'Products.csv': ['SomeColumn']
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


