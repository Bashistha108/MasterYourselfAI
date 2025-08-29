from datetime import datetime
from app import db

class WeeklyGoalIntensities(db.Model):
    __tablename__ = 'weekly_goal_intensities'
    
    id = db.Column(db.Integer, primary_key=True)
    goal_id = db.Column(db.Integer, db.ForeignKey('weekly_goals.id'), nullable=False)
    week_start = db.Column(db.Date, nullable=False)
    intensity = db.Column(db.Integer, nullable=False, default=0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship
    goal = db.relationship('WeeklyGoals', backref='weekly_intensities')
    
    def to_dict(self):
        return {
            'id': self.id,
            'goal_id': self.goal_id,
            'week_start': self.week_start.isoformat(),
            'intensity': self.intensity,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat(),
        }
    
    @classmethod
    def get_by_goal_and_week(cls, goal_id, week_start):
        """Get intensity for a specific goal and week"""
        return cls.query.filter_by(
            goal_id=goal_id,
            week_start=week_start
        ).first()
    
    @classmethod
    def get_by_goal(cls, goal_id):
        """Get all intensities for a specific goal"""
        return cls.query.filter_by(goal_id=goal_id).order_by(cls.week_start).all()
