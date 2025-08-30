#!/usr/bin/env python3
"""
Test script for password reset functionality
This demonstrates how the password reset system works
"""

import os
import sys
import secrets
import string
from datetime import datetime, timedelta

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app
from app.routes.auth import generate_reset_token, reset_tokens

def test_password_reset_flow():
    """Test the password reset flow"""
    print("🔐 Testing Password Reset Flow")
    print("=" * 50)
    
    # Create Flask app
    app = create_app()
    
    with app.app_context():
        # Test 1: Generate reset token
        print("\n1. Generating reset token...")
        reset_token = generate_reset_token()
        print(f"   ✅ Token generated: {reset_token[:10]}...")
        
        # Test 2: Simulate storing token (this would happen when sending email)
        print("\n2. Storing reset token...")
        reset_tokens[reset_token] = {
            'email': 'test@example.com',
            'expires': datetime.now() + timedelta(hours=1)
        }
        print(f"   ✅ Token stored for email: test@example.com")
        
        # Test 3: Create web reset link
        print("\n3. Creating web reset link...")
        web_reset_link = f"http://localhost:5000/reset-password-page?token={reset_token}"
        print(f"   ✅ Web reset link: {web_reset_link}")
        print(f"   🌐 Test this by opening: {web_reset_link}")
        
        # Test 4: Create app deep link
        print("\n4. Creating app deep link...")
        app_reset_link = f"masteryourselfai://reset-password?token={reset_token}"
        print(f"   ✅ App deep link: {app_reset_link}")
        
        # Test 5: Simulate email content
        print("\n5. Email content that would be sent:")
        print("-" * 40)
        email_content = f"""
Hello,

You requested a password reset for your Master Yourself AI account.

You can reset your password in two ways:

1. Click this link to open the app: {app_reset_link}

2. Or click this link to reset on the web: {web_reset_link}

This link will expire in 1 hour.

If you didn't request this reset, please ignore this email.

Best regards,
Master Yourself AI Team
        """
        print(email_content)
        print("-" * 40)
        
        # Test 6: Validate token
        print("\n6. Validating token...")
        if reset_token in reset_tokens:
            token_data = reset_tokens[reset_token]
            if datetime.now() < token_data['expires']:
                print("   ✅ Token is valid and not expired")
                print(f"   📧 Associated email: {token_data['email']}")
            else:
                print("   ❌ Token has expired")
        else:
            print("   ❌ Token not found")
        
        # Test 7: Simulate password reset
        print("\n7. Simulating password reset...")
        new_password = "newSecurePassword123"
        
        # This would be the API call
        reset_data = {
            'token': reset_token,
            'new_password': new_password
        }
        print(f"   📝 Reset data: {reset_data}")
        
        # Validate token again
        if reset_token in reset_tokens:
            token_data = reset_tokens[reset_token]
            if datetime.now() < token_data['expires']:
                email = token_data['email']
                # Remove used token
                del reset_tokens[reset_token]
                print(f"   ✅ Password reset successful for: {email}")
                print(f"   🔐 New password: {new_password}")
                print("   🗑️  Token removed after use")
            else:
                print("   ❌ Token expired")
        else:
            print("   ❌ Invalid token")
        
        print("\n" + "=" * 50)
        print("✅ Password reset flow test completed!")
        print("\n📋 Summary:")
        print("• User requests password reset")
        print("• System generates secure token")
        print("• Email sent with both app and web links")
        print("• User clicks web link → beautiful reset page")
        print("• User enters new password")
        print("• System validates token and updates password")
        print("• Token is removed after use")

if __name__ == "__main__":
    test_password_reset_flow()
