#!/usr/bin/env python3
"""
Test script to check Google OAuth configuration
"""
import os

def test_google_config():
    """Test Google OAuth configuration"""
    print("🔍 Testing Google OAuth Configuration...")
    
    # Check environment variables
    google_client_id = os.getenv('GOOGLE_CLIENT_ID')
    feedback_email = os.getenv('FEEDBACK_EMAIL_ADDRESS')
    feedback_password = os.getenv('FEEDBACK_EMAIL_PASSWORD')
    
    print(f"✅ GOOGLE_CLIENT_ID: {'SET' if google_client_id else 'NOT SET'}")
    if google_client_id:
        print(f"   Value: {google_client_id[:20]}...")
    
    print(f"✅ FEEDBACK_EMAIL_ADDRESS: {'SET' if feedback_email else 'NOT SET'}")
    print(f"✅ FEEDBACK_EMAIL_PASSWORD: {'SET' if feedback_password else 'NOT SET'}")
    
    if not google_client_id:
        print("\n❌ GOOGLE_CLIENT_ID is not set!")
        print("To fix this:")
        print("1. Go to Google Cloud Console: https://console.cloud.google.com/")
        print("2. Select your project")
        print("3. Go to APIs & Services > Credentials")
        print("4. Create an OAuth 2.0 Client ID for Web application")
        print("5. Add authorized origins: https://masteryourselfai.onrender.com")
        print("6. Copy the Client ID and set it as GOOGLE_CLIENT_ID environment variable")
        print("7. Redeploy to Render")
    
    if not feedback_email or not feedback_password:
        print("\n❌ Email configuration is not set!")
        print("To fix this:")
        print("1. Set FEEDBACK_EMAIL_ADDRESS environment variable")
        print("2. Set FEEDBACK_EMAIL_PASSWORD environment variable")
        print("3. Redeploy to Render")

if __name__ == "__main__":
    test_google_config()
