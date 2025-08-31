from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app import db

class Challenges(db.Model):
    """Challenges for goals (weekly/long-term)"""
    __tablename__ = 'challenges'
    
    id = Column(Integer, primary_key=True)
    goal_id = Column(Integer, nullable=False)  # ID of weekly or long-term goal
    goal_type = Column(String(20), nullable=False)  # 'weekly' or 'long_term'
    description = Column(Text, nullable=False)
    weight = Column(Float, default=1.0)  # Importance weight
    status = Column(String(20), default='active')  # active, completed, failed
    due_date = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships - Using simple foreign key references without back_populates
    # due to polymorphic relationship complexity
    weekly_goal = relationship('WeeklyGoals', 
                             foreign_keys=[goal_id], 
                             primaryjoin="and_(Challenges.goal_id==WeeklyGoals.id, Challenges.goal_type=='weekly')",
                             overlaps="long_term_goal")
    long_term_goal = relationship('LongTermGoals',
                                 foreign_keys=[goal_id],
                                 primaryjoin="and_(Challenges.goal_id==LongTermGoals.id, Challenges.goal_type=='long_term')",
                                 overlaps="weekly_goal")
    
    def to_dict(self):
        """Convert to dictionary for API response"""
        return {
            'id': self.id,
            'goal_id': self.goal_id,
            'goal_type': self.goal_type,
            'description': self.description,
            'weight': self.weight,
            'status': self.status,
            'due_date': self.due_date.isoformat() if self.due_date else None,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
