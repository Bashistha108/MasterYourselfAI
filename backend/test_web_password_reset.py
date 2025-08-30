#!/usr/bin/env python3
"""
Test the web password reset interface
"""

import requests
import json

def test_web_password_reset():
    """Test the web password reset interface"""
    print("🌐 Testing Web Password Reset Interface")
    print("=" * 40)
    
    base_url = "http://localhost:5000"
    
    try:
        # 1. Test if server is running
        print("1. Testing server connection...")
        response = requests.get(f"{base_url}/")
        print(f"   Server status: {response.status_code}")
        
        # 2. Test password reset page
        print("\n2. Testing password reset page...")
        test_token = "test_token_123"
        response = requests.get(f"{base_url}/reset-password-page?token={test_token}")
        print(f"   Reset page status: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ Reset page is accessible")
            
            # Check if the page contains the form
            if "resetPassword" in response.text:
                print("✅ Reset form found in page")
            else:
                print("❌ Reset form not found in page")
                
            # Check if the correct endpoint is being called
            if "/api/auth/reset-password" in response.text:
                print("✅ Correct endpoint (/api/auth/reset-password) found")
            else:
                print("❌ Wrong endpoint found")
                
        else:
            print("❌ Reset page not accessible")
            
        # 3. Test the actual reset endpoint
        print("\n3. Testing reset endpoint directly...")
        reset_data = {
            "token": "invalid_token",
            "new_password": "test_password"
        }
        
        response = requests.post(f"{base_url}/api/auth/reset-password", 
                               json=reset_data)
        print(f"   Reset endpoint status: {response.status_code}")
        print(f"   Response: {response.json()}")
        
        if response.status_code == 400:
            print("✅ Endpoint correctly rejects invalid token")
        else:
            print("❌ Endpoint should reject invalid token")
            
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to server. Is it running?")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_web_password_reset()
