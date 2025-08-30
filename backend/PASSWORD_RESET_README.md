# Password Reset System

This document explains the password reset functionality implemented for the Master Yourself AI application.

## Overview

The password reset system provides users with two ways to reset their password:
1. **App Deep Link**: Opens the Flutter app directly
2. **Web Page**: A beautiful, responsive web page for password reset

## How It Works

### 1. User Requests Password Reset
- User clicks "Forgot Password" in the login screen
- System generates a secure, random token
- Token is stored with expiration (1 hour)
- Email is sent with both app and web links

### 2. Email Content
The email contains:
- App deep link: `masteryourselfai://reset-password?token=...`
- Web link: `https://masteryourselfai.com/reset-password-page?token=...`
- Clear instructions and security notice

### 3. Password Reset Options

#### Option A: App Deep Link
- User clicks app link in email
- Opens Flutter app directly
- Navigates to password reset screen
- User enters new password in app

#### Option B: Web Page
- User clicks web link in email
- Opens beautiful, responsive web page
- User enters new password on web
- System validates token and updates password

## Files Created/Modified

### Backend Files
- `backend/app/routes/auth.py` - Main password reset logic
- `backend/test_password_reset.py` - Test script
- `backend/password_reset_demo.html` - Demo web page
- `backend/PASSWORD_RESET_README.md` - This documentation

### Frontend Files (Already Existed)
- `frontend/lib/screens/password_reset_screen.dart` - App reset screen
- `frontend/lib/main.dart` - Deep link handling
- `frontend/lib/services/firebase_auth_service.dart` - Firebase integration

## API Endpoints

### Send Password Reset Email
```
POST /auth/send-password-reset
Content-Type: application/json

{
  "email": "user@example.com"
}
```

### Reset Password Page
```
GET /reset-password-page?token=<reset_token>
```
Returns a beautiful HTML page for password reset.

### Reset Password
```
POST /auth/reset-password
Content-Type: application/json

{
  "token": "<reset_token>",
  "new_password": "newPassword123"
}
```

## Security Features

1. **Secure Token Generation**: Uses `secrets` module for cryptographically secure tokens
2. **Token Expiration**: Tokens expire after 1 hour
3. **Single Use**: Tokens are deleted after successful password reset
4. **Input Validation**: Password must be at least 6 characters
5. **CSRF Protection**: Tokens prevent unauthorized password changes

## Testing

### Run the Test Script
```bash
cd backend
source venv/bin/activate
python test_password_reset.py
```

### View the Demo Web Page
```bash
# Open in browser
open backend/password_reset_demo.html
```

### Test with Real Server
```bash
# Start the backend server
cd backend
source venv/bin/activate
python run.py

# In another terminal, test the endpoints
curl -X POST http://localhost:5000/auth/send-password-reset \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'
```

## Production Considerations

### 1. Firebase Integration
Currently, the system validates tokens but doesn't actually update Firebase passwords. For production:

```python
# Add Firebase Admin SDK integration
import firebase_admin
from firebase_admin import auth

# In reset_password function:
user = auth.get_user_by_email(email)
auth.update_user(user.uid, password=new_password)
```

### 2. Email Configuration
Ensure these environment variables are set:
```bash
FEEDBACK_EMAIL_ADDRESS=your-email@gmail.com
FEEDBACK_EMAIL_PASSWORD=your-app-password
```

### 3. Domain Configuration
Update the web reset link URL in `auth.py`:
```python
web_reset_link = f"https://yourdomain.com/reset-password-page?token={reset_token}"
```

### 4. Token Storage
For production, use Redis or database instead of in-memory storage:
```python
# Use Redis
import redis
r = redis.Redis(host='localhost', port=6379, db=0)
r.setex(f"reset_token:{token}", 3600, email)  # 1 hour expiration
```

## User Experience

### Email Flow
1. User requests password reset
2. Receives email with two options
3. Can choose app or web method
4. Both methods provide same security level

### Web Page Features
- Beautiful, modern design
- Responsive layout
- Password visibility toggle
- Real-time validation
- Loading states
- Success/error messages
- Mobile-friendly

### App Integration
- Seamless deep linking
- Consistent UI with app
- Same validation rules
- Firebase integration

## Troubleshooting

### Common Issues

1. **Email not sending**
   - Check SMTP credentials
   - Verify email configuration

2. **Token not working**
   - Check token expiration
   - Verify token storage

3. **Web page not loading**
   - Check server is running
   - Verify route registration

4. **App deep link not working**
   - Check URL scheme configuration
   - Verify deep link handling

### Debug Commands
```bash
# Check server logs
tail -f backend/server.log

# Test email sending
python -c "from app.routes.auth import send_reset_email; send_reset_email('test@example.com', 'test_token')"

# Check token storage
python -c "from app.routes.auth import reset_tokens; print(reset_tokens)"
```

## Future Enhancements

1. **Rate Limiting**: Prevent abuse of reset requests
2. **Audit Logging**: Track password reset attempts
3. **Multi-language Support**: Internationalize email and web page
4. **SMS Reset**: Add SMS-based password reset option
5. **Security Questions**: Add additional verification steps
