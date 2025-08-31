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

    # Database configuration
    # Priority: PostgreSQL (Render) > MySQL > SQLite
    
    # Check for Render's DATABASE_URL first (PostgreSQL)
    DATABASE_URL = os.environ.get('DATABASE_URL')
    
    # Manual PostgreSQL configuration
    POSTGRES_HOST = os.environ.get('POSTGRES_HOST')
    POSTGRES_PORT = os.environ.get('POSTGRES_PORT', '5432')
    POSTGRES_USER = os.environ.get('POSTGRES_USER')
    POSTGRES_PASSWORD = os.environ.get('POSTGRES_PASSWORD')
    POSTGRES_DATABASE = os.environ.get('POSTGRES_DATABASE')
    
    # MySQL configuration (fallback)
    MYSQL_HOST = os.environ.get('MYSQL_HOST')
    MYSQL_PORT = os.environ.get('MYSQL_PORT', '3306')
    MYSQL_USER = os.environ.get('MYSQL_USER')
    MYSQL_PASSWORD = os.environ.get('MYSQL_PASSWORD')
    MYSQL_DATABASE = os.environ.get('MYSQL_DATABASE')
    
    # SQLAlchemy configuration
    # TEMPORARY FIX: Use SQLite to get things working immediately
    SQLALCHEMY_DATABASE_URI = 'sqlite:///instance/master_yourself_ai.db'
    print(f"Using SQLite database for immediate functionality")
    elif all([POSTGRES_HOST, POSTGRES_USER, POSTGRES_DATABASE]):
        # Manual PostgreSQL configuration
        from urllib.parse import quote_plus
        encoded_password = quote_plus(POSTGRES_PASSWORD or '')
        SQLALCHEMY_DATABASE_URI = f"postgresql://{POSTGRES_USER}:{encoded_password}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DATABASE}"
        print(f"Using PostgreSQL database: {POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DATABASE}")
    elif all([MYSQL_HOST, MYSQL_USER, MYSQL_DATABASE]):
        # Use MySQL - URL encode the password to handle special characters
        from urllib.parse import quote_plus
        encoded_password = quote_plus(MYSQL_PASSWORD or '')
        SQLALCHEMY_DATABASE_URI = f"mysql+pymysql://{MYSQL_USER}:{encoded_password}@{MYSQL_HOST}:{MYSQL_PORT}/{MYSQL_DATABASE}?charset=utf8mb4"
        print(f"Using MySQL database: {MYSQL_HOST}:{MYSQL_PORT}/{MYSQL_DATABASE}")
    else:
        # Use SQLite as fallback
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
