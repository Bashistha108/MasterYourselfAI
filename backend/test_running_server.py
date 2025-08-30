#!/usr/bin/env python3
"""
Test the actual running Flask server
"""

import requests
import json

def test_running_server():
    """Test the actual running Flask server"""
    print("🌐 Testing Running Flask Server")
    print("=" * 35)
    
    base_url = "http://localhost:5000"
    
    try:
        # Test login with old password first
        print("1. Testing login with old password...")
        old_password_data = {
            "email": "mikecpp82@gmail.com",
            "password": "your_new_password_123"  # This should be the new password
        }
        
        response = requests.post(f"{base_url}/api/auth/login", json=old_password_data)
        print(f"   Login response status: {response.status_code}")
        print(f"   Login response: {response.json()}")
        
        if response.status_code == 200:
            print("   ✅ Login successful with new password")
        else:
            print("   ❌ Login failed with new password")
            
            # Try with a different password
            print("\n2. Testing with different passwords...")
            
            # Try the old password (from before our tests)
            old_password_data = {
                "email": "mikecpp82@gmail.com",
                "password": "test_password_123"
            }
            
            response = requests.post(f"{base_url}/api/auth/login", json=old_password_data)
            print(f"   Old password response: {response.status_code}")
            print(f"   Old password response: {response.json()}")
            
            if response.status_code == 200:
                print("   ✅ Old password still works - server is using different database!")
            else:
                print("   ❌ Old password doesn't work either")
                
        # Test database configuration
        print("\n3. Testing database configuration...")
        
        # Try to send a password reset request
        reset_data = {
            "email": "mikecpp82@gmail.com"
        }
        
        response = requests.post(f"{base_url}/api/auth/send-password-reset", json=reset_data)
        print(f"   Reset request status: {response.status_code}")
        print(f"   Reset response: {response.json()}")
        
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to server. Is it running?")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_running_server()
