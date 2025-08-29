from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime, CheckConstraint, Boolean
from sqlalchemy.orm import relationship
from app import db

class LongTermGoals(db.Model):
    """Long term goals model - max 3 total"""
    __tablename__ = 'long_term_goals'
    
    id = Column(Integer, primary_key=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    start_date = Column(DateTime, nullable=True)
    target_date = Column(DateTime, nullable=True)
    status = Column(String(50), default='active')  # active, completed, paused
    archived = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    # Note: relationships removed due to polymorphic relationship complexity
    # Use direct queries instead of relationships for challenges and goal_ratings
    notes = relationship('GoalNotes', back_populates='goal', cascade='all, delete-orphan')
    
    def to_dict(self):
        """Convert to dictionary for API response"""
        return {
            'id': self.id,
            'title': self.title,
            'description': self.description,
            'start_date': self.start_date.strftime('%Y-%m-%d') if self.start_date else None,
            'target_date': self.target_date.strftime('%Y-%m-%d') if self.target_date else None,
            'status': self.status,
            'archived': self.archived,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
    
    @classmethod
    def can_add_goal(cls):
        """Check if we can add another goal (max 3 total)"""
        active_goals = cls.query.filter_by(status='active', archived=False).count()
        return active_goals < 3
    
    @classmethod
    def get_active_goals(cls):
        """Get all active long-term goals (excluding archived)"""
        return cls.query.filter_by(status='active', archived=False).order_by(cls.created_at.desc()).all()
    
    @classmethod
    def get_completed_goals(cls):
        """Get all completed long-term goals (excluding archived)"""
        return cls.query.filter_by(status='completed', archived=False).order_by(cls.created_at.desc()).all()
    
    @classmethod
    def get_archived_goals(cls):
        """Get all archived long-term goals"""
        return cls.query.filter_by(archived=True).order_by(cls.created_at.desc()).all()
