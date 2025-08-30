#!/usr/bin/env python3
"""
Debug user password and verification
"""

import os
import sys
import subprocess

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db

def debug_user_password():
    """Debug user password and verification"""
    print("🔍 Debugging User Password")
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
            from werkzeug.security import check_password_hash
            
            # Test email
            test_email = 'mikecpp82@gmail.com'
            
            print(f"1. Checking if user exists: {test_email}")
            
            # Check database directly
            result = subprocess.run([
                'mysql', '-u', 'master_ai_user', '-pMasterAI2024!@#', 'master_yourself_ai',
                '-e', f"SELECT id, email, password_hash, created_at, updated_at FROM users WHERE email='{test_email}';"
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                if len(lines) >= 2:
                    parts = lines[1].split('\t')
                    user_id = parts[0]
                    email = parts[1]
                    password_hash = parts[2]
                    created_at = parts[3] if len(parts) > 3 else 'N/A'
                    updated_at = parts[4] if len(parts) > 4 else 'N/A'
                    
                    print(f"   ✅ User found in database:")
                    print(f"      ID: {user_id}")
                    print(f"      Email: {email}")
                    print(f"      Password Hash: {password_hash[:50]}...")
                    print(f"      Created: {created_at}")
                    print(f"      Updated: {updated_at}")
                    
                    # Test password verification manually
                    print(f"\n2. Testing password verification manually...")
                    
                    test_passwords = [
                        "test_commit_123",
                        "your_new_password_123",
                        "old_password",
                        "password123",
                        "test123"
                    ]
                    
                    for password in test_passwords:
                        is_valid = check_password_hash(password_hash, password)
                        print(f"   Password '{password}': {'✅ Valid' if is_valid else '❌ Invalid'}")
                    
                    # Test with SQLAlchemy
                    print(f"\n3. Testing with SQLAlchemy User model...")
                    user = User.get_by_email(test_email)
                    
                    if user:
                        print(f"   ✅ User found via SQLAlchemy:")
                        print(f"      ID: {user.id}")
                        print(f"      Email: {user.email}")
                        print(f"      Password Hash: {user.password_hash[:50]}...")
                        
                        # Test password checking
                        for password in test_passwords:
                            is_valid = user.check_password(password)
                            print(f"   Password '{password}': {'✅ Valid' if is_valid else '❌ Invalid'}")
                    else:
                        print(f"   ❌ User not found via SQLAlchemy!")
                        
                else:
                    print(f"   ❌ User not found in database!")
            else:
                print(f"   ❌ Error querying database: {result.stderr}")
                
        except Exception as e:
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    debug_user_password()
