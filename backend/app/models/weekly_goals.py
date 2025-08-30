from datetime import datetime, timedelta
from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey, CheckConstraint, Boolean, func
from sqlalchemy.orm import relationship
from app import db

class WeeklyGoals(db.Model):
    """Weekly goals model - max 3 per week"""
    __tablename__ = 'weekly_goals'
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    week_start_date = Column(DateTime, nullable=False, default=datetime.utcnow)
    week_end_date = Column(DateTime, nullable=False)
    rating = Column(Integer, CheckConstraint('rating >= 0 AND rating <= 10'), default=0)
    completed = Column(Boolean, default=False)
    archived = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship('User', backref='weekly_goals')
    
    # Relationships
    # Note: relationships removed due to polymorphic relationship complexity
    # Use direct queries instead of relationships for challenges and goal_ratings
    
    def __init__(self, user_id, title, description=None, week_start=None):
        self.user_id = user_id
        self.title = title
        self.description = description
        if week_start is None:
            # Calculate the start of the current week (Monday)
            now = datetime.utcnow()
            week_start = now - timedelta(days=now.weekday())
            # Set time to start of day for consistent comparison
            week_start = week_start.replace(hour=0, minute=0, second=0, microsecond=0)
        self.week_start_date = week_start
        self.week_end_date = week_start + timedelta(days=7)
    
    def to_dict(self):
        """Convert to dictionary for API response"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'title': self.title,
            'description': self.description,
            'week_start_date': self.week_start_date.isoformat(),
            'week_end_date': self.week_end_date.isoformat(),
            'rating': self.rating,
            'completed': self.completed,
            'archived': self.archived,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
    
    @classmethod
    def get_current_week_goals(cls, user_id):
        """Get goals for the current week (excluding archived)"""
        now = datetime.utcnow()
        # Calculate start of current week (Monday)
        start_of_week = now - timedelta(days=now.weekday())
        # Set time to start of day for consistent comparison
        start_of_week = start_of_week.replace(hour=0, minute=0, second=0, microsecond=0)
        end_of_week = start_of_week + timedelta(days=7)
        
        return cls.query.filter(
            cls.user_id == user_id,
            cls.week_start_date >= start_of_week,
            cls.week_start_date < end_of_week,
            cls.archived == False
        ).all()
    
    @classmethod
    def get_all_goals(cls, user_id):
        """Get all weekly goals (current and past weeks, excluding archived)"""
        return cls.query.filter(cls.user_id == user_id, cls.archived == False).order_by(cls.week_start_date.desc()).all()
    
    @classmethod
    def get_completed_goals(cls, user_id):
        """Get all completed weekly goals (excluding archived)"""
        return cls.query.filter(cls.user_id == user_id, cls.completed == True, cls.archived == False).order_by(cls.week_start_date.desc()).all()
    
    @classmethod
    def get_archived_goals(cls, user_id):
        """Get all archived weekly goals"""
        return cls.query.filter(cls.user_id == user_id, cls.archived == True).order_by(cls.week_start_date.desc()).all()
    
    @classmethod
    def can_add_goal(cls, user_id):
        """Check if we can add another goal (max 3 active per week)"""
        current_goals = cls.get_current_week_goals(user_id)
        active_goals = [goal for goal in current_goals if not goal.completed]
        return len(active_goals) < 3
    
    def calculate_average_rating(self):
        """Calculate average rating from goal_ratings table"""
        from app.models.goal_ratings import GoalRatings
        
        # Get all ratings for this goal
        ratings = GoalRatings.query.filter_by(
            goal_id=self.id,
            goal_type='weekly'
        ).all()
        
        if not ratings:
            return 0
        
        total_rating = sum(rating.rating for rating in ratings)
        return total_rating / len(ratings)
    
    def calculate_average_intensity(self):
        """Calculate average intensity from daily_goal_intensities table for the current week"""
        from app.models.daily_goal_intensities import DailyGoalIntensities
        
        # Get all daily intensities for this goal in the current week
        daily_intensities = DailyGoalIntensities.get_by_goal_and_week(self.id, self.week_start_date.date())
        
        if not daily_intensities:
            return 0
        
        total_intensity = sum(intensity.intensity for intensity in daily_intensities)
        return total_intensity / len(daily_intensities)
    
    def check_and_update_completion_status(self):
        """Check average rating and average intensity, automatically mark as completed if both >= 7"""
        average_rating = self.calculate_average_rating()
        average_intensity = self.calculate_average_intensity()
        
        # Only mark as completed if both average rating and average intensity >= 7
        if average_rating >= 7 and average_intensity >= 7 and not self.completed:
            self.completed = True
            self.updated_at = datetime.utcnow()
            db.session.commit()
            return True
        elif (average_rating < 7 or average_intensity < 7) and self.completed:
            # If either rating or intensity drops below 7, unmark as completed
            self.completed = False
            self.updated_at = datetime.utcnow()
            db.session.commit()
            return True
        
        return False
