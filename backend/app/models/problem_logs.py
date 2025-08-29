from datetime import datetime, date
from sqlalchemy import Column, Integer, Boolean, Date, DateTime, ForeignKey, String
from sqlalchemy.orm import relationship
from app import db

class ProblemLogs(db.Model):
    """Daily problem logging (tick/un-tick)"""
    __tablename__ = 'problem_logs'
    
    id = Column(Integer, primary_key=True)
    problem_id = Column(Integer, ForeignKey('problems.id'), nullable=False)
    log_date = Column(Date, nullable=False, default=date.today)
    intensity = Column(Integer, nullable=False, default=5)  # 1-10 scale
    notes = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    problem = relationship('Problems', back_populates='problem_logs')
    
    def to_dict(self):
        """Convert to dictionary for API response"""
        return {
            'id': self.id,
            'problem_id': self.problem_id,
            'log_date': self.log_date.isoformat(),
            'intensity': self.intensity,
            'notes': self.notes,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
    
    @classmethod
    def get_today_logs(cls):
        """Get all problem logs for today"""
        today = date.today()
        return cls.query.filter_by(log_date=today).all()
    
    @classmethod
    def get_or_create_log(cls, problem_id, log_date=None):
        """Get existing log or create new one for a specific date"""
        if log_date is None:
            log_date = date.today()
        
        log = cls.query.filter_by(problem_id=problem_id, log_date=log_date).first()
        if not log:
            log = cls(problem_id=problem_id, log_date=log_date)
            db.session.add(log)
            db.session.commit()
        
        return log
