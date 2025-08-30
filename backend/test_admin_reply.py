#!/usr/bin/env python3

import requests
import json

def test_admin_reply():
    """Test adding an admin reply"""
    
    # Test data
    test_data = {
        'subject': 'Re: [TEST] Admin Reply Test',
        'user_email': 'mikecpp82@gmail.com',
        'content': 'This is a test admin reply to verify the system is working correctly.'
    }
    
    try:
        # Send POST request to add admin reply
        response = requests.post(
            'http://localhost:5000/api/emails/add-admin-reply',
            json=test_data,
            headers={'Content-Type': 'application/json'}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        
        if response.status_code == 200:
            print("✅ Admin reply added successfully!")
            
            # Test getting emails
            emails_response = requests.get('http://localhost:5000/api/emails/')
            print(f"Emails Status: {emails_response.status_code}")
            emails_data = emails_response.json()
            print(f"Total emails: {len(emails_data.get('data', []))}")
            
        else:
            print("❌ Failed to add admin reply")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_admin_reply()
