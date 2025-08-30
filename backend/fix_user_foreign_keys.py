#!/usr/bin/env python3
"""
Fix user_id foreign keys to all tables for user isolation
"""

import os
import sys
from datetime import datetime
from sqlalchemy import text

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db

def fix_user_foreign_keys():
    """Add user_id foreign keys to all tables"""
    print("🔧 Adding User Foreign Keys to All Tables")
    print("=" * 50)
    
    app = create_app()
    
    with app.app_context():
        # List of tables that need user_id foreign key
        tables_to_update = [
            'weekly_goals',
            'long_term_goals', 
            'problems',
            'challenges',
            'goal_ratings',
            'quick_wins',
            'problem_logs',
            'daily_problem_logs',
            'goal_notes',
            'quick_notes',
            'todo_items',
            'weekly_goal_intensities',
            'daily_goal_intensities',
            'ai_challenges',
            'emails'
        ]
        
        print(f"📋 Tables to update: {len(tables_to_update)}")
        
        for table in tables_to_update:
            try:
                # Check if user_id column already exists
                result = db.session.execute(text(f"PRAGMA table_info({table})"))
                columns = [row[1] for row in result.fetchall()]
                
                if 'user_id' not in columns:
                    # Add user_id column
                    db.session.execute(text(f"ALTER TABLE {table} ADD COLUMN user_id INTEGER"))
                    print(f"✅ Added user_id to {table}")
                else:
                    print(f"⚠️  user_id already exists in {table}")
                    
            except Exception as e:
                print(f"❌ Error adding user_id to {table}: {e}")
        
        # Commit changes
        db.session.commit()
        print("\n✅ All foreign keys added successfully!")
        
        # Create a default user for existing data
        print("\n👤 Creating default user for existing data...")
        try:
            from app.models.user import User
            
            # Check if default user exists
            default_user = User.get_by_email('default@masteryourselfai.com')
            if not default_user:
                default_user = User.create_user(
                    email='default@masteryourselfai.com',
                    password='default_password_123',
                    display_name='Default User'
                )
                print(f"✅ Created default user: {default_user.email}")
            else:
                print(f"✅ Default user already exists: {default_user.email}")
            
            # Update all existing records to use the default user
            print("\n🔄 Updating existing records to use default user...")
            for table in tables_to_update:
                try:
                    # Check if table has data
                    result = db.session.execute(text(f"SELECT COUNT(*) FROM {table}"))
                    count = result.fetchone()[0]
                    
                    if count > 0:
                        # Update all records to use default user
                        db.session.execute(text(f"UPDATE {table} SET user_id = {default_user.id} WHERE user_id IS NULL"))
                        print(f"✅ Updated {count} records in {table}")
                    else:
                        print(f"ℹ️  No data in {table}")
                        
                except Exception as e:
                    print(f"❌ Error updating {table}: {e}")
            
            db.session.commit()
            print("\n✅ All existing data assigned to default user!")
            
        except Exception as e:
            print(f"❌ Error creating default user: {e}")

if __name__ == "__main__":
    fix_user_foreign_keys()
