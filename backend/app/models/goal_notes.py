from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app import db

class GoalNotes(db.Model):
    """Goal notes model for long-term goals"""
    __tablename__ = 'goal_notes'
    
    id = Column(Integer, primary_key=True)
    goal_id = Column(Integer, ForeignKey('long_term_goals.id'), nullable=False)
    title = Column(String(255), nullable=False)
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship
    goal = relationship('LongTermGoals', back_populates='notes')
    
    def to_dict(self):
        """Convert to dictionary for API response"""
        return {
            'id': self.id,
            'goal_id': self.goal_id,
            'title': self.title,
            'content': self.content,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
