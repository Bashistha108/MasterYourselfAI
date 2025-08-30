# Render Deployment Guide

## 🚀 Deploy Master Yourself AI to Render with PostgreSQL

### Step 1: Create PostgreSQL Database on Render

1. **Go to Render Dashboard**
   - Visit [render.com](https://render.com)
   - Sign up/Login

2. **Create PostgreSQL Database**
   - Click "New" → "PostgreSQL"
   - Name: `master-yourself-ai-db`
   - Region: Choose closest to you
   - PostgreSQL Version: 15 (latest)
   - Click "Create Database"

3. **Get Database URL**
   - Copy the "External Database URL"
   - It looks like: `postgresql://user:pass@host:port/database`

### Step 2: Create Web Service

1. **Connect GitHub Repository**
   - Click "New" → "Web Service"
   - Connect your GitHub repo
   - Select the repository

2. **Configure Web Service**
   - **Name**: `master-yourself-ai-backend`
   - **Environment**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn run:app --bind 0.0.0.0:$PORT`

3. **Environment Variables**
   Add these environment variables:
   ```
   DATABASE_URL=your_postgresql_url_from_step_1
   SECRET_KEY=your_secret_key_here
   GEMINI_API_KEY=your_gemini_api_key
   FEEDBACK_EMAIL_ADDRESS=your_email@gmail.com
   FEEDBACK_EMAIL_PASSWORD=your_app_password
   ```

### Step 3: Deploy Flutter Web

1. **Build Flutter Web**
   ```bash
   cd frontend
   flutter build web
   ```

2. **Create Static Site**
   - Click "New" → "Static Site"
   - Connect to your GitHub repo
   - **Build Command**: `cd frontend && flutter build web`
   - **Publish Directory**: `frontend/build/web`

### Step 4: Database Migration

1. **Run Migration Locally** (Optional)
   ```bash
   cd backend
   source venv/bin/activate
   python migrate_to_postgres.py
   ```

2. **Or Let Render Handle It**
   - Render will automatically run migrations when deployed
   - The app will create tables on first run

### Step 5: Update Frontend API URL

Update your Flutter app to use the Render backend URL:

```dart
// In frontend/lib/services/api_service.dart
class ApiService {
  static const String baseUrl = 'https://your-render-app.onrender.com';
  // ... rest of the code
}
```

### Step 6: Test Deployment

1. **Test Backend API**
   - Visit: `https://your-render-app.onrender.com/api/health`
   - Should return: `{"status": "healthy"}`

2. **Test Password Reset**
   - Try the password reset flow
   - Check if emails are sent

3. **Test Login**
   - Try logging in with your credentials

## 🔧 Troubleshooting

### Common Issues:

1. **Database Connection Error**
   - Check `DATABASE_URL` environment variable
   - Ensure PostgreSQL database is running

2. **Build Failures**
   - Check `requirements.txt` has all dependencies
   - Ensure `psycopg2-binary` is included

3. **CORS Issues**
   - Update CORS settings in Flask app
   - Add your frontend domain to allowed origins

4. **Email Not Working**
   - Check email credentials in environment variables
   - Test email configuration locally first

### Environment Variables Reference:

```bash
# Database (Render sets this automatically)
DATABASE_URL=postgresql://user:pass@host:port/database

# Flask
SECRET_KEY=your_secret_key_here

# Gemini AI
GEMINI_API_KEY=your_gemini_api_key

# Email (Gmail)
FEEDBACK_EMAIL_ADDRESS=your_email@gmail.com
FEEDBACK_EMAIL_PASSWORD=your_app_password
```

## 📊 Monitoring

- **Logs**: Check Render dashboard for application logs
- **Database**: Monitor PostgreSQL usage in Render dashboard
- **Performance**: Use Render's built-in monitoring

## 🔄 Updates

To update your deployment:
1. Push changes to GitHub
2. Render automatically redeploys
3. Check logs for any issues

## 💰 Costs

- **PostgreSQL**: Free tier available (limited storage)
- **Web Service**: Free tier available (sleeps after inactivity)
- **Static Site**: Free tier available

## 🎉 Success!

Your Master Yourself AI app is now deployed on Render with PostgreSQL! 🚀
