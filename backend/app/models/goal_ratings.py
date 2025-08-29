from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app import db

class GoalRatings(db.Model):
    """Weekly goal ratings tracking"""
    __tablename__ = 'goal_ratings'
    
    id = Column(Integer, primary_key=True)
    goal_id = Column(Integer, nullable=False)  # ID of weekly or long-term goal (not FK due to polymorphic relationship)
    goal_type = Column(String(20), nullable=False)  # 'weekly' or 'long_term'
    week = Column(String(10), nullable=False)  # Format: YYYY-WW (e.g., 2024-01)
    rating = Column(Integer, nullable=False)  # 0-10 rating
    notes = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships - Using simple foreign key references without back_populates
    # due to polymorphic relationship complexity
    weekly_goal = relationship('WeeklyGoals',
                             foreign_keys=[goal_id],
                             primaryjoin="and_(GoalRatings.goal_id==WeeklyGoals.id, GoalRatings.goal_type=='weekly')")
    long_term_goal = relationship('LongTermGoals',
                                 foreign_keys=[goal_id],
                                 primaryjoin="and_(GoalRatings.goal_id==LongTermGoals.id, GoalRatings.goal_type=='long_term')")
    
    def to_dict(self):
        """Convert to dictionary for API response"""
        return {
            'id': self.id,
            'goal_id': self.goal_id,
            'goal_type': self.goal_type,
            'week': self.week,
            'rating': self.rating,
            'notes': self.notes,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
    
    @classmethod
    def get_week_rating(cls, goal_id, goal_type, week):
        """Get rating for a specific goal and week"""
        return cls.query.filter_by(
            goal_id=goal_id,
            goal_type=goal_type,
            week=week
        ).first()
