import pandas as pd
from sqlalchemy import create_engine

# DEFINE THE DATABASE CREDENTIALS
user='subhiksha'
password="Subhiksha787"
host='127.0.0.1'
port=3306
database='project'

# CREATE A CONNECTION TO THE DATABASE
myConnection= create_engine(f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}")

# # CHECK THIS SITE FOR __name__ AND __main__ RELATION
# # https://geeksforgeeks.org/__name__-a-special-variable-in-python/   
if __name__ == '__main__':
    try:
        # GET THE CONNECTION OBJECT (ENGINE) FOR THE DATABASE
        engine = myConnection
        print(f"Connection to the {host} for user {user} created successfully.")
    except Exception as ex:
        print("Connection could not be made due to the following error: \n", ex)



# List of files and table names
files = {
    'cleaned_data_stores.csv': 'stores',
    'cleaned_data_exchange_rates.csv': 'exchange_rates',
    'cleaned_data_sales.csv': 'sales',
    'cleaned_data_customers.csv': 'customers',
    'cleaned_data_products.csv': 'products'
}

# Upload data to SQL
for file, table in files.items():
    df = pd.read_csv(file)
    df.to_sql(table, myConnection, if_exists='replace', index= False)
    print(f"Data from {file} uploaded to table {table}.")
