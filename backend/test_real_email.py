#!/usr/bin/env python3
"""
Test script to send a real password reset email
"""

import os
import sys
from datetime import datetime, timedelta

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app
from app.routes.auth import generate_reset_token, send_reset_email

def test_real_email():
    """Test sending a real password reset email"""
    print("📧 Testing Real Email Sending")
    print("=" * 50)
    
    # Create Flask app
    app = create_app()
    
    with app.app_context():
        # Get email from user input
        email = input("Enter email address to send reset link to: ").strip()
        
        if not email:
            print("❌ No email provided")
            return
        
        print(f"\n📧 Sending password reset email to: {email}")
        
        # Generate reset token
        reset_token = generate_reset_token()
        print(f"🔐 Generated token: {reset_token[:10]}...")
        
        # Send the email
        print("\n📤 Sending email...")
        success = send_reset_email(email, reset_token)
        
        if success:
            print("✅ Email sent successfully!")
            print(f"\n🌐 Web reset link: http://localhost:5000/reset-password-page?token={reset_token}")
            print(f"📱 App deep link: masteryourselfai://reset-password?token={reset_token}")
            print("\n📋 Next steps:")
            print("1. Check your email inbox")
            print("2. Click the web link to test the reset page")
            print("3. Or start the server and test the full flow")
        else:
            print("❌ Failed to send email")
            print("Check the error messages above for details")

if __name__ == "__main__":
    test_real_email()
