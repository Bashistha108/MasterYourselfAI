#!/usr/bin/env python3
"""
Test script to verify email configuration
"""

import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def test_email_config():
    """Test email configuration"""
    print("📧 Testing Email Configuration")
    print("=" * 40)
    
    # Check environment variables
    email_address = os.getenv('FEEDBACK_EMAIL_ADDRESS')
    email_password = os.getenv('FEEDBACK_EMAIL_PASSWORD')
    
    print(f"Email Address: {'✅ Set' if email_address else '❌ Not set'}")
    if email_address:
        print(f"  Value: {email_address}")
    
    print(f"Email Password: {'✅ Set' if email_password else '❌ Not set'}")
    if email_password:
        print(f"  Value: {email_password[:4]}...{email_password[-4:] if len(email_password) > 8 else '***'}")
    
    # Test if we can import the email function
    try:
        from app.routes.auth import send_reset_email
        print("✅ Email function imported successfully")
        
        # Test sending a reset email
        print("\n🧪 Testing email sending...")
        test_email = "test@example.com"
        test_token = "test_token_123"
        
        result = send_reset_email(test_email, test_token)
        
        if result:
            print("✅ Email sent successfully!")
        else:
            print("❌ Email sending failed")
            
    except Exception as e:
        print(f"❌ Error importing email function: {e}")
    
    print("\n" + "=" * 40)

if __name__ == "__main__":
    test_email_config()
