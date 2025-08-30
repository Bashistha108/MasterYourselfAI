#!/usr/bin/env python3
"""
Test MySQL connection and basic functionality
"""

import os
import sys

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db

def test_mysql():
    """Test MySQL connection and basic functionality"""
    print("🧪 Testing MySQL Connection")
    print("=" * 30)
    
    # Load MySQL environment variables
    os.environ['MYSQL_HOST'] = 'localhost'
    os.environ['MYSQL_PORT'] = '3306'
    os.environ['MYSQL_USER'] = 'master_ai_user'
    os.environ['MYSQL_PASSWORD'] = 'MasterAI2024!@#'
    os.environ['MYSQL_DATABASE'] = 'master_yourself_ai'
    
    app = create_app()
    
    with app.app_context():
        try:
            # Test connection
            print("Testing database connection...")
            with db.engine.connect() as conn:
                result = conn.execute(db.text("SELECT 1"))
                print("✅ Database connection successful!")
            
            # Test creating a user
            print("\nTesting user creation...")
            from app.models.user import User
            
            test_user = User.create_user(
                email='test@example.com',
                password='test_password_123',
                display_name='Test User'
            )
            print(f"✅ Created test user: {test_user.email} (ID: {test_user.id})")
            
            # Test creating a weekly goal
            print("\nTesting weekly goal creation...")
            from app.models.weekly_goals import WeeklyGoals
            
            test_goal = WeeklyGoals(
                user_id=test_user.id,
                title='Test Goal',
                description='This is a test goal'
            )
            db.session.add(test_goal)
            db.session.commit()
            print(f"✅ Created test goal: {test_goal.title} (ID: {test_goal.id})")
            
            # Test querying
            print("\nTesting queries...")
            users = User.query.all()
            print(f"✅ Found {len(users)} users")
            
            goals = WeeklyGoals.query.all()
            print(f"✅ Found {len(goals)} weekly goals")
            
            print("\n🎉 All tests passed! MySQL is working correctly.")
            
        except Exception as e:
            print(f"❌ Test failed: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    test_mysql()
