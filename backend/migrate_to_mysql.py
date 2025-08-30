#!/usr/bin/env python3
"""
Migrate data from SQLite to MySQL
"""

import os
import sys
import sqlite3
import mysql.connector
from mysql.connector import Error
from datetime import datetime

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db

def migrate_to_mysql():
    """Migrate data from SQLite to MySQL"""
    print("🔄 Migrating from SQLite to MySQL")
    print("=" * 40)
    
    # Load MySQL environment variables
    os.environ['MYSQL_HOST'] = 'localhost'
    os.environ['MYSQL_PORT'] = '3306'
    os.environ['MYSQL_USER'] = 'master_ai_user'
    os.environ['MYSQL_PASSWORD'] = 'MasterAI2024!@#'
    os.environ['MYSQL_DATABASE'] = 'master_yourself_ai'
    
    app = create_app()
    
    with app.app_context():
        # Create all tables in MySQL
        print("Creating tables in MySQL...")
        db.create_all()
        print("✅ Tables created successfully!")
        
        # Connect to SQLite database
        sqlite_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'master_yourself_ai.db')
        print(f"Reading from SQLite: {sqlite_path}")
        
        if not os.path.exists(sqlite_path):
            print("❌ SQLite database not found!")
            return
        
        sqlite_conn = sqlite3.connect(sqlite_path)
        sqlite_cursor = sqlite_conn.cursor()
        
        # Get all tables from SQLite
        sqlite_cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = [row[0] for row in sqlite_cursor.fetchall()]
        
        print(f"Found {len(tables)} tables in SQLite")
        
        # Migrate each table
        for table in tables:
            try:
                print(f"Migrating table: {table}")
                
                # Get table structure
                sqlite_cursor.execute(f"PRAGMA table_info({table})")
                columns = sqlite_cursor.fetchall()
                
                # Get data
                sqlite_cursor.execute(f"SELECT * FROM {table}")
                rows = sqlite_cursor.fetchall()
                
                if rows:
                    print(f"  - Found {len(rows)} rows")
                    
                    # Insert data into MySQL
                    for row in rows:
                        # Convert row to dict
                        row_dict = {}
                        for i, col in enumerate(columns):
                            row_dict[col[1]] = row[i]
                        
                        # Insert into MySQL using SQLAlchemy
                        try:
                            # Import the model
                            if table == 'users':
                                from app.models.user import User
                                if 'email' in row_dict and row_dict['email']:
                                    user = User.get_by_email(row_dict['email'])
                                    if not user:
                                        User.create_user(
                                            email=row_dict['email'],
                                            password=row_dict.get('password_hash', 'default_password'),
                                            display_name=row_dict.get('display_name', '')
                                        )
                            elif table == 'weekly_goals':
                                from app.models.weekly_goals import WeeklyGoals
                                if 'title' in row_dict:
                                    goal = WeeklyGoals(
                                        user_id=row_dict.get('user_id', 1),
                                        title=row_dict['title'],
                                        description=row_dict.get('description', ''),
                                        week_start=datetime.fromisoformat(row_dict['week_start_date']) if row_dict.get('week_start_date') else None
                                    )
                                    goal.rating = row_dict.get('rating', 0)
                                    goal.completed = row_dict.get('completed', False)
                                    goal.archived = row_dict.get('archived', False)
                                    db.session.add(goal)
                            elif table == 'ai_challenges':
                                from app.models.ai_challenges import AIChallenges
                                if 'title' in row_dict:
                                    challenge = AIChallenges(
                                        user_id=row_dict.get('user_id', 1),
                                        title=row_dict['title'],
                                        description=row_dict.get('description', ''),
                                        difficulty=row_dict.get('difficulty', 'medium'),
                                        category=row_dict.get('category', 'general')
                                    )
                                    challenge.completed = row_dict.get('completed', False)
                                    challenge.rating = row_dict.get('rating', 0)
                                    db.session.add(challenge)
                            
                        except Exception as e:
                            print(f"    ⚠️  Error inserting row: {e}")
                            continue
                    
                    db.session.commit()
                    print(f"  ✅ Migrated {len(rows)} rows")
                else:
                    print(f"  ℹ️  No data in {table}")
                    
            except Exception as e:
                print(f"  ❌ Error migrating {table}: {e}")
        
        sqlite_conn.close()
        print("\n✅ Migration completed!")

if __name__ == "__main__":
    migrate_to_mysql()
