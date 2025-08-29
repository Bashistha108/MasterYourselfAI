import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class Config:
    """Base configuration class"""
    SECRET_KEY = os.environ.get('SECRET_KEY')

    # Get the absolute path to the backend directory (where config.py is located)
    BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))
    
    # Get the absolute path to the project root (parent of backend directory)
    PROJECT_ROOT = os.path.dirname(BACKEND_DIR)
    
    # Full path to database file - use project root to ensure consistency
    DB_PATH = os.path.join(PROJECT_ROOT, 'master_yourself_ai.db')
    
    # Ensure the directory containing the database exists
    db_dir = os.path.dirname(DB_PATH)
    if not os.path.exists(db_dir):
        os.makedirs(db_dir)

    # SQLAlchemy configuration - always use absolute path, ignore environment variable
    SQLALCHEMY_DATABASE_URI = f"sqlite:///{os.path.abspath(DB_PATH)}"
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
