from datetime import datetime, date
from sqlalchemy import Column, Integer, Boolean, DateTime, Date, ForeignKey
from sqlalchemy.orm import relationship
from app import db

class DailyProblemLogs(db.Model):
    """Daily problem logs model"""
    __tablename__ = 'daily_problem_logs'
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    problem_id = Column(Integer, ForeignKey('problems.id'), nullable=False)
    date = Column(Date, nullable=False)
    faced = Column(Boolean, default=False)
    intensity = Column(Integer, default=0)  # 1, 2, or 3 points
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    problem = relationship('Problems', back_populates='daily_logs')
    
    def to_dict(self):
        """Convert to dictionary for API response"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'problem_id': self.problem_id,
            'date': self.date.isoformat(),
            'faced': self.faced,
            'intensity': self.intensity,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
