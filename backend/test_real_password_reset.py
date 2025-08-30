#!/usr/bin/env python3
"""
Test the complete password reset flow with a real token
"""

import os
import sys
import requests
import json

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db

def test_real_password_reset():
    """Test the complete password reset flow"""
    print("🔄 Testing Complete Password Reset Flow")
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
            
            # Test email
            test_email = 'test@example.com'
            
            print(f"1. Checking user: {test_email}")
            user = User.get_by_email(test_email)
            
            if user:
                print(f"✅ User found: {user.email} (ID: {user.id})")
                
                # Generate a real reset token
                print("\n2. Generating reset token...")
                reset_token = generate_reset_token()
                reset_tokens[reset_token] = {
                    'email': test_email,
                    'expires': datetime.now() + timedelta(hours=1)
                }
                print(f"   Token: {reset_token}")
                
                # Test the reset page with real token
                print("\n3. Testing reset page with real token...")
                with app.test_client() as client:
                    response = client.get(f'/reset-password-page?token={reset_token}')
                    print(f"   Reset page status: {response.status_code}")
                    
                    if response.status_code == 200:
                        print("✅ Reset page accessible with real token")
                        
                        # Check if form is present
                        if "reset-form" in response.get_data(as_text=True):
                            print("✅ Reset form found")
                        else:
                            print("❌ Reset form not found")
                            
                    else:
                        print(f"❌ Reset page failed: {response.get_data(as_text=True)}")
                
                # Test the reset endpoint with real token
                print("\n4. Testing reset endpoint with real token...")
                new_password = 'real_reset_password_123'
                
                with app.test_client() as client:
                    response = client.post('/api/auth/reset-password', 
                                         json={
                                             'token': reset_token,
                                             'new_password': new_password
                                         })
                    
                    print(f"   Reset endpoint status: {response.status_code}")
                    print(f"   Response: {response.get_json()}")
                    
                    if response.status_code == 200:
                        print("✅ Password reset successful!")
                        
                        # Verify password was updated
                        print("\n5. Verifying password update...")
                        db.session.refresh(user)
                        
                        if user.check_password(new_password):
                            print("✅ New password works!")
                        else:
                            print("❌ New password doesn't work!")
                            
                    else:
                        print("❌ Password reset failed!")
                        
            else:
                print(f"❌ User not found: {test_email}")
                
        except Exception as e:
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    from datetime import datetime, timedelta
    test_real_password_reset()
