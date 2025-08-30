#!/usr/bin/env python3
"""
Debug the exact issue with password reset
"""

import os
import sys
import requests
import json
import time

def debug_your_issue():
    """Debug the exact issue"""
    print("🔍 Debugging Your Password Reset Issue")
    print("=" * 40)
    
    # Test the running server
    base_url = "http://localhost:5000"
    
    try:
        print("1. Testing server connection...")
        response = requests.get(f"{base_url}/", timeout=5)
        print(f"   Server response: {response.status_code}")
        
        # Test login with different passwords
        print("\n2. Testing different passwords...")
        
        passwords_to_test = [
            "your_new_password_123",  # The password we set in our test
            "test_password_123",      # Old password
            "default_password_123",   # Another possible password
            "wrong_password_123"      # Obviously wrong password
        ]
        
        for password in passwords_to_test:
            print(f"\n   Testing password: {password}")
            login_data = {
                "email": "mikecpp82@gmail.com",
                "password": password
            }
            
            try:
                response = requests.post(f"{base_url}/api/auth/login", json=login_data, timeout=5)
                print(f"   Response: {response.status_code}")
                
                if response.status_code == 200:
                    print(f"   ✅ SUCCESS! Password '{password}' works!")
                    user_data = response.json()
                    print(f"   User: {user_data.get('user', {}).get('email', 'N/A')}")
                    print(f"   Updated at: {user_data.get('user', {}).get('updated_at', 'N/A')}")
                elif response.status_code == 401:
                    print(f"   ❌ Password '{password}' rejected (401)")
                else:
                    print(f"   ❓ Unexpected response: {response.status_code}")
                    print(f"   Response: {response.text}")
                    
            except requests.exceptions.RequestException as e:
                print(f"   ❌ Request failed: {e}")
        
        # Test password reset flow
        print("\n3. Testing password reset flow...")
        
        # Send reset request
        reset_request_data = {
            "email": "mikecpp82@gmail.com"
        }
        
        try:
            response = requests.post(f"{base_url}/api/auth/send-password-reset", json=reset_request_data, timeout=5)
            print(f"   Reset request response: {response.status_code}")
            print(f"   Response: {response.json()}")
            
            if response.status_code == 200:
                print("   ✅ Password reset request sent successfully")
                print("   📧 Check your email for the reset link")
            else:
                print("   ❌ Password reset request failed")
                
        except requests.exceptions.RequestException as e:
            print(f"   ❌ Reset request failed: {e}")
            
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to server. Make sure it's running on http://localhost:5000")
        print("   Start the server with: python run.py")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    debug_your_issue()
