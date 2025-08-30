from flask import Blueprint, request, jsonify
import os
import imaplib
import email
from email.header import decode_header
from datetime import datetime
import re
from app import db
from app.models import Email as EmailModel

emails_bp = Blueprint('emails', __name__)

@emails_bp.route('/', methods=['GET'])
def get_emails():
    """
    Retrieve emails from database (sent feedback) and user's Gmail (received replies)
    """
    try:
        emails = []
        
        # Get emails from database (admin replies)
        db_emails = EmailModel.query.order_by(EmailModel.date.desc()).limit(50).all()
        
        for db_email in db_emails:
            email_data = {
                'id': f"db_{db_email.id}",
                'subject': db_email.subject,
                'sender': db_email.sender,
                'recipient': db_email.recipient,
                'content': db_email.content,
                'date': db_email.date.isoformat(),
                'isRead': db_email.is_read,
                'type': db_email.email_type
            }
            emails.append(email_data)
        
        print(f"✅ Retrieved {len(emails)} emails from database")
        
        # Get emails from Gmail
        print("📧 Fetching emails from Gmail...")
        
        # Get received emails from app's Gmail account (admin replies)
        email_address = os.getenv('FEEDBACK_EMAIL', 'master.yourself.ai@gmail.com')
        password = os.getenv('FEEDBACK_EMAIL_PASSWORD')
        
        if password:
            try:
                # Connect to Gmail IMAP
                mail = imaplib.IMAP4_SSL('imap.gmail.com')
                mail.login(email_address, password)
                
                # Get emails from INBOX
                mail.select('INBOX')
                status, messages = mail.search(None, 'ALL')
                
                if status == 'OK':
                    inbox_ids = messages[0].split()
                    recent_inbox = inbox_ids[-10:] if len(inbox_ids) > 10 else inbox_ids
                    
                    # Process INBOX emails
                    for email_id in reversed(recent_inbox):
                        try:
                            status, msg_data = mail.fetch(email_id, '(RFC822)')
                            raw_email = msg_data[0][1]
                            email_message = email.message_from_bytes(raw_email)
                            
                            # Extract email data
                            subject = decode_header(email_message.get('subject', 'No Subject'))[0][0]
                            if isinstance(subject, bytes):
                                subject = subject.decode('utf-8', errors='ignore')
                            
                            sender = decode_header(email_message.get('from', 'Unknown'))[0][0]
                            if isinstance(sender, bytes):
                                sender = sender.decode('utf-8', errors='ignore')
                            
                            to_field = decode_header(email_message.get('to', ''))[0][0]
                            if isinstance(to_field, bytes):
                                to_field = to_field.decode('utf-8', errors='ignore')
                            
                            # Check if this is a reply FROM admin TO a user
                            # We want emails where master.yourself.ai@gmail.com is the SENDER (admin replies)
                            is_admin_reply = (
                                'master.yourself.ai@gmail.com' in sender.lower() and
                                'master.yourself.ai@gmail.com' not in to_field.lower()
                            )
                            
                            print(f"📧 INBOX email: '{subject}' from '{sender}' to '{to_field}' - is_admin_reply: {is_admin_reply}")
                            
                            if is_admin_reply:
                                # Extract body
                                body = ""
                                if email_message.is_multipart():
                                    for part in email_message.walk():
                                        if part.get_content_type() == "text/plain":
                                            try:
                                                payload = part.get_payload(decode=True)
                                                if payload:
                                                    body = payload.decode('utf-8', errors='ignore')
                                                    break
                                            except:
                                                body = "Could not decode content"
                                else:
                                    try:
                                        payload = email_message.get_payload(decode=True)
                                        if payload:
                                            body = payload.decode('utf-8', errors='ignore')
                                        else:
                                            body = "No content"
                                    except:
                                        body = "Could not decode content"
                                
                                # Extract date
                                date_str = email_message.get('date', '')
                                try:
                                    if date_str:
                                        date_tuple = email.utils.parsedate_tz(date_str)
                                        if date_tuple:
                                            email_date = datetime.fromtimestamp(email.utils.mktime_tz(date_tuple))
                                        else:
                                            email_date = datetime.now()
                                    else:
                                        email_date = datetime.now()
                                except:
                                    email_date = datetime.now()
                                
                                # Add received email
                                email_data = {
                                    'id': f"gmail_{email_id.decode()}",
                                    'subject': subject,
                                    'sender': sender,
                                    'recipient': to_field,
                                    'content': body.strip()[:1000],
                                    'date': email_date.isoformat(),
                                    'isRead': False,
                                    'type': 'received'
                                }
                                emails.append(email_data)
                                print(f"✅ Added received email: '{subject}' from '{sender}'")
                        
                        except Exception as e:
                            print(f"❌ Error processing Gmail email {email_id}: {e}")
                            continue
                
                # Also get sent emails from SENT folder (user feedback)
                try:
                    mail.select('"[Gmail]/Sent Mail"')
                    status, messages = mail.search(None, 'ALL')
                    
                    if status == 'OK':
                        sent_ids = messages[0].split()
                        recent_sent = sent_ids[-10:] if len(sent_ids) > 10 else sent_ids
                        
                        for email_id in reversed(recent_sent):
                            try:
                                status, msg_data = mail.fetch(email_id, '(RFC822)')
                                raw_email = msg_data[0][1]
                                email_message = email.message_from_bytes(raw_email)
                                
                                # Extract email data
                                subject = decode_header(email_message.get('subject', 'No Subject'))[0][0]
                                if isinstance(subject, bytes):
                                    subject = subject.decode('utf-8', errors='ignore')
                                
                                sender = decode_header(email_message.get('from', 'Unknown'))[0][0]
                                if isinstance(sender, bytes):
                                    sender = sender.decode('utf-8', errors='ignore')
                                
                                to_field = decode_header(email_message.get('to', ''))[0][0]
                                if isinstance(to_field, bytes):
                                    to_field = to_field.decode('utf-8', errors='ignore')
                                
                                # Check if this is feedback sent TO master.yourself.ai@gmail.com
                                is_feedback_sent = (
                                    'master.yourself.ai@gmail.com' in to_field.lower() and
                                    ('feedback' in subject.lower() or 'issue' in subject.lower() or 'improvement' in subject.lower() or 'report' in subject.lower())
                                )
                                
                                # Check if this is admin reply FROM master.yourself.ai@gmail.com TO users
                                is_admin_reply = (
                                    'master.yourself.ai@gmail.com' in sender.lower() and 
                                    ('re:' in subject.lower() or 'reply' in subject.lower())
                                )
                                
                                print(f"📧 SENT email: '{subject}' from '{sender}' to '{to_field}' - is_feedback_sent: {is_feedback_sent}, is_admin_reply: {is_admin_reply}")
                                print(f"   Sender contains master.yourself.ai: {'master.yourself.ai@gmail.com' in sender.lower()}")
                                print(f"   Subject contains re: {'re:' in subject.lower()}")
                                print(f"   Subject contains reply: {'reply' in subject.lower()}")
                                
                                if is_feedback_sent:
                                    # Extract body
                                    body = ""
                                    if email_message.is_multipart():
                                        for part in email_message.walk():
                                            if part.get_content_type() == "text/plain":
                                                try:
                                                    payload = part.get_payload(decode=True)
                                                    if payload:
                                                        body = payload.decode('utf-8', errors='ignore')
                                                        break
                                                except:
                                                    body = "Could not decode content"
                                    else:
                                        try:
                                            payload = email_message.get_payload(decode=True)
                                            if payload:
                                                body = payload.decode('utf-8', errors='ignore')
                                            else:
                                                body = "No content"
                                        except:
                                            body = "Could not decode content"
                                    
                                    # Extract date
                                    date_str = email_message.get('date', '')
                                    try:
                                        if date_str:
                                            date_tuple = email.utils.parsedate_tz(date_str)
                                            if date_tuple:
                                                email_date = datetime.fromtimestamp(email.utils.mktime_tz(date_tuple))
                                            else:
                                                email_date = datetime.now()
                                        else:
                                            email_date = datetime.now()
                                    except:
                                        email_date = datetime.now()
                                    
                                    # Add sent email
                                    email_data = {
                                        'id': f"sent_{email_id.decode()}",
                                        'subject': subject,
                                        'sender': sender,
                                        'recipient': to_field,
                                        'content': body.strip()[:1000],
                                        'date': email_date.isoformat(),
                                        'isRead': False,
                                        'type': 'sent'
                                    }
                                    emails.append(email_data)
                                    print(f"✅ Added sent email: '{subject}' to '{to_field}'")
                                
                                elif is_admin_reply:
                                    # Add admin reply as received email
                                    email_data = {
                                        'id': f"sent_{email_id.decode()}",
                                        'subject': subject,
                                        'sender': sender,
                                        'recipient': to_field,
                                        'content': body.strip()[:1000],
                                        'date': email_date.isoformat(),
                                        'isRead': False,
                                        'type': 'received'
                                    }
                                    emails.append(email_data)
                                    print(f"✅ Added admin reply as received: '{subject}' from '{sender}'")
                            
                            except Exception as e:
                                print(f"❌ Error processing sent email {email_id}: {e}")
                                continue
                
                except Exception as e:
                    print(f"❌ Error accessing SENT folder: {e}")
                
                mail.close()
                mail.logout()
                
            except Exception as e:
                print(f"❌ Error accessing Gmail: {e}")
        else:
            print("⚠️ No Gmail password configured for fetching emails")
        
        # Sort all emails by date
        emails.sort(key=lambda x: x['date'], reverse=True)
        
        print(f"✅ Total emails: {len(emails)} (sent: {len([e for e in emails if e['type'] == 'sent'] or 'received')}, received: {len([e for e in emails if e['type'] == 'received'])})")
        
        return jsonify({
            'success': True,
            'data': emails
        }), 200
        
    except Exception as e:
        print(f"Error in get_emails: {e}")
        return jsonify({'error': f'Server error: {str(e)}'}), 500

@emails_bp.route('/delete/<email_id>', methods=['DELETE'])
def delete_email(email_id):
    """
    Delete an email from Gmail
    """
    try:
        # Email configuration
        email_address = os.getenv('FEEDBACK_EMAIL', 'master.yourself.ai@gmail.com')
        password = os.getenv('FEEDBACK_EMAIL_PASSWORD')
        
        if not password:
            return jsonify({'error': 'Email configuration not set up'}), 500
        
        # Connect to Gmail IMAP
        mail = imaplib.IMAP4_SSL('imap.gmail.com')
        mail.login(email_address, password)
        
        # Parse email ID to get folder and message ID
        if email_id.startswith('db_'):
            # Delete from database
            db_id = email_id.replace('db_', '')
            email_record = EmailModel.query.get(db_id)
            
            if not email_record:
                return jsonify({'error': 'Email not found in database'}), 404
            
            db.session.delete(email_record)
            db.session.commit()
            
            print(f"✅ Successfully deleted email {email_id} from database")
            
            return jsonify({
                'success': True,
                'message': 'Email deleted successfully'
            }), 200
            
        elif email_id.startswith('inbox_'):
            folder = 'INBOX'
            msg_id = email_id.replace('inbox_', '')
        elif email_id.startswith('sent_'):
            folder = '"[Gmail]/Sent Mail"'
            msg_id = email_id.replace('sent_', '')
        else:
            # Try to find in database by ID
            email_record = EmailModel.query.get(email_id)
            if email_record:
                db.session.delete(email_record)
                db.session.commit()
                print(f"✅ Successfully deleted email {email_id} from database")
                return jsonify({
                    'success': True,
                    'message': 'Email deleted successfully'
                }), 200
            else:
                return jsonify({'error': 'Invalid email ID format'}), 400
        
        try:
            # Select the appropriate folder
            print(f"🔍 Selecting folder: {folder}")
            status, messages = mail.select(folder)
            print(f"📁 Folder selection status: {status}")
            
            if status != 'OK':
                return jsonify({'error': f'Failed to select folder: {status}'}), 500
            
            # Delete the email
            print(f"🗑️ Marking email {msg_id} for deletion...")
            status, response = mail.store(msg_id, '+FLAGS', '\\Deleted')
            print(f"📝 Store status: {status}, Response: {response}")
            
            if status != 'OK':
                return jsonify({'error': f'Failed to mark email for deletion: {status}'}), 500
            
            # Expunge to permanently delete
            print(f"🗑️ Permanently deleting email...")
            status, response = mail.expunge()
            print(f"🗑️ Expunge status: {status}, Response: {response}")
            
            if status != 'OK':
                return jsonify({'error': f'Failed to permanently delete email: {status}'}), 500
            
            print(f"✅ Successfully deleted email {email_id} from {folder}")
            
            return jsonify({
                'success': True,
                'message': 'Email deleted successfully'
            }), 200
            
        except Exception as e:
            print(f"❌ Error deleting email {email_id}: {e}")
            return jsonify({'error': f'Failed to delete email: {str(e)}'}), 500
        
        finally:
            mail.close()
            mail.logout()
        
    except Exception as e:
        print(f"Error in delete_email: {e}")
        return jsonify({'error': f'Server error: {str(e)}'}), 500

@emails_bp.route('/add-admin-reply', methods=['POST'])
def add_admin_reply():
    """
    Manually add an admin reply to the database
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        # Extract data from request
        subject = data.get('subject')
        user_email = data.get('user_email')
        content = data.get('content')
        
        # Validate required fields
        if not subject or not user_email or not content:
            return jsonify({'error': 'Missing required fields: subject, user_email, content'}), 400
        
        # Create email record for admin reply
        email_record = EmailModel(
            subject=subject,
            sender='master.yourself.ai@gmail.com',
            recipient=user_email,
            content=content,
            date=datetime.now(),
            email_type='received',
            is_read=False
        )
        
        db.session.add(email_record)
        db.session.commit()
        
        print(f"✅ Added admin reply: '{subject}' to '{user_email}'")
        
        return jsonify({
            'success': True,
            'message': 'Admin reply added successfully',
            'email_id': email_record.id
        }), 200
        
    except Exception as e:
        print(f"Error in add_admin_reply: {e}")
        db.session.rollback()
        return jsonify({'error': f'Server error: {str(e)}'}), 500

@emails_bp.route('/health', methods=['GET'])
def health_check():
    """
    Health check endpoint for emails service
    """
    return jsonify({
        'status': 'healthy',
        'service': 'emails',
        'timestamp': datetime.now().isoformat()
    }), 200
