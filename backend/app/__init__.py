from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS
from config import config

# Initialize extensions
db = SQLAlchemy()
migrate = Migrate()

def create_app(config_name='default'):
    """Application factory pattern"""
    app = Flask(__name__)
    
    # Load configuration
    app.config.from_object(config[config_name])
    config[config_name].init_app(app)
    
    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    CORS(app)
    
    # Register blueprints
    from app.routes.weekly_goals import weekly_goals_bp
    from app.routes.long_term_goals import long_term_goals_bp
    from app.routes.problems import problems_bp
    from app.routes.daily_problem_logs import daily_problem_logs_bp
    from app.routes.ai_challenges import ai_challenges_bp
    from app.routes.goal_ratings import goal_ratings_bp
    from app.routes.daily_goal_intensities import daily_goal_intensities_bp
    from app.routes.quick_notes import quick_notes_bp
    from app.routes.todo_items import todo_items_bp
    from app.routes.weekly_goal_intensities import weekly_goal_intensities_bp
    from app.routes.quick_wins import quick_wins_bp
    from app.routes.goal_notes import goal_notes_bp
    from app.routes.graphs import graphs_bp
    from app.routes.feedback import feedback_bp
    from app.routes.emails import emails_bp
    
    app.register_blueprint(weekly_goals_bp, url_prefix='/api/weekly-goals')
    app.register_blueprint(long_term_goals_bp, url_prefix='/api/long-term-goals')
    app.register_blueprint(problems_bp, url_prefix='/api/problems')
    app.register_blueprint(daily_problem_logs_bp, url_prefix='/api/daily-problem-logs')
    app.register_blueprint(ai_challenges_bp, url_prefix='/api/ai-challenges')
    app.register_blueprint(goal_ratings_bp, url_prefix='/api/goal-ratings')
    app.register_blueprint(daily_goal_intensities_bp, url_prefix='/api/daily-goal-intensities')
    app.register_blueprint(quick_notes_bp, url_prefix='/api/quick-notes')
    app.register_blueprint(todo_items_bp, url_prefix='/api/todo-items')
    app.register_blueprint(weekly_goal_intensities_bp, url_prefix='/api/weekly-goal-intensities')
    app.register_blueprint(quick_wins_bp, url_prefix='/api/quick-wins')
    app.register_blueprint(goal_notes_bp, url_prefix='/api/goal-notes')
    app.register_blueprint(graphs_bp, url_prefix='/api/graphs')
    app.register_blueprint(feedback_bp, url_prefix='/api/feedback')
    app.register_blueprint(emails_bp, url_prefix='/api/emails')
    
    # Health check endpoint
    @app.route('/health')
    def health_check():
        return {'status': 'healthy', 'message': 'Master Yourself AI API is running'}
    
    return app

# Import models to ensure they are registered with SQLAlchemy
from app.models import weekly_goals, long_term_goals, problems, daily_problem_logs, ai_challenges, goal_ratings, daily_goal_intensities, quick_notes, todo_items, weekly_goal_intensities, quick_wins, goal_notes
