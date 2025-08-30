#!/usr/bin/env python3
"""
Setup MySQL database for Master Yourself AI
"""

import mysql.connector
from mysql.connector import Error
import os

def setup_mysql_database():
    """Setup MySQL database and user"""
    print("🔧 Setting up MySQL Database")
    print("=" * 40)
    
    # Database configuration
    DB_NAME = 'master_yourself_ai'
    USER_NAME = 'master_ai_user'
    USER_PASSWORD = 'MasterAI2024!@#'
    
    try:
        # Connect to MySQL as root (you'll need to enter password)
        print("Connecting to MySQL as root...")
        connection = mysql.connector.connect(
            host='localhost',
            user='root',
            password=input("Enter MySQL root password: ")
        )
        
        if connection.is_connected():
            cursor = connection.cursor()
            
            # Create database
            print(f"Creating database: {DB_NAME}")
            cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
            
            # Create user
            print(f"Creating user: {USER_NAME}")
            cursor.execute(f"CREATE USER IF NOT EXISTS '{USER_NAME}'@'localhost' IDENTIFIED BY '{USER_PASSWORD}'")
            
            # Grant privileges
            print(f"Granting privileges to {USER_NAME}")
            cursor.execute(f"GRANT ALL PRIVILEGES ON {DB_NAME}.* TO '{USER_NAME}'@'localhost'")
            cursor.execute("FLUSH PRIVILEGES")
            
            print("✅ MySQL database setup completed successfully!")
            print(f"Database: {DB_NAME}")
            print(f"User: {USER_NAME}")
            print(f"Password: {USER_PASSWORD}")
            
            # Test connection with new user
            print("\nTesting connection with new user...")
            test_connection = mysql.connector.connect(
                host='localhost',
                user=USER_NAME,
                password=USER_PASSWORD,
                database=DB_NAME
            )
            
            if test_connection.is_connected():
                print("✅ Connection test successful!")
                test_connection.close()
            
    except Error as e:
        print(f"❌ Error: {e}")
    finally:
        if 'connection' in locals() and connection.is_connected():
            cursor.close()
            connection.close()
            print("MySQL connection closed.")

if __name__ == "__main__":
    setup_mysql_database()
