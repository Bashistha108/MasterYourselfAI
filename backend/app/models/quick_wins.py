from datetime import datetime, date
from sqlalchemy import Column, Integer, String, Text, Boolean, Date, DateTime, ForeignKey
from app import db

class QuickWins(db.Model):
    """Quick wins for micro-achievements"""
    __tablename__ = 'quick_wins'
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    date = Column(Date, nullable=False, default=date.today)
    completed = Column(Boolean, default=False)
    points = Column(Integer, default=5)  # Points awarded for completion
    category = Column(String(100), nullable=True)  # e.g., 'productivity', 'health', 'social'
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        """Convert to dictionary for API response"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'title': self.title,
            'description': self.description,
            'date': self.date.isoformat(),
            'completed': self.completed,
            'points': self.points,
            'category': self.category,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
    
    @classmethod
    def get_today_wins(cls):
        """Get quick wins for today"""
        today = date.today()
        return cls.query.filter_by(date=today).all()
