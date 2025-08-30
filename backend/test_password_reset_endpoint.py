#!/usr/bin/env python3
"""
Test the actual password reset endpoint
"""

import os
import sys
import requests
import json

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db

def test_password_reset_endpoint():
    """Test the password reset endpoint"""
    print("🧪 Testing Password Reset Endpoint")
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
            
            # Test email
            test_email = 'test@example.com'
            
            print(f"1. Checking current user: {test_email}")
            user = User.get_by_email(test_email)
            
            if user:
                print(f"✅ User found: {user.email} (ID: {user.id})")
                print(f"   Current password hash: {user.password_hash[:50]}...")
                
                # Test current password
                current_password = 'new_password_456'  # From previous test
                print(f"2. Testing current password: {current_password}")
                if user.check_password(current_password):
                    print("✅ Current password works")
                else:
                    print("❌ Current password doesn't work")
                
                # Now test the actual reset endpoint
                print("\n3. Testing password reset endpoint...")
                
                # First, we need to generate a reset token
                from app.routes.auth import reset_tokens, generate_reset_token
                
                # Generate a test token
                test_token = generate_reset_token()
                reset_tokens[test_token] = {
                    'email': test_email,
                    'expires': datetime.now() + timedelta(hours=1)
                }
                
                print(f"   Generated test token: {test_token}")
                
                # Test the reset password endpoint
                new_password = 'reset_password_789'
                
                # Create a test request
                with app.test_client() as client:
                    response = client.post('/api/auth/reset-password', 
                                         json={
                                             'token': test_token,
                                             'new_password': new_password
                                         })
                    
                    print(f"   Response status: {response.status_code}")
                    print(f"   Response data: {response.get_json()}")
                    
                    if response.status_code == 200:
                        print("✅ Password reset endpoint worked!")
                        
                        # Check if password was actually updated
                        print("\n4. Verifying password was updated...")
                        db.session.refresh(user)
                        
                        if user.check_password(new_password):
                            print("✅ New password works!")
                        else:
                            print("❌ New password doesn't work!")
                        
                        if user.check_password(current_password):
                            print("❌ Old password still works (this is wrong!)")
                        else:
                            print("✅ Old password correctly fails")
                            
                    else:
                        print("❌ Password reset endpoint failed!")
                        
            else:
                print(f"❌ User not found: {test_email}")
                
        except Exception as e:
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    from datetime import datetime, timedelta
    test_password_reset_endpoint()
