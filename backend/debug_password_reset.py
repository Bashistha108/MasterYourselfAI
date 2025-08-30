#!/usr/bin/env python3
"""
Debug password reset functionality
"""

import os
import sys

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db

def debug_password_reset():
    """Debug password reset functionality"""
    print("🔍 Debugging Password Reset")
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
            from app.models.user import User
            
            # Test email
            test_email = 'test@example.com'
            
            print(f"1. Checking if user exists: {test_email}")
            user = User.get_by_email(test_email)
            
            if user:
                print(f"✅ User found: {user.email} (ID: {user.id})")
                print(f"   Current password hash: {user.password_hash[:50]}...")
                
                # Test old password
                old_password = 'test_password_123'
                print(f"2. Testing old password: {old_password}")
                if user.check_password(old_password):
                    print("✅ Old password works")
                else:
                    print("❌ Old password doesn't work")
                
                # Update password
                new_password = 'new_password_456'
                print(f"3. Setting new password: {new_password}")
                user.set_password(new_password)
                
                print(f"   New password hash: {user.password_hash[:50]}...")
                
                # Commit to database
                print("4. Committing to database...")
                db.session.commit()
                print("✅ Database committed")
                
                # Refresh user from database
                print("5. Refreshing user from database...")
                db.session.refresh(user)
                print(f"   Password hash after refresh: {user.password_hash[:50]}...")
                
                # Test new password
                print(f"6. Testing new password: {new_password}")
                if user.check_password(new_password):
                    print("✅ New password works!")
                else:
                    print("❌ New password doesn't work!")
                
                # Test old password (should fail)
                print(f"7. Testing old password (should fail): {old_password}")
                if user.check_password(old_password):
                    print("❌ Old password still works (this is wrong!)")
                else:
                    print("✅ Old password correctly fails")
                
            else:
                print(f"❌ User not found: {test_email}")
                
        except Exception as e:
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    debug_password_reset()
