#!/usr/bin/env python3
"""
Test what password currently works for the user
"""

import requests
import json

def test_current_password():
    """Test different passwords to see which one works"""
    print("🔍 Testing Current Password for User")
    print("=" * 40)
    
    # Flask server URL
    base_url = "http://localhost:5000"
    test_email = "mikecpp82@gmail.com"
    
    # Test different passwords
    passwords_to_test = [
        "test_commit_123",
        "your_new_password_123", 
        "old_password",
        "password123",
        "test123"
    ]
    
    for password in passwords_to_test:
        print(f"\nTesting password: '{password}'")
        
        try:
            login_url = f"{base_url}/api/auth/login"
            login_data = {
                "email": test_email,
                "password": password
            }
            
            response = requests.post(login_url, json=login_data)
            
            if response.status_code == 200:
                response_data = response.json()
                if response_data.get('success'):
                    print(f"   ✅ SUCCESS! Password '{password}' works!")
                    return password
                else:
                    print(f"   ❌ Failed: {response_data.get('error', 'Unknown error')}")
            else:
                print(f"   ❌ HTTP {response.status_code}: {response.text}")
                
        except Exception as e:
            print(f"   ❌ Error: {e}")
    
    print(f"\n❌ None of the tested passwords worked!")
    return None

if __name__ == "__main__":
    working_password = test_current_password()
    if working_password:
        print(f"\n🎉 The working password is: '{working_password}'")
    else:
        print(f"\n💡 You may need to reset the password again")
