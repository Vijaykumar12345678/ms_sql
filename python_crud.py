
"""
@Author:Vijay Kumar M N
@Date: 2024-09-19
@Last Modified by: Vijay Kumar M N
@Last Modified: 2024-09-19
@Title : python program for to crud operations on mssql.
"""

import pyodbc

def get_connection(database_name=None):
    """
    Description:
        Establishes a connection to the SQL Server database. If a database name is provided, it connects to that database.
    
    Parameters:
        database_name (str): The name of the database to connect to. If None, connects to the default instance.
    
    Returns:
        pyodbc.Connection: Connection object for the specified database.
    """
    try:
        connection_string = (
            f"Driver={{ODBC Driver 17 for SQL Server}};"
            f"Server=DESKTOP-9ELS0L3\\SQLEXPRESS;"
            f"Database={database_name if database_name else 'master'};"
            f"Trusted_Connection=yes;"
        )
        connection = pyodbc.connect(connection_string)
        return connection
    except Exception as e:
        print("Error while connecting to SQL Server:", e)
        return None

def create_database(cursor, db_name):
    """
    Description:
        Creates a new database with the given name.
    
    Parameters:
        cursor (pyodbc.Cursor): Cursor object for executing SQL queries.
        db_name (str): The name of the new database.
    
    Returns:
        None
    """
    try:
        cursor.execute(f"CREATE DATABASE {db_name}")
        cursor.connection.commit()
        print(f"Database '{db_name}' created successfully.")
    except Exception as e:
        print(f"Error creating database '{db_name}':", e)

def get_table_structure():
    """
    Description:
        Prompts the user to input the table structure (column names and data types) for dynamic table creation.
    
    Returns:
        str: SQL query string for creating the table.
    """
    table_name = input("Enter table name: ")
    columns = []
    print("Define columns (enter 'done' when finished):")
    
    while True:
        column_name = input("Column name: ")
        if column_name.lower() == 'done':
            break
        data_type = input(f"Data type for {column_name} (e.g., INT, VARCHAR(255)): ")
        columns.append(f"{column_name} {data_type}")
    
    column_definitions = ", ".join(columns)
    create_table_query = f"CREATE TABLE {table_name} ({column_definitions});"
    return create_table_query

def create_table(cursor):
    """
    Description:
        Creates a new table dynamically based on user input.
    
    Parameters:
        cursor (pyodbc.Cursor): Cursor object for executing SQL queries.
    
    Returns:
        None
    """
    create_table_query = get_table_structure()
    try:
        cursor.execute(create_table_query)
        cursor.connection.commit()
        print("Table created successfully.")
    except Exception as e:
        print("Error creating table:", e)

def insert_record(cursor):
    """
    Description:
        Inserts a new record into a table dynamically based on user input.
    
    Parameters:
        cursor (pyodbc.Cursor): Cursor object for executing SQL queries.
    
    Returns:
        None
    """
    table_name = input("Enter table name to insert into: ")
    cursor.execute(f"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '{table_name}'")
    columns = [row.COLUMN_NAME for row in cursor.fetchall()]
    
    values = []
    for column in columns:
        value = input(f"Enter value for {column}: ")
        values.append(f"'{value}'")
    
    insert_query = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES ({', '.join(values)});"
    
    try:
        cursor.execute(insert_query)
        cursor.connection.commit()
        print("Record inserted successfully.")
    except Exception as e:
        print("Error inserting record:", e)

def display_rows(cursor):
    """
    Description:
        Displays all rows from the specified table.
    
    Parameters:
        cursor (pyodbc.Cursor): Cursor object for executing SQL queries.
    
    Returns:
        None
    """
    table_name = input("Enter table name to display records: ")
    select_query = f"SELECT * FROM {table_name}"
    cursor.execute(select_query)
    rows = cursor.fetchall()
    
    if rows:
        for row in rows:
            print(row)
    else:
        print(f"No records found in table {table_name}.")

def update_record(cursor):
    """
    Description:
        Updates a record in a table dynamically based on user input.
    
    Parameters:
        cursor (pyodbc.Cursor): Cursor object for executing SQL queries.
    
    Returns:
        None
    """
    table_name = input("Enter table name to update record: ")
    column_to_update = input("Enter the column to update: ")
    new_value = input(f"Enter the new value for {column_to_update}: ")
    condition_column = input("Enter the condition column for identifying the record: ")
    condition_value = input(f"Enter the value of {condition_column} to update: ")
    
    update_query = f"UPDATE {table_name} SET {column_to_update} = '{new_value}' WHERE {condition_column} = '{condition_value}'"
    
    try:
        cursor.execute(update_query)
        cursor.connection.commit()
        print("Record updated successfully.")
    except Exception as e:
        print("Error updating record:", e)

def delete_record(cursor):
    """
    Description:
        Deletes a record from a table dynamically based on user input.
    
    Parameters:
        cursor (pyodbc.Cursor): Cursor object for executing SQL queries.
    
    Returns:
        None
    """
    table_name = input("Enter table name to delete record from: ")
    condition_column = input("Enter the condition column for identifying the record: ")
    condition_value = input(f"Enter the value of {condition_column} to delete: ")
    
    delete_query = f"DELETE FROM {table_name} WHERE {condition_column} = '{condition_value}'"
    
    try:
        cursor.execute(delete_query)
        cursor.connection.commit()
        print("Record deleted successfully.")
    except Exception as e:
        print("Error deleting record:", e)

def main():
    connection = get_connection()
    if connection is None:
        return

    cursor = connection.cursor()
    
    # Ask user if they want to create a new database or use an existing one
    choice = input("Do you want to create a new database or work with an existing one? (new/existing): ").strip().lower()
    
    if choice == 'new':
        db_name = input("Enter the new database name: ")
        create_database(cursor, db_name)
        cursor.connection.close()
        connection = get_connection(db_name)
        cursor = connection.cursor()
    elif choice == 'existing':
        db_name = input("Enter the existing database name: ")
        cursor.connection.close()
        connection = get_connection(db_name)
        cursor = connection.cursor()
    else:
        print("Invalid choice. Exiting.")
        return

    while True:
        print("\n--- Menu ---")
        print("1. Create Table")
        print("2. Insert Record")
        print("3. Display Records")
        print("4. Update Record")
        print("5. Delete Record")
        print("6. Exit")
        
        option = input("Choose an option: ")
        
        if option == '1':
            create_table(cursor)
        elif option == '2':
            insert_record(cursor)
        elif option == '3':
            display_rows(cursor)
        elif option == '4':
            update_record(cursor)
        elif option == '5':
            delete_record(cursor)
        elif option == '6':
            print("Exiting the program.")
            break
        else:
            print("Invalid option. Please try again.")

    connection.close()

if __name__ == "__main__":
    main()
