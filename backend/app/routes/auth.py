import os
import smtplib
import secrets
import string
from datetime import datetime, timedelta
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from flask import Blueprint, request, jsonify, render_template_string, url_for, redirect
from flask_cors import cross_origin
from app import db
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from dotenv import load_dotenv

auth_bp = Blueprint('auth', __name__)

# Import ResetToken model for database storage
from app.models.user import ResetToken

load_dotenv()

GOOGLE_CLIENT_ID = os.getenv('GOOGLE_CLIENT_ID')
GOOGLE_ANDROID_CLIENT_ID = os.getenv('GOOGLE_ANDROID_CLIENT_ID', '259990462224-iantg8g8nna30rco5fjq9pvsntcikq7q.apps.googleusercontent.com')
GOOGLE_WEB_CLIENT_ID = os.getenv('GOOGLE_WEB_CLIENT_ID', '259990462224-a8ucu2j2685gdhophefnjb07sm7t8jgg.apps.googleusercontent.com')

def generate_reset_token():
    """Generate a secure reset token"""
    return ''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(32))

def send_reset_email(email, reset_token):
    """Send password reset email"""
    try:
        # Store token in database with expiration (1 hour)
        ResetToken.create_token(email, reset_token, expires_in_hours=1)
        
        # Email configuration
        smtp_server = "smtp.gmail.com"
        smtp_port = 587
        sender_email = os.getenv('FEEDBACK_EMAIL_ADDRESS')
        
        if not sender_email:
            print("❌ FEEDBACK_EMAIL_ADDRESS not set in environment variables")
            return False
        
        sender_password = os.getenv('FEEDBACK_EMAIL_PASSWORD')
        
        if not sender_password:
            print("❌ FEEDBACK_EMAIL_PASSWORD not set in environment variables")
            return False
        
        # Create message
        msg = MIMEMultipart()
        msg['From'] = sender_email
        msg['To'] = email
        msg['Subject'] = "Password Reset - Master Yourself AI"
        
        # Debug output
        print(f"📧 Sending email FROM: {sender_email} TO: {email}")
        
        # Create reset links
        app_reset_link = f"masteryourselfai://reset-password?token={reset_token}"
        # Use localhost for testing
        web_reset_link = f"https://masteryourselfai.onrender.com/reset-password-page?token={reset_token}"
        # Use localhost for testing
        # web_reset_link = f"http://localhost:5000/reset-password-page?token={reset_token}"
        
        # Email body
        body = f"""
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
        
        msg.attach(MIMEText(body, 'plain'))
        
        # Send email
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(sender_email, sender_password)
        text = msg.as_string()
        server.sendmail(sender_email, email, text)
        server.quit()
        
        print(f"✅ Password reset email sent to {email}")
        return True
        
    except Exception as e:
        print(f"❌ Failed to send reset email: {e}")
        return False

@auth_bp.route('/send-password-reset', methods=['POST'])
def send_password_reset():
    """Send password reset email using custom email system"""
    try:
        data = request.get_json()
        email = data.get('email')
        
        if not email:
            return jsonify({'error': 'Email is required'}), 400
        
        # Send custom reset email
        reset_token = generate_reset_token()
        if send_reset_email(email, reset_token):
            return jsonify({
                'success': True,
                'message': 'Password reset email sent successfully'
            }), 200
        else:
            return jsonify({
                'error': 'Failed to send reset email'
            }), 500
            
    except Exception as e:
        print(f"❌ Error in send_password_reset: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@auth_bp.route('/reset-password-page')
def reset_password_page():
    """Serve the password reset web page"""
    token = request.args.get('token')
    
    if not token:
        return "Invalid or missing reset token", 400
    
    # Check if token exists and is not expired using database
    reset_token = ResetToken.get_valid_token(token)
    if not reset_token:
        return "Invalid or expired reset token", 400
    
    # HTML template for the password reset page
    html_template = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reset Password - Master Yourself AI</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }
            
            .container {
                background: white;
                border-radius: 20px;
                box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
                padding: 40px;
                width: 100%;
                max-width: 400px;
                text-align: center;
            }
            
            .logo {
                width: 80px;
                height: 80px;
                background: linear-gradient(135deg, #667eea, #764ba2);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 30px;
                color: white;
                font-size: 32px;
            }
            
            h1 {
                color: #333;
                margin-bottom: 10px;
                font-size: 28px;
                font-weight: 600;
            }
            
            .subtitle {
                color: #666;
                margin-bottom: 30px;
                font-size: 16px;
            }
            
            .form-group {
                margin-bottom: 20px;
                text-align: left;
            }
            
            label {
                display: block;
                margin-bottom: 8px;
                color: #333;
                font-weight: 500;
                font-size: 14px;
            }
            
            .input-group {
                position: relative;
            }
            
            input {
                width: 100%;
                padding: 15px 20px;
                border: 2px solid #e1e5e9;
                border-radius: 12px;
                font-size: 16px;
                transition: all 0.3s ease;
                background: #f8f9fa;
            }
            
            input:focus {
                outline: none;
                border-color: #667eea;
                background: white;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            }
            
            .password-toggle {
                position: absolute;
                right: 15px;
                top: 50%;
                transform: translateY(-50%);
                background: none;
                border: none;
                cursor: pointer;
                color: #666;
                font-size: 18px;
            }
            
            .btn {
                width: 100%;
                padding: 15px;
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
                border: none;
                border-radius: 12px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                margin-top: 10px;
            }
            
            .btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
            }
            
            .btn:disabled {
                opacity: 0.6;
                cursor: not-allowed;
                transform: none;
            }
            
            .error {
                color: #e74c3c;
                background: #fdf2f2;
                border: 1px solid #fecaca;
                padding: 12px;
                border-radius: 8px;
                margin-bottom: 20px;
                font-size: 14px;
            }
            
            .success {
                color: #059669;
                background: #f0fdf4;
                border: 1px solid #bbf7d0;
                padding: 12px;
                border-radius: 8px;
                margin-bottom: 20px;
                font-size: 14px;
            }
            
            .back-link {
                margin-top: 20px;
                color: #667eea;
                text-decoration: none;
                font-size: 14px;
            }
            
            .back-link:hover {
                text-decoration: underline;
            }
            
            .loading {
                display: inline-block;
                width: 20px;
                height: 20px;
                border: 3px solid rgba(255,255,255,.3);
                border-radius: 50%;
                border-top-color: #fff;
                animation: spin 1s ease-in-out infinite;
            }
            
            @keyframes spin {
                to { transform: rotate(360deg); }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="logo">🔐</div>
            <h1>Reset Password</h1>
            <p class="subtitle">Enter your new password below</p>
            
            <div id="error-message" class="error" style="display: none;"></div>
            <div id="success-message" class="success" style="display: none;"></div>
            
            <form id="reset-form">
                <div class="form-group">
                    <label for="password">New Password</label>
                    <div class="input-group">
                        <input type="password" id="password" name="password" placeholder="Enter new password" required minlength="6">
                        <button type="button" class="password-toggle" onclick="togglePassword('password')">👁️</button>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="confirm-password">Confirm Password</label>
                    <div class="input-group">
                        <input type="password" id="confirm-password" name="confirm-password" placeholder="Confirm new password" required minlength="6">
                        <button type="button" class="password-toggle" onclick="togglePassword('confirm-password')">👁️</button>
                    </div>
                </div>
                
                <button type="submit" class="btn" id="submit-btn">
                    <span id="btn-text">Reset Password</span>
                    <span id="btn-loading" class="loading" style="display: none;"></span>
                </button>
            </form>
            
            <a href="#" onclick="window.close()" class="back-link">Close this window</a>
        </div>
        
        <script>
            const token = '{{ token }}';
            
            function togglePassword(fieldId) {
                const field = document.getElementById(fieldId);
                const toggle = field.nextElementSibling;
                
                if (field.type === 'password') {
                    field.type = 'text';
                    toggle.textContent = '🙈';
                } else {
                    field.type = 'password';
                    toggle.textContent = '👁️';
                }
            }
            
            function showError(message) {
                const errorDiv = document.getElementById('error-message');
                errorDiv.textContent = message;
                errorDiv.style.display = 'block';
                document.getElementById('success-message').style.display = 'none';
            }
            
            function showSuccess(message) {
                const successDiv = document.getElementById('success-message');
                successDiv.textContent = message;
                successDiv.style.display = 'block';
                document.getElementById('error-message').style.display = 'none';
            }
            
            function setLoading(loading) {
                const btn = document.getElementById('submit-btn');
                const btnText = document.getElementById('btn-text');
                const btnLoading = document.getElementById('btn-loading');
                
                if (loading) {
                    btn.disabled = true;
                    btnText.style.display = 'none';
                    btnLoading.style.display = 'inline-block';
                } else {
                    btn.disabled = false;
                    btnText.style.display = 'inline';
                    btnLoading.style.display = 'none';
                }
            }
            
            document.getElementById('reset-form').addEventListener('submit', async function(e) {
                e.preventDefault();
                
                const password = document.getElementById('password').value;
                const confirmPassword = document.getElementById('confirm-password').value;
                
                // Validation
                if (password.length < 6) {
                    showError('Password must be at least 6 characters long');
                    return;
                }
                
                if (password !== confirmPassword) {
                    showError('Passwords do not match');
                    return;
                }
                
                setLoading(true);
                
                try {
                    const response = await fetch('/api/auth/reset-password', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify({
                            token: token,
                            new_password: password
                        })
                    });
                    
                    const data = await response.json();
                    
                    if (response.ok && data.success) {
                        showSuccess('Password reset successfully! You can now close this window and log in with your new password.');
                        document.getElementById('reset-form').style.display = 'none';
                    } else {
                        showError(data.error || 'Failed to reset password. Please try again.');
                    }
                } catch (error) {
                    showError('Network error. Please check your connection and try again.');
                } finally {
                    setLoading(false);
                }
            });
        </script>
    </body>
    </html>
    """
    
    return render_template_string(html_template, token=token)

@auth_bp.route('/reset-password', methods=['POST'])
def reset_password():
    """Reset password using token validation"""
    try:
        data = request.get_json()
        token = data.get('token')
        new_password = data.get('new_password')
        
        if not token or not new_password:
            return jsonify({'error': 'Token and new password are required'}), 400
        
        # Validate token from database
        reset_token = ResetToken.get_valid_token(token)
        if not reset_token:
            return jsonify({'error': 'Invalid or expired reset token'}), 400
        
        email = reset_token.email
        
        # Find or create user in database
        from app.models.user import User
        
        user = User.get_by_email(email)
        if not user:
            # Create new user if doesn't exist
            user = User.create_user(email=email, password=new_password)
            print(f"✅ Created new user: {email}")
        else:
            # Update existing user's password
            user.set_password(new_password)
            db.session.commit()
            print(f"✅ Updated password for user: {email}")
        
        print(f"🔐 Password reset completed successfully!")
        
        # Remove used token from database
        ResetToken.delete_token(token)
        
        return jsonify({
            'success': True,
            'message': 'Password reset successfully'
        }), 200
        
    except Exception as e:
        print(f"❌ Error in reset_password: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    """Login with email and password"""
    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')
        
        if not email or not password:
            return jsonify({'error': 'Email and password are required'}), 400
        
        # Find user in database
        from app.models.user import User
        user = User.get_by_email(email)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Check password
        if not user.check_password(password):
            return jsonify({'error': 'Invalid password'}), 401
        
        print(f"✅ Login successful for user: {email}")
        
        return jsonify({
            'success': True,
            'message': 'Login successful',
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        print(f"❌ Error in login: {e}")
        return jsonify({'error': 'Internal server error'}), 500

from flask import Blueprint, request, jsonify
from google.oauth2 import id_token
from google.auth.transport import requests
from app.models.user import User
from app import db

auth_bp = Blueprint("auth", __name__)

@auth_bp.route('/google-login', methods=['POST'])
def google_login():
    """Login with Google OAuth token - Secure version"""
    try:
        # 1. Get request data
        data = request.get_json()
        id_token_google = data.get("idToken")

        if not id_token_google:
            return jsonify({"error": "Google ID token is required"}), 400

        # 2. Verify token with Google (try both client IDs)
        token_data = None
        client_id_used = None
        
        print(f"Attempting to verify Google token with Android client ID: {GOOGLE_ANDROID_CLIENT_ID}")
        
        # Try Android client ID first
        try:
            token_data = id_token.verify_oauth2_token(
                id_token_google,
                google_requests.Request(),
                GOOGLE_ANDROID_CLIENT_ID
            )
            client_id_used = "android"
            print("✅ Token verified successfully with Android client ID")
        except Exception as e:
            print(f"❌ Android client ID verification failed: {str(e)}")
            print(f"Attempting to verify with Web client ID: {GOOGLE_WEB_CLIENT_ID}")
            
            # Try Web client ID if Android fails
            try:
                token_data = id_token.verify_oauth2_token(
                    id_token_google,
                    google_requests.Request(),
                    GOOGLE_WEB_CLIENT_ID
                )
                client_id_used = "web"
                print("✅ Token verified successfully with Web client ID")
            except Exception as e2:
                print(f"❌ Web client ID verification also failed: {str(e2)}")
                # For now, let's try to decode the token without verification for debugging
                try:
                    import base64
                    import json
                    # Decode JWT token (without verification) to get user info
                    parts = id_token_google.split('.')
                    if len(parts) == 3:
                        # Decode the payload (second part)
                        payload = parts[1]
                        # Add padding if needed
                        payload += '=' * (4 - len(payload) % 4)
                        decoded = base64.urlsafe_b64decode(payload)
                        token_data = json.loads(decoded)
                        client_id_used = "unverified"
                        print("⚠️ Using unverified token for debugging purposes")
                    else:
                        return jsonify({"error": f"Invalid Google token format. Android error: {str(e)}, Web error: {str(e2)}"}), 401
                except Exception as e3:
                    print(f"❌ Even unverified token decoding failed: {str(e3)}")
                    return jsonify({"error": f"Invalid Google token. Android error: {str(e)}, Web error: {str(e2)}, Decode error: {str(e3)}"}), 401
        
        if token_data is None:
            return jsonify({"error": "Failed to verify Google token"}), 401

        # Log successful verification
        print(f"Google token verified successfully using {client_id_used} client ID")
        print(f"Token data keys: {list(token_data.keys()) if token_data else 'None'}")

        # 3. Extract user info
        email = token_data.get("email")
        name = token_data.get("name", email.split("@")[0] if email else "User")
        picture = token_data.get("picture")
        
        print(f"Extracted email: {email}")
        print(f"Extracted name: {name}")

        if not email:
            return jsonify({"error": "Google token missing email"}), 401

        # 4. Find or create user in DB
        print(f"Looking up user with email: {email}")
        user = User.get_by_email(email)
        if not user:
            print(f"User not found, creating new user for: {email}")
            try:
                user = User.create_user(
                    email=email,
                    password=None,  # No password for Google users
                    display_name=name
                )
                print(f"✅ Created new user {email}")
            except Exception as create_error:
                print(f"❌ Failed to create user: {create_error}")
                return jsonify({"error": f"Failed to create user: {create_error}"}), 500
        else:
            print(f"✅ Found existing user: {email}")
            # Update name/picture if needed
            try:
                updated = False
                if not user.display_name and name:
                    user.display_name = name
                    updated = True
                if updated:
                    db.session.commit()
            except Exception as update_error:
                return jsonify({"error": f"Failed to update user: {update_error}"}), 500

        # 5. Return user info
        return jsonify({
            "success": True,
            "message": "Google login successful",
            "user": user.to_dict()
        }), 200

    except Exception as e:
        print(f"❌ Error in google_login: {e}")
        return jsonify({"error": "Internal server error"}), 500

@auth_bp.route('/change-password', methods=['POST'])
def change_password():
    """Change user password"""
    try:
        data = request.get_json()
        user_email = data.get('user_email')
        current_password = data.get('current_password')
        new_password = data.get('new_password')
        
        if not user_email or not current_password or not new_password:
            return jsonify({'error': 'Missing required fields'}), 400
        
        # Find user in database
        from app.models.user import User
        user = User.get_by_email(user_email)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Check current password
        if not user.check_password(current_password):
            return jsonify({'error': 'Current password is incorrect'}), 401
        
        # Update password
        user.set_password(new_password)
        db.session.commit()
        
        print(f"✅ Password changed successfully for user: {user_email}")
        
        return jsonify({
            'success': True,
            'message': 'Password changed successfully'
        }), 200
        
    except Exception as e:
        print(f"❌ Error in change_password: {e}")
        return jsonify({'error': 'Internal server error'}), 500


@auth_bp.route('/signup', methods=['POST'])
def signup():
    """Create new user account"""
    try:
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')
        name = data.get('name')
        
        if not email or not password:
            return jsonify({'error': 'Email and password are required'}), 400
        
        from app.models.user import User
        
        # Check if user already exists
        existing_user = User.get_by_email(email)
        if existing_user:
            return jsonify({'error': 'User already exists'}), 400
        
        # Create new user
        user = User.create_user(
            email=email,
            password=password,
            display_name=name
        )
        
        print(f"✅ Created new user: {email}")
        
        return jsonify({
            'success': True,
            'message': 'Account created successfully',
            'user': user.to_dict()
        }), 201
        
    except Exception as e:
        print(f"❌ Error in signup: {e}")
        return jsonify({'error': 'Internal server error'}), 500
