# Feedback Feature Setup Guide

## Overview
The Master Yourself AI app now includes a "Report Issue & Improvement" feature that allows users to submit feedback directly from the app. This feature sends emails to `master.yourself.ai@gmail.com` with the user's feedback.

## Backend Setup

### 1. Email Configuration
To enable email sending, you need to configure Gmail SMTP settings:

1. **Create a Gmail App Password**:
   - Go to your Google Account settings
   - Navigate to Security → 2-Step Verification
   - Create an App Password for "Mail"
   - Use this password instead of your regular Gmail password

2. **Set Environment Variables**:
   Create a `.env` file in the `backend` directory with:
   ```
   FEEDBACK_EMAIL=master.yourself.ai@gmail.com
   FEEDBACK_EMAIL_PASSWORD=your_app_password_here
   ```

### 2. Install Dependencies
The required dependencies are already included in `requirements.txt`:
- `smtplib` (built-in Python library)
- `email.mime.text` and `email.mime.multipart` (built-in Python libraries)

### 3. API Endpoints
The feedback feature adds these endpoints:
- `POST /api/feedback/submit-feedback` - Submit feedback
- `GET /api/feedback/health` - Health check

## Frontend Integration

### 1. Settings Screen
The feedback form is accessible from:
- Settings → Report Issue & Improvement

### 2. Form Features
- **Subject Field**: Brief description of the issue/improvement
- **Description Field**: Detailed explanation (minimum 10 characters)
- **Auto Email**: User's email is automatically included from their account
- **Validation**: Form validates all required fields
- **Loading States**: Shows progress during submission

### 3. User Experience
- Beautiful dialog interface with gradient design
- Form validation with helpful error messages
- Success/error notifications
- Responsive design for all screen sizes

## Email Format

When a user submits feedback, an email is sent to `master.yourself.ai@gmail.com` with:

```
Subject: [GENERAL] User's Subject

New Feedback Submission

Type: General
From: user@example.com
Subject: User's Subject
Date: 2024-01-15 14:30:25

Description:
User's detailed description here...

---
This email was sent from the Master Yourself AI app feedback form.
```

## Security Considerations

1. **Email Authentication**: Uses Gmail's secure SMTP with TLS
2. **App Passwords**: Uses Gmail App Passwords instead of regular passwords
3. **Input Validation**: All user inputs are validated on both frontend and backend
4. **Rate Limiting**: Consider implementing rate limiting for production

## Testing

1. **Backend Testing**:
   ```bash
   cd backend
   source venv/bin/activate
   python -c "
   import requests
   response = requests.post('http://localhost:5000/api/feedback/submit-feedback', 
                          json={'user_email': 'test@example.com', 
                                'subject': 'Test', 
                                'body': 'Test feedback'})
   print(response.json())
   "
   ```

2. **Frontend Testing**:
   - Navigate to Settings in the app
   - Tap "Report Issue & Improvement"
   - Fill out the form and submit
   - Check for success/error messages

## Troubleshooting

### Common Issues:

1. **Email Authentication Failed**:
   - Ensure you're using an App Password, not your regular Gmail password
   - Check that 2-Step Verification is enabled on your Gmail account

2. **Email Not Sending**:
   - Verify the `.env` file has correct email credentials
   - Check that the backend server is running
   - Review server logs for SMTP errors

3. **Frontend Connection Issues**:
   - Ensure the backend server is running on `localhost:5000`
   - Check that the API endpoint is accessible

## Production Deployment

For production deployment:

1. **Use Environment Variables**: Never hardcode email credentials
2. **Implement Rate Limiting**: Prevent spam submissions
3. **Add Logging**: Monitor feedback submissions
4. **Consider Email Service**: For high volume, consider services like SendGrid or AWS SES
5. **Backup Email**: Consider having a backup email address

## Future Enhancements

Potential improvements:
- Feedback categories (Bug, Feature Request, General)
- File attachments
- Feedback status tracking
- Admin dashboard for feedback management
- Email templates for different feedback types

