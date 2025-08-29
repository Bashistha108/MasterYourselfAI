#!/usr/bin/env python3
"""
Run script that can be executed from any directory
"""
import os
import sys

# Get the absolute path to the backend directory
backend_dir = os.path.dirname(os.path.abspath(__file__))

# Add the backend directory to Python path
sys.path.insert(0, backend_dir)

# Change to the backend directory to ensure consistent behavior
os.chdir(backend_dir)

# Import and run the application
from app import create_app, db

app = create_app()

if __name__ == '__main__':
    print(f"Starting server from directory: {os.getcwd()}")
    print(f"Database path: {app.config['SQLALCHEMY_DATABASE_URI']}")
    app.run(debug=True, host='0.0.0.0', port=5000)
