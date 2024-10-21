import pandas as pd
from sqlalchemy import create_engine

# Database connection string
DATABASE_TYPE = 'mysql'  # Change to MySQL
DBAPI = 'pymysql'  # MySQL driver
ENDPOINT = 'localhost'  # Database endpoint
USER = 'subhiksha'  # Database username
PASSWORD = 'Subhiksha787'  # Database password
PORT = 3306  # Default port for MySQL
DATABASE = 'project'  # Database name

# Create a connection to the SQL database
engine = create_engine(f'{DATABASE_TYPE}+{DBAPI}://{USER}:{PASSWORD}@{ENDPOINT}:{PORT}/{DATABASE}')

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
    df.to_sql(table, engine, if_exists='replace', index=False)
    print(f"Data from {file} uploaded to table {table}.")
