import os
from dotenv import load_dotenv

load_dotenv()

class DatabaseConfig:
    """Database configuration settings"""
    
    # PostgreSQL Configuration
    POSTGRES_HOST = os.getenv('POSTGRES_HOST', 'localhost')
    POSTGRES_PORT = os.getenv('POSTGRES_PORT', '5432')
    POSTGRES_DB = os.getenv('POSTGRES_DB', 'master_yourself_ai')
    POSTGRES_USER = os.getenv('POSTGRES_USER', 'postgres')
    POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD', 'password')
    
    # SQLAlchemy Configuration
    SQLALCHEMY_DATABASE_URI = f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_pre_ping': True,
        'pool_recycle': 300,
    }
    
    # Development Database (SQLite for testing)
    SQLITE_DATABASE_URI = "sqlite:///master_yourself_ai.db"
    
    @classmethod
    def get_database_uri(cls, use_sqlite=False):
        """Get database URI based on environment"""
        if use_sqlite or os.getenv('FLASK_ENV') == 'development':
            return cls.SQLITE_DATABASE_URI
        return cls.SQLALCHEMY_DATABASE_URI
