#!/usr/bin/env python3
"""
Script to show all existing users in the database
"""

import os
import sys
from dotenv import load_dotenv

# Add the backend directory to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Load environment variables
load_dotenv()

from app import create_app, db
from app.models.user import User

def show_all_users():
    """Display all users in the database"""
    try:
        # Create Flask app context
        app = create_app()
        
        with app.app_context():
            # Get all users
            users = User.query.all()
            
            if not users:
                print("❌ No users found in the database.")
                return
            
            print(f"✅ Found {len(users)} user(s) in the database:")
            print("=" * 80)
            
            for i, user in enumerate(users, 1):
                print(f"User {i}:")
                print(f"  ID: {user.id}")
                print(f"  Email: {user.email}")
                print(f"  Display Name: {user.display_name or 'Not set'}")
                print(f"  Created: {user.created_at}")
                print(f"  Updated: {user.updated_at}")
                print("-" * 40)
                
    except Exception as e:
        print(f"❌ Error: {e}")
        print("Make sure your database is running and accessible.")

if __name__ == "__main__":
    show_all_users()
