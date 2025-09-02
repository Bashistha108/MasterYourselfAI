# Master Yourself AI

A cross-platform mobile app for personal development with AI-powered challenges and goal tracking.

## Project Overview

**Master Yourself AI** helps users track weekly goals, long-term objectives, and personal problems while providing AI-generated daily challenges based on problem intensity analysis.

### Key Features
- **Weekly Goals**: Track and rate weekly objectives (0-10 scale)
- **Long Term Goals**: Manage long-term aspirations with challenges
- **Problem Tracking**: Daily problem logging with intensity analysis
- **AI Challenges**: Daily personalized challenges based on problem trends
- **Progress Visualization**: Interactive graphs and progress tracking
- **Gamification**: Streaks, points, and achievement system

##  Architecture

- **Frontend**: Flutter (Cross-platform mobile app)
- **Backend**: Flask (Python REST API)
- **Database**: PostgreSQL/MySQL
- **AI Logic**: Custom problem intensity calculation and challenge generation

## Project Structure

```
master_yourself_ai/
├── backend/                 # Flask API
│   ├── app/
│   │   ├── models/         # Database models
│   │   ├── routes/         # API endpoints
│   │   ├── services/       # AI logic & business logic
│   │   ├── utils/          # Helper functions
│   │   └── config/         # Configuration
│   ├── venv/               # Python virtual environment
│   ├── requirements.txt
│   ├── config.py
│   └── run.py
├── frontend/               # Flutter app
│   ├── lib/
│   │   ├── models/         # Data models
│   │   ├── screens/        # UI screens
│   │   ├── widgets/        # Reusable components
│   │   ├── services/       # API integration
│   │   ├── providers/      # State management
│   │   └── utils/          # Helper functions
│   ├── assets/
│   └── pubspec.yaml
└── README.md
```

## Development Setup

### Prerequisites
- Python 3.8+
- Flutter SDK
- PostgreSQL/MySQL
- Git

### Backend Setup
```bash
cd backend
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run
```

## Database Schema

### Core Tables
- **WeeklyGoals**: Weekly objectives with ratings
- **LongTermGoals**: Long-term aspirations
- **Problems**: Personal problems/focus areas
- **ProblemLogs**: Daily problem tracking
- **AIChallenges**: Generated daily challenges
- **GoalRatings**: Weekly goal progress
- **QuickWins**: Micro-achievements

## UI Design Philosophy

Based on the wireframes, the app features:
- **Clean, minimal design** with clear sections
- **Progress bars** with red/green indicators
- **Simple navigation** with 2x2 grid layout
- **Interactive graphs** with multiple colored lines
- **Checkbox-based** problem tracking
- **Visual progress** indicators throughout

## Development Workflow

1. **Parallel Development**: Backend and frontend developed simultaneously
2. **Mock Data First**: Frontend uses mock data initially
3. **API Integration**: Connect frontend to backend APIs
4. **Testing**: Comprehensive testing at each stage
5. **Deployment**: Production-ready deployment

## Screens

1. **Dashboard**: Overview with navigation grid
2. **Tiny Steps**: Weekly goals management
3. **Build Your Goal**: Long-term goals and challenges
4. **My Problems**: Daily problem tracking
5. **AI Challenge**: Daily challenge interface
6. **Graphs**: Progress visualization
7. **Summary**: Weekly/monthly reports

## AI Features

- **Problem Intensity Calculation**: Dynamic weight-based analysis
- **Challenge Generation**: Daily personalized challenges
- **Predictive Analytics**: Weekly risk assessment
- **Adaptive Difficulty**: Adjusts based on user consistency
- **Trend Analysis**: Problem pattern recognition

## Next Steps

1. Set up project structure and dependencies
2. Set up database models and migrations
3. Implement basic CRUD API endpoints
4. Create Flutter screens with mock data
5. Develop AI logic and challenge generation
6. Add graph visualization
7. Integrate frontend with backend
8. Add notifications and gamification
9. Testing and optimization

## 🛠️ Current Status

- **Project Structure**: Complete
- **Backend Dependencies**: Installed (Flask, SQLAlchemy, etc.)
- **Frontend Dependencies**: Installed (Flutter, Provider, fl_chart, etc.)
- **Virtual Environment**: Set up
- **Database Setup**: In progress
- **API Development**: Pending
- **UI Development**: Pending

---

**Note**: This project follows a step-by-step development approach with clean, testable code and professional UI design.
