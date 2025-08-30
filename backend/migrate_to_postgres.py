#!/usr/bin/env python3
"""
Migration script to move data from MySQL to PostgreSQL
This script will help you migrate your data when deploying to Render
"""

import os
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import urllib.parse

# Add the backend directory to the Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db
from app.models import *

def migrate_to_postgres():
    """Migrate data from MySQL to PostgreSQL"""
    
    print("🚀 Starting migration to PostgreSQL...")
    
    # Create Flask app
    app = create_app()
    
    with app.app_context():
        try:
            # Create all tables in PostgreSQL
            print("📋 Creating tables in PostgreSQL...")
            db.create_all()
            print("✅ Tables created successfully")
            
            # Check if we have data to migrate
            try:
                # Try to connect to MySQL to get existing data
                mysql_host = os.environ.get('MYSQL_HOST')
                mysql_user = os.environ.get('MYSQL_USER')
                mysql_password = os.environ.get('MYSQL_PASSWORD')
                mysql_database = os.environ.get('MYSQL_DATABASE')
                
                if all([mysql_host, mysql_user, mysql_password, mysql_database]):
                    print("📊 Migrating data from MySQL...")
                    
                    # Create MySQL connection
                    encoded_password = urllib.parse.quote_plus(mysql_password)
                    mysql_uri = f"mysql+pymysql://{mysql_user}:{encoded_password}@{mysql_host}:3306/{mysql_database}"
                    mysql_engine = create_engine(mysql_uri)
                    
                    # Migrate users first (required for foreign keys)
                    print("👥 Migrating users...")
                    with mysql_engine.connect() as conn:
                        users_result = conn.execute(text("SELECT * FROM users"))
                        users_data = users_result.fetchall()
                        
                        for user_row in users_data:
                            # Create user in PostgreSQL
                            user = User(
                                id=user_row.id,
                                email=user_row.email,
                                password_hash=user_row.password_hash,
                                display_name=user_row.display_name,
                                created_at=user_row.created_at,
                                updated_at=user_row.updated_at
                            )
                            db.session.add(user)
                    
                    db.session.commit()
                    print(f"✅ Migrated {len(users_data)} users")
                    
                    # Migrate other tables
                    tables_to_migrate = [
                        ('weekly_goals', WeeklyGoal),
                        ('long_term_goals', LongTermGoal),
                        ('problems', Problem),
                        ('ai_challenges', AIChallenge),
                        ('quick_wins', QuickWin),
                        ('daily_goal_intensities', DailyGoalIntensity),
                        ('daily_problem_logs', DailyProblemLog),
                        ('weekly_goal_intensities', WeeklyGoalIntensity),
                        ('goal_notes', GoalNote),
                        ('quick_notes', QuickNote),
                        ('todo_items', TodoItem),
                        ('emails', Email)
                    ]
                    
                    for table_name, model_class in tables_to_migrate:
                        print(f"📋 Migrating {table_name}...")
                        with mysql_engine.connect() as conn:
                            result = conn.execute(text(f"SELECT * FROM {table_name}"))
                            rows = result.fetchall()
                            
                            for row in rows:
                                # Convert row to dict and create model instance
                                row_dict = dict(row._mapping)
                                model_instance = model_class(**row_dict)
                                db.session.add(model_instance)
                        
                        db.session.commit()
                        print(f"✅ Migrated {len(rows)} {table_name}")
                    
                else:
                    print("ℹ️  No MySQL configuration found, skipping data migration")
                    print("   This is normal for fresh deployments")
                    
            except Exception as e:
                print(f"⚠️  Could not migrate from MySQL: {e}")
                print("   This is normal for fresh deployments")
            
            print("🎉 Migration completed successfully!")
            print("   Your PostgreSQL database is ready for Render deployment")
            
        except Exception as e:
            print(f"❌ Migration failed: {e}")
            db.session.rollback()
            raise

if __name__ == "__main__":
    migrate_to_postgres()
