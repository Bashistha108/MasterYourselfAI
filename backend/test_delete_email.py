#!/usr/bin/env python3

import requests
import json

def test_delete_email():
    """Test deleting an email"""
    
    try:
        # First, get all emails
        emails_response = requests.get('http://localhost:5000/api/emails/')
        print(f"Emails Status: {emails_response.status_code}")
        emails_data = emails_response.json()
        emails = emails_data.get('data', [])
        print(f"Total emails before deletion: {len(emails)}")
        
        if emails:
            # Get the first email ID
            first_email = emails[0]
            email_id = first_email['id']
            subject = first_email['subject']
            
            print(f"Attempting to delete email: {email_id} - {subject}")
            
            # Delete the email
            delete_response = requests.delete(f'http://localhost:5000/api/emails/delete/{email_id}')
            print(f"Delete Status: {delete_response.status_code}")
            print(f"Delete Response: {delete_response.json()}")
            
            if delete_response.status_code == 200:
                print("✅ Email deleted successfully!")
                
                # Check emails again
                emails_response2 = requests.get('http://localhost:5000/api/emails/')
                emails_data2 = emails_response2.json()
                emails2 = emails_data2.get('data', [])
                print(f"Total emails after deletion: {len(emails2)}")
                
                if len(emails2) < len(emails):
                    print("✅ Email count decreased - deletion confirmed!")
                else:
                    print("❌ Email count didn't decrease")
            else:
                print("❌ Failed to delete email")
        else:
            print("❌ No emails found to delete")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_delete_email()
