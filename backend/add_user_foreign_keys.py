#!/usr/bin/env python3
"""
Script to add user_id foreign keys to all models for user isolation
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db
from app.models.user import User
from app.models.ai_challenges import AIChallenges
from app.models.problems import Problems
from app.models.weekly_goals import WeeklyGoals
from app.models.long_term_goals import LongTermGoals
from app.models.challenges import Challenges
from app.models.todo_items import TodoItems
from app.models.quick_notes import QuickNotes
from app.models.goal_notes import GoalNotes
from app.models.quick_wins import QuickWins
from app.models.problem_logs import ProblemLogs
from app.models.daily_problem_logs import DailyProblemLogs
from app.models.daily_goal_intensities import DailyGoalIntensities
from app.models.weekly_goal_intensities import WeeklyGoalIntensities
from app.models.goal_ratings import GoalRatings

def add_user_foreign_keys():
    """Add user_id foreign keys to all models"""
    app = create_app()
    
    with app.app_context():
        print("🔧 Adding user_id foreign keys to all models...")
        
        # Create a default user if none exists
        default_user = User.query.first()
        if not default_user:
            print("⚠️ No users found in database. Please create a user first.")
            return
        
        print(f"✅ Using default user: {default_user.email} (ID: {default_user.id})")
        
        # Update AI Challenges
        print("📝 Updating AI Challenges...")
        AIChallenges.query.update({AIChallenges.user_id: default_user.id})
        
        # Update Problems
        print("📝 Updating Problems...")
        Problems.query.update({Problems.user_id: default_user.id})
        
        # Update Weekly Goals
        print("📝 Updating Weekly Goals...")
        WeeklyGoals.query.update({WeeklyGoals.user_id: default_user.id})
        
        # Update Long Term Goals
        print("📝 Updating Long Term Goals...")
        LongTermGoals.query.update({LongTermGoals.user_id: default_user.id})
        
        # Update Challenges
        print("📝 Updating Challenges...")
        Challenges.query.update({Challenges.user_id: default_user.id})
        
        # Update Todo Items
        print("📝 Updating Todo Items...")
        TodoItems.query.update({TodoItems.user_id: default_user.id})
        
        # Update Quick Notes
        print("📝 Updating Quick Notes...")
        QuickNotes.query.update({QuickNotes.user_id: default_user.id})
        
        # Update Goal Notes
        print("📝 Updating Goal Notes...")
        GoalNotes.query.update({GoalNotes.user_id: default_user.id})
        
        # Update Quick Wins
        print("📝 Updating Quick Wins...")
        QuickWins.query.update({QuickWins.user_id: default_user.id})
        
        # Update Problem Logs
        print("📝 Updating Problem Logs...")
        ProblemLogs.query.update({ProblemLogs.user_id: default_user.id})
        
        # Update Daily Problem Logs
        print("📝 Updating Daily Problem Logs...")
        DailyProblemLogs.query.update({DailyProblemLogs.user_id: default_user.id})
        
        # Update Daily Goal Intensities
        print("📝 Updating Daily Goal Intensities...")
        DailyGoalIntensities.query.update({DailyGoalIntensities.user_id: default_user.id})
        
        # Update Weekly Goal Intensities
        print("📝 Updating Weekly Goal Intensities...")
        WeeklyGoalIntensities.query.update({WeeklyGoalIntensities.user_id: default_user.id})
        
        # Update Goal Ratings
        print("📝 Updating Goal Ratings...")
        GoalRatings.query.update({GoalRatings.user_id: default_user.id})
        
        # Commit all changes
        db.session.commit()
        print("✅ Successfully added user_id foreign keys to all models!")
        print(f"📊 All data now belongs to user: {default_user.email}")

if __name__ == "__main__":
    add_user_foreign_keys()
