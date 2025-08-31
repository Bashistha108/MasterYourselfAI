from datetime import datetime, timedelta
from app import db
from werkzeug.security import generate_password_hash, check_password_hash

class ResetToken(db.Model):
    """Model for storing password reset tokens"""
    __tablename__ = 'reset_tokens'
    
    id = db.Column(db.Integer, primary_key=True)
    token = db.Column(db.String(255), unique=True, nullable=False)
    email = db.Column(db.String(120), nullable=False)
    expires_at = db.Column(db.DateTime, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    @classmethod
    def create_token(cls, email, token, expires_in_hours=1):
        """Create a new reset token"""
        expires_at = datetime.utcnow() + timedelta(hours=expires_in_hours)
        reset_token = cls(token=token, email=email, expires_at=expires_at)
        db.session.add(reset_token)
        db.session.commit()
        return reset_token
    
    @classmethod
    def get_valid_token(cls, token):
        """Get a valid token"""
        reset_token = cls.query.filter_by(token=token).first()
        if reset_token and reset_token.expires_at > datetime.utcnow():
            return reset_token
        return None
    
    @classmethod
    def delete_token(cls, token):
        """Delete a token"""
        reset_token = cls.query.filter_by(token=token).first()
        if reset_token:
            db.session.delete(reset_token)
            db.session.commit()

class User(db.Model):
    """User model for storing user credentials"""
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=True)  # Nullable for Google users
    display_name = db.Column(db.String(100))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def set_password(self, password):
        """Hash and set password"""
        self.password_hash = generate_password_hash(password)
        self.updated_at = datetime.utcnow()
    
    def check_password(self, password):
        """Check if password is correct"""
        if not self.password_hash:
            return False  # Google users don't have passwords
        return check_password_hash(self.password_hash, password)
    
    @classmethod
    def get_by_email(cls, email):
        """Get user by email"""
        return cls.query.filter_by(email=email).first()
    
    @classmethod
    def create_user(cls, email, password=None, display_name=None):
        """Create a new user"""
        user = cls(email=email, display_name=display_name)
        if password:
            user.set_password(password)
        db.session.add(user)
        db.session.commit()
        return user
    
    def to_dict(self):
        """Convert to dictionary"""
        return {
            'id': self.id,
            'email': self.email,
            'display_name': self.display_name,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
