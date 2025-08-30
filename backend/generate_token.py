#!/usr/bin/env python3
"""
Generate a fresh token for testing the reset password page
"""

import os
import sys
from datetime import datetime, timedelta

# Add the current directory to the path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app
from app.routes.auth import generate_reset_token, reset_tokens

def generate_fresh_token():
    """Generate a fresh token for testing"""
    print("🔐 Generating Fresh Token for Testing")
    print("=" * 50)
    
    # Create Flask app
    app = create_app()
    
    with app.app_context():
        # Generate fresh token
        reset_token = generate_reset_token()
        print(f"✅ Fresh token generated: {reset_token}")
        
        # Store token with expiration (1 hour)
        reset_tokens[reset_token] = {
            'email': 'test@example.com',
            'expires': datetime.now() + timedelta(hours=1)
        }
        print(f"✅ Token stored and will expire in 1 hour")
        
        # Create the URL
        web_reset_link = f"http://localhost:5000/reset-password-page?token={reset_token}"
        print(f"\n🌐 Test this URL:")
        print(f"{web_reset_link}")
        
        print(f"\n📱 App deep link:")
        print(f"masteryourselfai://reset-password?token={reset_token}")
        
        print(f"\n⏰ Token expires at: {reset_tokens[reset_token]['expires']}")
        print(f"📧 Associated email: {reset_tokens[reset_token]['email']}")

if __name__ == "__main__":
    generate_fresh_token()
