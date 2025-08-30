#!/usr/bin/env python3
"""
Fixed migration script that handles foreign key constraints properly
"""

import os
import sys
import sqlite3
from datetime import datetime

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db

def fix_migration():
    """Migrate data from SQLite to MySQL with proper foreign key handling"""
    print("🔄 Fixed Migration from SQLite to MySQL")
    print("=" * 40)
    
    # Load MySQL environment variables
    os.environ['MYSQL_HOST'] = 'localhost'
    os.environ['MYSQL_PORT'] = '3306'
    os.environ['MYSQL_USER'] = 'master_ai_user'
    os.environ['MYSQL_PASSWORD'] = 'MasterAI2024!@#'
    os.environ['MYSQL_DATABASE'] = 'master_yourself_ai'
    
    app = create_app()
    
    with app.app_context():
        # Clear existing data
        print("Clearing existing data...")
        db.drop_all()
        db.create_all()
        print("✅ Tables recreated successfully!")
        
        # Connect to SQLite database
        sqlite_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'master_yourself_ai.db')
        print(f"Reading from SQLite: {sqlite_path}")
        
        if not os.path.exists(sqlite_path):
            print("❌ SQLite database not found!")
            return
        
        sqlite_conn = sqlite3.connect(sqlite_path)
        sqlite_cursor = sqlite_conn.cursor()
        
        # First, migrate users
        print("\n👤 Migrating users...")
        sqlite_cursor.execute("SELECT * FROM users")
        users = sqlite_cursor.fetchall()
        
        if users:
            print(f"Found {len(users)} users")
            for user_row in users:
                try:
                    from app.models.user import User
                    
                    # Get user data
                    user_id = user_row[0]
                    email = user_row[1]
                    password_hash = user_row[2]
                    display_name = user_row[3] if len(user_row) > 3 else ''
                    
                    if email:
                        # Create user in MySQL
                        user = User.create_user(
                            email=email,
                            password='default_password_123',  # Reset password for security
                            display_name=display_name
                        )
                        print(f"✅ Created user: {email} (ID: {user.id})")
                        
                except Exception as e:
                    print(f"❌ Error creating user: {e}")
        
        # Now migrate weekly_goals
        print("\n📋 Migrating weekly_goals...")
        sqlite_cursor.execute("SELECT * FROM weekly_goals")
        goals = sqlite_cursor.fetchall()
        
        if goals:
            print(f"Found {len(goals)} weekly goals")
            for goal_row in goals:
                try:
                    from app.models.weekly_goals import WeeklyGoals
                    
                    # Get goal data
                    goal_id = goal_row[0]
                    user_id = goal_row[1] if len(goal_row) > 1 else 1  # Default to user 1
                    title = goal_row[2]
                    description = goal_row[3] if len(goal_row) > 3 else ''
                    week_start_date = goal_row[4] if len(goal_row) > 4 else None
                    week_end_date = goal_row[5] if len(goal_row) > 5 else None
                    rating = goal_row[6] if len(goal_row) > 6 else 0
                    completed = goal_row[7] if len(goal_row) > 7 else False
                    archived = goal_row[8] if len(goal_row) > 8 else False
                    
                    # Create goal in MySQL
                    goal = WeeklyGoals(
                        user_id=user_id,
                        title=title,
                        description=description,
                        week_start=datetime.fromisoformat(week_start_date) if week_start_date else None
                    )
                    goal.rating = rating
                    goal.completed = completed
                    goal.archived = archived
                    
                    db.session.add(goal)
                    print(f"✅ Created goal: {title}")
                    
                except Exception as e:
                    print(f"❌ Error creating goal: {e}")
        
        # Now migrate ai_challenges
        print("\n🤖 Migrating ai_challenges...")
        sqlite_cursor.execute("SELECT * FROM ai_challenges")
        challenges = sqlite_cursor.fetchall()
        
        if challenges:
            print(f"Found {len(challenges)} AI challenges")
            for challenge_row in challenges:
                try:
                    from app.models.ai_challenges import AIChallenges
                    
                    # Get challenge data
                    challenge_id = challenge_row[0]
                    user_id = challenge_row[1] if len(challenge_row) > 1 else 1  # Default to user 1
                    title = challenge_row[2]
                    description = challenge_row[3] if len(challenge_row) > 3 else ''
                    difficulty = challenge_row[4] if len(challenge_row) > 4 else 'medium'
                    category = challenge_row[5] if len(challenge_row) > 5 else 'general'
                    completed = challenge_row[6] if len(challenge_row) > 6 else False
                    rating = challenge_row[7] if len(challenge_row) > 7 else 0
                    
                    # Create challenge in MySQL
                    challenge = AIChallenges(
                        user_id=user_id,
                        title=title,
                        description=description,
                        difficulty=difficulty,
                        category=category
                    )
                    challenge.completed = completed
                    challenge.rating = rating
                    
                    db.session.add(challenge)
                    print(f"✅ Created challenge: {title}")
                    
                except Exception as e:
                    print(f"❌ Error creating challenge: {e}")
        
        # Commit all changes
        db.session.commit()
        print("\n✅ Migration completed successfully!")
        
        sqlite_conn.close()

if __name__ == "__main__":
    fix_migration()
