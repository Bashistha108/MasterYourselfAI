#!/usr/bin/env python3
"""
Test if database is actually being updated during password reset
"""

import os
import sys
import subprocess

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db

def test_db_update():
    """Test if database is actually being updated"""
    print("🔍 Testing Database Update During Password Reset")
    print("=" * 50)
    
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
            from app.routes.auth import reset_tokens, generate_reset_token
            
            # Test email
            test_email = 'test@example.com'
            
            print(f"1. Checking current password hash in database...")
            result = subprocess.run([
                'mysql', '-u', 'master_ai_user', '-pMasterAI2024!@#', 'master_yourself_ai',
                '-e', f"SELECT password_hash FROM users WHERE email='{test_email}';"
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                if len(lines) >= 2:
                    current_hash = lines[1].strip()
                    print(f"   Current hash: {current_hash[:50]}...")
                else:
                    print("   No user found")
                    return
            else:
                print(f"   Error querying database: {result.stderr}")
                return
            
            print(f"\n2. Getting user from SQLAlchemy...")
            user = User.get_by_email(test_email)
            
            if user:
                print(f"   SQLAlchemy hash: {user.password_hash[:50]}...")
                
                # Check if they match
                if user.password_hash == current_hash:
                    print("   ✅ SQLAlchemy and database match")
                else:
                    print("   ❌ SQLAlchemy and database don't match!")
                    print("   This indicates a caching issue")
                
                # Generate a real reset token
                print(f"\n3. Generating reset token...")
                reset_token = generate_reset_token()
                reset_tokens[reset_token] = {
                    'email': test_email,
                    'expires': datetime.now() + timedelta(hours=1)
                }
                print(f"   Token: {reset_token}")
                
                # Test the reset endpoint
                print(f"\n4. Testing password reset...")
                new_password = 'test_db_update_123'
                
                with app.test_client() as client:
                    response = client.post('/api/auth/reset-password', 
                                         json={
                                             'token': reset_token,
                                             'new_password': new_password
                                         })
                    
                    print(f"   Response status: {response.status_code}")
                    print(f"   Response: {response.get_json()}")
                    
                    if response.status_code == 200:
                        print("   ✅ Password reset endpoint succeeded")
                        
                        # Check database immediately after reset
                        print(f"\n5. Checking database after reset...")
                        result = subprocess.run([
                            'mysql', '-u', 'master_ai_user', '-pMasterAI2024!@#', 'master_yourself_ai',
                            '-e', f"SELECT password_hash FROM users WHERE email='{test_email}';"
                        ], capture_output=True, text=True)
                        
                        if result.returncode == 0:
                            lines = result.stdout.strip().split('\n')
                            if len(lines) >= 2:
                                new_hash = lines[1].strip()
                                print(f"   New hash in database: {new_hash[:50]}...")
                                
                                if new_hash != current_hash:
                                    print("   ✅ Database was updated!")
                                else:
                                    print("   ❌ Database was NOT updated!")
                                    
                                # Check if new password works
                                print(f"\n6. Testing new password...")
                                if user.check_password(new_password):
                                    print("   ✅ New password works with SQLAlchemy")
                                else:
                                    print("   ❌ New password doesn't work with SQLAlchemy")
                                    
                                # Refresh user from database
                                print(f"\n7. Refreshing user from database...")
                                db.session.refresh(user)
                                
                                if user.check_password(new_password):
                                    print("   ✅ New password works after refresh")
                                else:
                                    print("   ❌ New password doesn't work after refresh")
                                    
                            else:
                                print("   ❌ User not found after reset")
                        else:
                            print(f"   ❌ Error querying database: {result.stderr}")
                    else:
                        print("   ❌ Password reset endpoint failed")
                        
            else:
                print(f"❌ User not found: {test_email}")
                
        except Exception as e:
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    from datetime import datetime, timedelta
    test_db_update()
