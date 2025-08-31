from datetime import datetime, date, timedelta
from app import db

class DailyGoalIntensities(db.Model):
    __tablename__ = 'daily_goal_intensities'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    goal_id = db.Column(db.Integer, db.ForeignKey('weekly_goals.id'), nullable=False)
    intensity_date = db.Column(db.Date, nullable=False)
    intensity = db.Column(db.Integer, nullable=False, default=1)  # Default to lowest intensity (1)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship
    goal = db.relationship('WeeklyGoals', backref='daily_intensities')
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'goal_id': self.goal_id,
            'intensity_date': self.intensity_date.isoformat(),
            'intensity': self.intensity,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat(),
        }
    
    @classmethod
    def get_by_goal_and_date(cls, goal_id, intensity_date):
        """Get intensity for a specific goal and date"""
        return cls.query.filter_by(
            goal_id=goal_id,
            intensity_date=intensity_date
        ).first()
    
    @classmethod
    def get_by_goal_and_week(cls, goal_id, week_start_date):
        """Get all daily intensities for a specific goal and week"""
        week_end_date = week_start_date + timedelta(days=7)
        return cls.query.filter(
            cls.goal_id == goal_id,
            cls.intensity_date >= week_start_date,
            cls.intensity_date < week_end_date
        ).order_by(cls.intensity_date).all()
    
    @classmethod
    def get_or_create_daily_intensity(cls, goal_id, intensity_date):
        """Get existing daily intensity or create with default value"""
        intensity = cls.get_by_goal_and_date(goal_id, intensity_date)
        if not intensity:
            # Get the first user as default (for backward compatibility)
            from app.models.user import User
            default_user = User.query.first()
            if not default_user:
                raise Exception("No users found in database")
            
            intensity = cls(
                goal_id=goal_id,
                intensity_date=intensity_date,
                user_id=default_user.id,
                intensity=1  # Default to lowest intensity
            )
            db.session.add(intensity)
            db.session.commit()
        return intensity
