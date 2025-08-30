from app import db
from datetime import datetime

class Email(db.Model):
    __tablename__ = 'emails'
    
    id = db.Column(db.Integer, primary_key=True)
    subject = db.Column(db.String(500), nullable=False)
    sender = db.Column(db.String(200), nullable=False)
    recipient = db.Column(db.String(200), nullable=True)
    content = db.Column(db.Text, nullable=False)
    date = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    email_type = db.Column(db.String(20), default='received', nullable=False)  # 'sent' or 'received'
    is_read = db.Column(db.Boolean, default=False, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    def __repr__(self):
        return f'<Email {self.id}: {self.subject}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'subject': self.subject,
            'sender': self.sender,
            'recipient': self.recipient,
            'content': self.content,
            'date': self.date.isoformat(),
            'email_type': self.email_type,
            'is_read': self.is_read,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
