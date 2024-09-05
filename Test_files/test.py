import pandas as pd

# Load the data from CSV
df = pd.read_csv('Customers.csv')
# print(df.head())
# print(df.info())
# print(df.describe(include='all'))   
#Sort the DataFrame by 'StoreKey' in ascending order
df_sorted = df.sort_values(by='StoreKey', ascending=True)
# print(df_sorted)

#Convert 'Open Date' to datetime format
# Load the data into a DataFrame
df_sorted = pd.read_csv('Customers.csv')

# Define a function to handle different date formats
def parse_date(date):
    for fmt in ('%d-%m-%y', '%m/%d/%Y', '%d/%m/%Y', '%d-%m-%Y'):
        try:
            return pd.to_datetime(date, format=fmt)
        except ValueError:
            continue
    return pd.NaT  # If none of the formats match, return Not a Time (NaT)

# Apply the function to the 'Open Date' column
df_sorted['Open Date'] = df_sorted['Open Date'].apply(parse_date)

# Display the cleaned DataFrame
print(df_sorted)




#-------------------------------------------------------------------------------------------------------------------------

# Function to format dates, handling NaT values
def format_missing_date(date):
    if pd.notna(date) and isinstance(date, pd.Timestamp):  # Check if date is a valid datetime object
        return date.strftime('%Y-%m-%d')  # Example format
    else:
        return 'No Delivery Date'  # Placeholder for missing dates
    df['Delivery Date'] = df['Delivery Date'].apply(format_missing_date)








#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

#pip install  pip install pandas openpyxl and  pip install xlrd

# Define the path to the Excel file
# file_path = 'Global_Electronics.xlsx'
# sheets_names = pd.read_excel(file_path, sheet_name=None)
# print(sheets_names.keys())


# Function to clean dates
# def clean_date(date_str):
#     try:
#         return pd.to_datetime(date_str, format='%d-%m-%y', errors='coerce').strftime('%Y-%m-%d')
#     except:
#         return pd.to_datetime(date_str, errors='coerce').strftime('%Y-%m-%d')
    

# # Load data from CSV
# df = pd.read_csv('Stores.csv')
# df = df.sort_values(by='StoreKey', ascending=True)

# # Clean 'Open Date' column
# df['Open Date'] = df['Open Date'].apply(clean_date)

# # Clean 'Square Meters' column
# df['Square Meters'] = pd.to_numeric(df['Square Meters'], errors='coerce', downcast='integer')

# # Handle special characters 
# df['State'] = df['State'].str.replace('Ã©', 'é').str.replace('Ã¨', 'è').str.replace('Ã³', 'ó')
# df['State'] = df['State'].str.replace('Ã¢â‚¬Â¢', '•')

# # Display cleaned data
# print(df)

# df.to_csv('cleaned_data_stores.csv', index=False)
# print ("Stores over =================")

# df = pd.read_csv('Exchange_Rates.csv')
# df['Date'] = df['Date'].apply(clean_date)
# df['Currency'] = df['Currency'].str.upper()  # Convert to uppercase if needed
# df['Exchange'] = pd.to_numeric(df['Exchange'], errors='coerce')
# print (df)
# df.to_csv('cleaned_data_exchange_rates.csv', index=False)
# print ("Exchange_rates over =================")




# df = pd.read_csv("Sales.csv")
# # # NOTE: delivery dates are mising, formate dates , 62884 count, 
# # # checked the count of the columns

# df['Order Date'] = df['Order Date'].apply(clean_date)
# df['Currency Code'] = df['Currency Code'].str.upper()
# df['Quantity'] = pd.to_numeric(df['Quantity'], errors='coerce')
# print (df)
# df.to_csv('cleaned_data_sales.csv', index=False)
# print ("Sales over ================= still delivery date has to clean")



# df = pd.read_csv("Customers.csv",encoding='ISO-8859-1')

# df[['Name', 'City', 'Continent']] = df[['Name', 'City', 'Continent']].apply(lambda x: x.str.strip())
# df['City'] = df['City'].str.upper()
# df.fillna({'Gender': 'Unknown', 'State': 'Unknown'}, inplace=True)
# df['Zip Code'] = df['Zip Code'].astype(str).str.zfill(4)

# df['Birthday'] = df['Birthday'].apply(clean_date)
# print (df)
# df.to_csv('cleaned_data_customers.csv', index=False)
# print ("Customers over ================= mapping of country code needs to be done")






# df = pd.read_csv("Products.csv")
# df[['Product Name', 'Brand', 'Color', 'Subcategory', 'Category']] = df[['Product Name', 'Brand', 'Color', 'Subcategory', 'Category']].apply(lambda x: x.str.strip())
# df[['ProductKey', 'SubcategoryKey', 'CategoryKey']] = df[['ProductKey', 'SubcategoryKey', 'CategoryKey']].astype(int)
# df['Unit Cost USD'] = df['Unit Cost USD'].replace('[\$,]', '', regex=True).astype(float)
# df['Unit Price USD'] = df['Unit Price USD'].replace('[\$,]', '', regex=True).astype(float)
# print (df)
# df.to_csv('cleaned_data_products.csv', index=False)
# print ("Customers over =================")