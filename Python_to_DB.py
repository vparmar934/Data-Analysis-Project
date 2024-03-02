#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 22 18:44:42 2024

@author: viky
"""

import pandas as pd

df = pd.read_excel("/Users/Viky/Documents/Sample - Superstore.xls")
print(df.dtypes)    

dfc = df.iloc[:,5:13]
dfc1 = dfc.drop_duplicates(subset = "Customer ID")

dfp = df.iloc[:,13:17]
dfp1 = dfp.drop_duplicates(subset = "Product ID")

df1 = df.drop(df.columns[[6,7,8,9,10,11,12,14,15,16]], axis=1)



# Establish a connection to the PostgreSQL database
import psycopg2

hostname = 'localhost'
database = 'vikas'
username = 'postgres'
pwd = '****'
port_id = 5432
schema = 'superstore'

conn = psycopg2.connect(
    host=hostname,
    dbname=database,
    user=username,
    password=pwd,
    port=port_id
)

cur = conn.cursor()

table_name1 = 'orders'
column_def1 = '''row_id int, order_id varchar, order_date date, ship_date date,
              ship_mode varchar, customer_id varchar, product_id varchar,
              sales float, quantity int, discount float, profit float'''
              
table_name2 = 'customers'
column_def2 = '''cutsomer_id varchar, customer_name varchar, segment varchar,
               country varchar, city varchar, state varchar, postal_code int,
               region varchar'''

table_name3 = 'products'
column_def3 = 'product_id varchar, category varchar, sub_category varchar, product_name varchar'

cur.execute(f"CREATE TABLE IF NOT EXISTS {schema}.{table_name1} ({column_def1})")
cur.execute(f"CREATE TABLE IF NOT EXISTS {schema}.{table_name2} ({column_def2})")
cur.execute(f"CREATE TABLE IF NOT EXISTS {schema}.{table_name3} ({column_def3})")

data1 = df1.iloc[0:].values.tolist()  # Skip the first row (headers)
# Insert data into the table
columns1 = ', '.join(['"{}"'.format(col) for col in df1.columns])
values1 = ', '.join(['%s' for _ in range(len(df1.columns))])
query1 = f"INSERT INTO {schema}.{table_name1} VALUES ({values1})"
cur.executemany(query1, data1)

data2 = dfc1.iloc[0:].values.tolist()  # Skip the first row (headers)
# Insert data into the table
columns2 = ', '.join(['"{}"'.format(col) for col in dfc1.columns])
values2 = ', '.join(['%s' for _ in range(len(dfc1.columns))])
query2 = f"INSERT INTO {schema}.{table_name2} VALUES ({values2})"
cur.executemany(query2, data2)


data3 = dfp1.iloc[0:].values.tolist()  # Skip the first row (headers)
# Insert data into the table
columns3 = ', '.join(['"{}"'.format(col) for col in dfp1.columns])
values3 = ', '.join(['%s' for _ in range(len(dfp1.columns))])
query3 = f"INSERT INTO {schema}.{table_name3} VALUES ({values3})"
cur.executemany(query3, data3)

conn.commit()

cur.close()
conn.close()
