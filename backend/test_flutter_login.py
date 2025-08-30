#!/usr/bin/env python3
"""
Test Flask login endpoint for Flutter app
"""

import requests
import json

def test_flutter_login():
    """Test the Flask login endpoint that Flutter will use"""
    print("🔍 Testing Flask Login Endpoint for Flutter")
    print("=" * 50)
    
    # Flask server URL
    base_url = "http://localhost:5000"
    
    # Test credentials
    test_email = "mikecpp82@gmail.com"
    test_password = "test_commit_123"  # This is the password we set in the database
    
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
        print(f"   Response Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            response_data = response.json()
            print(f"   Response Data: {json.dumps(response_data, indent=2)}")
            
            if response_data.get('success'):
                print("   ✅ Login successful!")
                print(f"   User: {response_data.get('user', {})}")
            else:
                print("   ❌ Login failed!")
                print(f"   Error: {response_data.get('error', 'Unknown error')}")
        else:
            print(f"   ❌ HTTP Error: {response.status_code}")
            print(f"   Response: {response.text}")
            
    except requests.exceptions.ConnectionError:
        print("❌ Could not connect to Flask server. Is it running?")
        print("   Start it with: python run.py")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_flutter_login()
