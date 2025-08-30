#!/usr/bin/env python3
"""
Final test to verify password reset with the running server
"""

import requests
import json
import time

def test_final_password_reset():
    """Test password reset with the running server"""
    print("🔍 Final Password Reset Test with Running Server")
    print("=" * 45)
    
    base_url = "http://localhost:5000"
    
    try:
        # Wait a moment for server to be ready
        print("1. Waiting for server to be ready...")
        time.sleep(2)
        
        # Test current password
        print("\n2. Testing current password...")
        current_password_data = {
            "email": "mikecpp82@gmail.com",
            "password": "your_new_password_123"
        }
        
        response = requests.post(f"{base_url}/api/auth/login", json=current_password_data)
        print(f"   Current password response: {response.status_code}")
        print(f"   Response: {response.json()}")
        
        if response.status_code == 200:
            print("   ✅ Current password works")
        else:
            print("   ❌ Current password doesn't work")
        
        # Send password reset request
        print("\n3. Sending password reset request...")
        reset_request_data = {
            "email": "mikecpp82@gmail.com"
        }
        
        response = requests.post(f"{base_url}/api/auth/send-password-reset", json=reset_request_data)
        print(f"   Reset request response: {response.status_code}")
        print(f"   Response: {response.json()}")
        
        if response.status_code == 200:
            print("   ✅ Password reset request sent successfully")
            print("   📧 Check your email for the reset link")
        else:
            print("   ❌ Password reset request failed")
            
        # Test with a completely new password
        print("\n4. Testing with a completely new password...")
        
        # First, let's try to login with a random password to see what happens
        random_password_data = {
            "email": "mikecpp82@gmail.com",
            "password": "completely_random_password_123"
        }
        
        response = requests.post(f"{base_url}/api/auth/login", json=random_password_data)
        print(f"   Random password response: {response.status_code}")
        print(f"   Response: {response.json()}")
        
        if response.status_code == 401:
            print("   ✅ Server correctly rejects wrong password")
        else:
            print("   ❌ Server should reject wrong password")
            
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to server. Make sure it's running on http://localhost:5000")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_final_password_reset()
