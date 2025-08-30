#!/usr/bin/env python3
"""
Test if password 'aaaaaa' works
"""

import requests
import json

def test_aaaaaa_password():
    """Test if password 'aaaaaa' works"""
    print("🔍 Testing Password 'aaaaaa'")
    print("=" * 30)
    
    # Flask server URL
    base_url = "http://localhost:5000"
    test_email = "mikecpp82@gmail.com"
    test_password = "aaaaaa"
    
    print(f"Testing login with:")
    print(f"  Email: {test_email}")
    print(f"  Password: {test_password}")
    print()
    
    try:
        # Test login endpoint
        login_url = f"{base_url}/api/auth/login"
        login_data = {
            "email": test_email,
            "password": test_password
        }
        
        print(f"1. Sending POST request to: {login_url}")
        print(f"   Data: {json.dumps(login_data, indent=2)}")
        
        response = requests.post(login_url, json=login_data)
        
        print(f"\n2. Response Status: {response.status_code}")
        
        if response.status_code == 200:
            response_data = response.json()
            print(f"   Response Data: {json.dumps(response_data, indent=2)}")
            
            if response_data.get('success'):
                print("   ✅ SUCCESS! Password 'aaaaaa' works!")
                print(f"   User: {response_data.get('user', {})}")
                return True
            else:
                print("   ❌ Login failed!")
                print(f"   Error: {response_data.get('error', 'Unknown error')}")
                return False
        else:
            print(f"   ❌ HTTP Error: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Could not connect to Flask server. Is it running?")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    success = test_aaaaaa_password()
    if success:
        print(f"\n🎉 The password 'aaaaaa' works! You can now log in with this password.")
    else:
        print(f"\n❌ The password 'aaaaaa' does not work.")
