from datetime import datetime, date, timedelta
from sqlalchemy import Column, Integer, String, Text, Boolean, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app import db

class AIChallenges(db.Model):
    """AI-generated daily challenges"""
    __tablename__ = 'ai_challenges'
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    challenge_text = Column(Text, nullable=False)  # Single challenge text
    challenge_date = Column(Date, nullable=False, default=date.today)
    completed = Column(Boolean, default=False)
    completed_at = Column(DateTime)
    intensity = Column(Integer, default=0)  # -3 to 3 scale
    regeneration_count = Column(Integer, default=0)  # Track regeneration count for today
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        """Convert to dictionary for API response"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'challenge_text': self.challenge_text,
            'challenge_date': self.challenge_date.isoformat() if self.challenge_date else None,
            'completed': self.completed,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None,
            'intensity': self.intensity,
            'regeneration_count': self.regeneration_count,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
    
    @classmethod
    def get_today_challenge(cls, user_id):
        """Get today's AI challenge for a user"""
        today = date.today()
        return cls.query.filter_by(user_id=user_id, challenge_date=today).first()
    
    @classmethod
    def get_user_challenges(cls, user_id):
        """Get all challenges for a user"""
        return cls.query.filter_by(user_id=user_id).order_by(cls.challenge_date.desc()).all()
    
    @classmethod
    def get_completed_challenges(cls, user_id, days_back=30):
        """Get completed challenges for history"""
        end_date = date.today()
        start_date = end_date - timedelta(days=days_back)
        
        return cls.query.filter(
            cls.user_id == user_id,
            cls.completed == True,
            cls.challenge_date >= start_date
        ).order_by(cls.challenge_date.desc(), cls.completed_at.desc()).all()
    
    @classmethod
    def get_active_challenges(cls, user_id):
        """Get active (non-completed) challenges for a user"""
        return cls.query.filter_by(user_id=user_id, completed=False).order_by(cls.challenge_date.desc()).all()
    
    @classmethod
    def get_today_regeneration_count(cls, user_id):
        """Get the number of times user has regenerated challenges today"""
        today = date.today()
        challenges = cls.query.filter_by(user_id=user_id, challenge_date=today).all()
        return len(challenges)
    
    @classmethod
    def clear_old_challenges(cls):
        """Clear challenges from previous days"""
        today = date.today()
        # Delete challenges from previous days
        cls.query.filter(cls.challenge_date < today).delete()
        db.session.commit()
    
    @classmethod
    def ensure_daily_reset(cls, user_id):
        """Ensure challenges are reset for a new day"""
        today = date.today()
        # Check if user has any challenges from previous days
        old_challenges = cls.query.filter(
            cls.user_id == user_id,
            cls.challenge_date < today
        ).all()
        
        if old_challenges:
            # Clear old challenges
            for challenge in old_challenges:
                db.session.delete(challenge)
            db.session.commit()
            return True
        return False
    
    @classmethod
    def create_daily_challenge(cls, user_id, challenge_text):
        """Create a new daily challenge"""
        today = date.today()
        
        challenge = cls(
            user_id=user_id,
            challenge_text=challenge_text,
            challenge_date=today
        )
        
        db.session.add(challenge)
        db.session.commit()
        return challenge

    @classmethod
    def update_intensity(cls, challenge_id, intensity):
        """Update the intensity rating for a challenge"""
        if not -3 <= intensity <= 3:
            raise ValueError("Intensity must be between -3 and 3")
        
        challenge = cls.query.get(challenge_id)
        if challenge:
            challenge.intensity = intensity
            challenge.updated_at = datetime.utcnow()
            db.session.commit()
            return challenge
        return None
