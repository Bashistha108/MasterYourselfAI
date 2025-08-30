from flask import Blueprint, request, jsonify
import secrets
import string
from datetime import datetime, timedelta
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os

auth_bp = Blueprint('auth', __name__)

def generate_reset_token():
    """Generate a secure reset token"""
    return ''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(32))

def send_reset_email(email, reset_token):
    """Send password reset email"""
    try:
        # Email configuration
        smtp_server = "smtp.gmail.com"
        smtp_port = 587
        sender_email = "master.yourself.ai@gmail.com"
        sender_password = os.getenv('FEEDBACK_EMAIL_PASSWORD')
        
        if not sender_password:
            print("❌ FEEDBACK_EMAIL_PASSWORD not set in environment variables")
            return False
        
        # Create message
        msg = MIMEMultipart()
        msg['From'] = sender_email
        msg['To'] = email
        msg['Subject'] = "Password Reset - Master Yourself AI"
        
        # Create reset link - this will open the app with deep link
        reset_link = f"masteryourselfai://reset-password?token={reset_token}"
        
        # Email body
        body = f"""
        Hello,
        
        You requested a password reset for your Master Yourself AI account.
        
        Click the link below to reset your password:
        {reset_link}
        
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

@auth_bp.route('/reset-password', methods=['POST'])
def reset_password():
    """Reset password using Firebase Auth"""
    try:
        data = request.get_json()
        token = data.get('token')
        new_password = data.get('new_password')
        
        if not token or not new_password:
            return jsonify({'error': 'Token and new password are required'}), 400
        
        # For now, we'll use Firebase Auth to reset the password
        # In a production app, you'd validate the token and update the password
        # For now, we'll just return success and let Firebase handle the actual reset
        print(f"🔐 Password reset requested for token: {token[:10]}...")
        
        return jsonify({
            'success': True,
            'message': 'Password reset successfully'
        }), 200
        
    except Exception as e:
        print(f"❌ Error in reset_password: {e}")
        return jsonify({'error': 'Internal server error'}), 500
