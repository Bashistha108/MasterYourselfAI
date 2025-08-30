#!/usr/bin/env python3
"""
Test password reset with user's actual email
"""

import os
import sys
import subprocess

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db

def test_your_password_reset():
    """Test password reset with user's actual email"""
    print("🔍 Testing Password Reset with Your Email")
    print("=" * 40)
    
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
            
            # Your actual email
            your_email = 'mikecpp82@gmail.com'
            
            print(f"1. Checking your user: {your_email}")
            result = subprocess.run([
                'mysql', '-u', 'master_ai_user', '-pMasterAI2024!@#', 'master_yourself_ai',
                '-e', f"SELECT id, email, LEFT(password_hash, 50) as hash_preview FROM users WHERE email='{your_email}';"
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                if len(lines) >= 2:
                    parts = lines[1].split('\t')
                    user_id = parts[0]
                    email = parts[1]
                    current_hash = parts[2]
                    print(f"   User ID: {user_id}")
                    print(f"   Email: {email}")
                    print(f"   Current hash: {current_hash}...")
                else:
                    print("   No user found")
                    return
            else:
                print(f"   Error querying database: {result.stderr}")
                return
            
            print(f"\n2. Getting user from SQLAlchemy...")
            user = User.get_by_email(your_email)
            
            if user:
                print(f"   SQLAlchemy hash: {user.password_hash[:50]}...")
                
                # Generate a real reset token
                print(f"\n3. Generating reset token...")
                reset_token = generate_reset_token()
                reset_tokens[reset_token] = {
                    'email': your_email,
                    'expires': datetime.now() + timedelta(hours=1)
                }
                print(f"   Token: {reset_token}")
                
                # Test the reset endpoint
                print(f"\n4. Testing password reset...")
                new_password = 'your_new_password_123'
                
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
                            '-e', f"SELECT LEFT(password_hash, 50) as hash_preview FROM users WHERE email='{your_email}';"
                        ], capture_output=True, text=True)
                        
                        if result.returncode == 0:
                            lines = result.stdout.strip().split('\n')
                            if len(lines) >= 2:
                                new_hash = lines[1].strip()
                                print(f"   New hash in database: {new_hash}...")
                                
                                if new_hash != current_hash:
                                    print("   ✅ Database was updated!")
                                else:
                                    print("   ❌ Database was NOT updated!")
                                    
                                # Test login with new password
                                print(f"\n6. Testing login with new password...")
                                if user.check_password(new_password):
                                    print("   ✅ New password works!")
                                else:
                                    print("   ❌ New password doesn't work!")
                                    
                                # Test login endpoint
                                print(f"\n7. Testing login endpoint...")
                                with app.test_client() as client:
                                    login_response = client.post('/api/auth/login', 
                                                               json={
                                                                   'email': your_email,
                                                                   'password': new_password
                                                               })
                                    
                                    print(f"   Login response status: {login_response.status_code}")
                                    print(f"   Login response: {login_response.get_json()}")
                                    
                                    if login_response.status_code == 200:
                                        print("   ✅ Login successful with new password!")
                                    else:
                                        print("   ❌ Login failed with new password!")
                                    
                            else:
                                print("   ❌ User not found after reset")
                        else:
                            print(f"   ❌ Error querying database: {result.stderr}")
                    else:
                        print("   ❌ Password reset endpoint failed")
                        
            else:
                print(f"❌ User not found: {your_email}")
                
        except Exception as e:
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    from datetime import datetime, timedelta
    test_your_password_reset()
