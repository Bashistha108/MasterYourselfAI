from flask import Blueprint, request, jsonify
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
from datetime import datetime
from app import db
from app.models import Email

feedback_bp = Blueprint('feedback', __name__)

@feedback_bp.route('/submit-feedback', methods=['POST'])
def submit_feedback():
    """
    Submit feedback (issue report or improvement suggestion) via email
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        # Extract data from request
        user_email = data.get('user_email')
        subject = data.get('subject')
        body = data.get('body')
        feedback_type = data.get('type', 'general')  # 'issue' or 'improvement'
        
        # Validate required fields
        if not user_email or not subject or not body:
            return jsonify({'error': 'Missing required fields'}), 400
        
        # Email configuration
        sender_email = os.getenv('FEEDBACK_EMAIL', 'master.yourself.ai@gmail.com')
        sender_password = os.getenv('FEEDBACK_EMAIL_PASSWORD')
        recipient_email = 'master.yourself.ai@gmail.com'
        
        if not sender_password:
            return jsonify({'error': 'Email configuration not set up'}), 500
        
        # Create email content
        email_subject = f"[{feedback_type.upper()}] {subject}"
        
        email_body = f"""
        New Feedback Submission
        
        Type: {feedback_type.title()}
        From: {user_email}
        Subject: {subject}
        Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
        
        Description:
        {body}
        
        ---
        This email was sent from the Master Yourself AI app feedback form.
        """
        
        # Create message
        msg = MIMEMultipart()
        msg['From'] = sender_email
        msg['To'] = recipient_email
        msg['Subject'] = email_subject
        msg['Reply-To'] = user_email
        msg['Bcc'] = sender_email  # BCC the app so we get a copy of admin replies
        
        # Add body to email
        msg.attach(MIMEText(email_body, 'plain'))
        
        # Send email
        try:
            server = smtplib.SMTP('smtp.gmail.com', 587)
            server.starttls()
            server.login(sender_email, sender_password)
            text = msg.as_string()
            server.sendmail(sender_email, recipient_email, text)
            server.quit()
            
            # Store email in database
            email_record = Email(
                subject=email_subject,
                sender=user_email,
                recipient=recipient_email,
                content=email_body,
                date=datetime.now(),
                email_type='sent',
                is_read=False
            )
            db.session.add(email_record)
            db.session.commit()
            
            print(f"✅ Stored feedback email in database: {email_subject}")
            
            return jsonify({
                'message': 'Feedback submitted successfully',
                'status': 'success'
            }), 200
            
        except smtplib.SMTPAuthenticationError:
            return jsonify({'error': 'Email authentication failed'}), 500
        except smtplib.SMTPException as e:
            return jsonify({'error': f'Email sending failed: {str(e)}'}), 500
            
    except Exception as e:
        return jsonify({'error': f'Server error: {str(e)}'}), 500

@feedback_bp.route('/health', methods=['GET'])
def health_check():
    """
    Health check endpoint for feedback service
    """
    return jsonify({
        'status': 'healthy',
        'service': 'feedback',
        'timestamp': datetime.now().isoformat()
    }), 200

