import os
from datetime import datetime

class Config:
    """Base configuration class"""
    
    # Basic Flask configuration
    SECRET_KEY = os.environ.get('SECRET_KEY')
    
    # Directory configuration
    BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))
    PROJECT_ROOT = os.path.dirname(BACKEND_DIR)
    DB_PATH = os.path.join(PROJECT_ROOT, 'master_yourself_ai.db')
    
    # PostgreSQL configuration
    DATABASE_URL = os.environ.get('DATABASE_URL')
    POSTGRES_HOST = os.environ.get('POSTGRES_HOST')
    POSTGRES_PORT = os.environ.get('POSTGRES_PORT', '5432')
    POSTGRES_USER = os.environ.get('POSTGRES_USER')
    POSTGRES_PASSWORD = os.environ.get('POSTGRES_PASSWORD')
    POSTGRES_DATABASE = os.environ.get('POSTGRES_DATABASE')
    
    # SQLAlchemy configuration
    if DATABASE_URL:
        # Render provides DATABASE_URL for PostgreSQL
        db_url = DATABASE_URL
        # Convert to psycopg2 format
        # db_url = db_url.replace('postgresql://', 'postgresql+psycopg2://')
        db_url = db_url.replace("postgresql://", "postgresql+psycopg://")
        SQLALCHEMY_DATABASE_URI = db_url
        print(f"Using Render PostgreSQL database with psycopg2")
    elif all([POSTGRES_HOST, POSTGRES_USER, POSTGRES_DATABASE]):
        # Manual PostgreSQL configuration
        from urllib.parse import quote_plus
        encoded_password = quote_plus(POSTGRES_PASSWORD or '')
        SQLALCHEMY_DATABASE_URI = f"postgresql://{POSTGRES_USER}:{encoded_password}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DATABASE}"
        print(f"Using PostgreSQL database: {POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DATABASE}")
    else:
        # Fallback to SQLite for local development
        SQLALCHEMY_DATABASE_URI = f"sqlite:///{os.path.abspath(DB_PATH)}"
        print(f"Using SQLite database: {os.path.abspath(DB_PATH)}")
    
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # Debug information
    print("BACKEND_DIR =", BACKEND_DIR)
    print("PROJECT_ROOT =", PROJECT_ROOT)
    print("DB_PATH =", DB_PATH)
    print("Absolute DB_PATH =", os.path.abspath(DB_PATH))
    print("SQLALCHEMY_DATABASE_URI =", SQLALCHEMY_DATABASE_URI)
    print("Database exists:", os.path.exists(DB_PATH))

    # Check if the database file exists, create if it doesn't
    if not os.path.exists(DB_PATH):
        print("Database file does not exist. Creating...")
        # Create the database file
        with open(DB_PATH, 'w') as f:
            f.write('')
        print("Database file created successfully")

    # Gemini API Configuration
    GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY')
    GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    
    @staticmethod
    def init_app(app):
        pass

class DevelopmentConfig(Config):
    """Development configuration"""
    DEBUG = True

class ProductionConfig(Config):
    """Production configuration"""
    DEBUG = False
    
    @classmethod
    def init_app(cls, app):
        Config.init_app(app)
        
        # Log to stderr in production
        import logging
        from logging import StreamHandler
        file_handler = StreamHandler()
        file_handler.setLevel(logging.INFO)
        app.logger.addHandler(file_handler)

class TestingConfig(Config):
    """Testing configuration"""
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'

config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}