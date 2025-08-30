#!/usr/bin/env python3
"""
Debug script to test email sending
"""

import os
import sys
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def debug_email():
    """Debug email sending"""
    print("🔍 Debugging Email Sending")
    print("=" * 50)
    
    # Check environment variables
    sender_email = os.getenv('FEEDBACK_EMAIL_ADDRESS')
    sender_password = os.getenv('FEEDBACK_EMAIL_PASSWORD')
    
    print(f"Sender Email: {sender_email}")
    print(f"Sender Password: {'***' if sender_password else 'Not set'}")
    
    # Test email
    test_email = "test@example.com"
    print(f"Test Email: {test_email}")
    
    # Import and test the function
    try:
        from app.routes.auth import send_reset_email
        print("\n📤 Testing email sending...")
        
        # Call the function
        result = send_reset_email(test_email, "test_token_123")
        
        print(f"Result: {result}")
        
        # Check if token was stored
        from app.routes.auth import reset_tokens
        print(f"Stored tokens: {list(reset_tokens.keys())}")
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    debug_email()
