#!/usr/bin/env python3

import sys
import os

# Add the backend directory to the Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db
from app.models import Email

def add_emails_table():
    """Add the emails table to the database"""
    app = create_app()
    
    with app.app_context():
        try:
            # Create the emails table
            db.create_all()
            print("✅ Emails table created successfully!")
            
            # Verify the table exists
            result = db.engine.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='emails'")
            if result.fetchone():
                print("✅ Emails table verified in database")
            else:
                print("❌ Emails table not found in database")
                
        except Exception as e:
            print(f"❌ Error creating emails table: {e}")

if __name__ == "__main__":
    add_emails_table()
