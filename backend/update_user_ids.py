#!/usr/bin/env python3
"""
Script to update user_id fields for existing data
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app, db
from app.models.user import User
from app.models.ai_challenges import AIChallenges
from app.models.problems import Problems
from app.models.todo_items import TodoItems
from app.models.challenges import Challenges

def update_user_ids():
    """Update user_id fields for existing data"""
    app = create_app()
    
    with app.app_context():
        print("🔧 Updating user_id fields for existing data...")
        
        # Get the first user
        default_user = User.query.first()
        if not default_user:
            print("⚠️ No users found in database. Please create a user first.")
            return
        
        print(f"✅ Using default user: {default_user.email} (ID: {default_user.id})")
        
        # Update AI Challenges
        print("📝 Updating AI Challenges...")
        try:
            AIChallenges.query.update({AIChallenges.user_id: default_user.id})
            print(f"✅ Updated {AIChallenges.query.count()} AI challenges")
        except Exception as e:
            print(f"❌ Error updating AI challenges: {e}")
        
        # Update Problems
        print("📝 Updating Problems...")
        try:
            Problems.query.update({Problems.user_id: default_user.id})
            print(f"✅ Updated {Problems.query.count()} problems")
        except Exception as e:
            print(f"❌ Error updating problems: {e}")
        
        # Update Todo Items
        print("📝 Updating Todo Items...")
        try:
            TodoItems.query.update({TodoItems.user_id: default_user.id})
            print(f"✅ Updated {TodoItems.query.count()} todo items")
        except Exception as e:
            print(f"❌ Error updating todo items: {e}")
        
        # Update Challenges
        print("📝 Updating Challenges...")
        try:
            Challenges.query.update({Challenges.user_id: default_user.id})
            print(f"✅ Updated {Challenges.query.count()} challenges")
        except Exception as e:
            print(f"❌ Error updating challenges: {e}")
        
        # Commit all changes
        db.session.commit()
        print("✅ Successfully updated user_id fields!")

if __name__ == "__main__":
    update_user_ids()
