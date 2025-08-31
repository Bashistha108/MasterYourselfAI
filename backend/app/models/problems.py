from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app import db

class Problems(db.Model):
    """Problems/Focus areas model"""
    __tablename__ = 'problems'
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    weight = Column(Float, default=1.0)  # Base weight for intensity calculation
    category = Column(String(100), nullable=True)  # e.g., 'productivity', 'health', 'social'
    status = Column(String(50), default='active')  # active, inactive, resolved
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    problem_logs = relationship('ProblemLogs', back_populates='problem', cascade='all, delete-orphan')
    daily_logs = relationship('DailyProblemLogs', back_populates='problem', cascade='all, delete-orphan')
    
    def to_dict(self):
        """Convert to dictionary for API response"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'name': self.name,
            'description': self.description,
            'weight': self.weight,
            'category': self.category,
            'status': self.status,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
    
    def calculate_intensity(self, days=7):
        """Calculate current problem intensity based on recent logs"""
        from app.models.problem_logs import ProblemLogs
        from datetime import datetime, timedelta
        
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        recent_logs = ProblemLogs.query.filter(
            ProblemLogs.problem_id == self.id,
            ProblemLogs.date >= start_date,
            ProblemLogs.date <= end_date
        ).all()
        
        # Calculate intensity based on frequency and weight
        ticked_count = sum(1 for log in recent_logs if log.ticked)
        total_days = len(recent_logs) if recent_logs else days
        
        if total_days == 0:
            return 0.0
        
        frequency = ticked_count / total_days
        intensity = frequency * self.weight * 10  # Scale to 0-10
        
        return min(intensity, 10.0)  # Cap at 10
