from flask import Blueprint, request, jsonify
from app.models.ai_challenges import AIChallenges
from app.models.problem_logs import ProblemLogs
from app.models.problems import Problems
from app.models.weekly_goals import WeeklyGoals
from app.models.long_term_goals import LongTermGoals
from app.services.gemini_service import GeminiService
from app import db
from datetime import datetime, date, timedelta
import logging

logger = logging.getLogger(__name__)
ai_challenges_bp = Blueprint('ai_challenges', __name__)

# Initialize Gemini service
try:
    gemini_service = GeminiService()
    GEMINI_AVAILABLE = True
    logger.info("Gemini service initialized successfully")
except Exception as e:
    gemini_service = None
    GEMINI_AVAILABLE = False
    logger.warning(f"Gemini service not available: {str(e)}")

@ai_challenges_bp.route('/', methods=['GET'])
def get_ai_challenges():
    """Get AI challenges for a user"""
    try:
        user_id = request.args.get('user_id')
        print(f"🔍 Getting AI challenges for user: {user_id}")
        logger.info(f"🔍 Getting AI challenges for user: {user_id}")
        
        if not user_id:
            print("❌ No user_id provided in request")
            logger.warning("❌ No user_id provided in request")
            return jsonify({
                'success': False,
                'error': 'user_id is required'
            }), 400
        
        challenges = AIChallenges.get_user_challenges(user_id)
        print(f"✅ Found {len(challenges)} challenges for user {user_id}")
        logger.info(f"✅ Found {len(challenges)} challenges for user {user_id}")
        
        challenge_data = [challenge.to_dict() for challenge in challenges]
        for i, challenge in enumerate(challenge_data):
            challenge_text = challenge.get('challenge_text', 'No text')
            challenge_date = challenge.get('challenge_date', 'No date')
            print(f"📋 Challenge {i+1}: {challenge_text} (Date: {challenge_date})")
            logger.info(f"📋 Challenge {i+1}: {challenge_text} (Date: {challenge_date})")
        
        return jsonify({
            'success': True,
            'data': challenge_data
        }), 200
    except Exception as e:
        print(f"❌ Error getting AI challenges: {str(e)}")
        logger.error(f"❌ Error getting AI challenges: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@ai_challenges_bp.route('/today', methods=['GET'])
def get_today_challenge():
    """Get today's AI challenge for a user"""
    try:
        user_id = request.args.get('user_id')
        logger.info(f"🔍 Getting today's AI challenge for user: {user_id}")
        
        if not user_id:
            logger.warning("❌ No user_id provided in request")
            return jsonify({
                'success': False,
                'error': 'user_id is required'
            }), 400
        
        challenge = AIChallenges.get_today_challenge(user_id)
        if challenge:
            logger.info(f"✅ Found today's challenge: {challenge.challenge_text}")
        else:
            logger.info("📝 No challenge found for today, generating new one...")
            challenge = generate_ai_challenge_for_user(user_id)
            if challenge:
                logger.info(f"✅ Generated new challenge: {challenge.challenge_text}")
            else:
                logger.warning("❌ Failed to generate new challenge")
        
        return jsonify({
            'success': True,
            'data': challenge.to_dict() if challenge else None
        }), 200
    except Exception as e:
        logger.error(f"❌ Error getting today's challenge: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@ai_challenges_bp.route('/today-challenges', methods=['GET'])
def get_today_challenges():
    """Get all today's AI challenges for a user"""
    try:
        user_id = request.args.get('user_id')
        logger.info(f"🔍 Getting today's AI challenges for user: {user_id}")
        
        if not user_id:
            logger.warning("❌ No user_id provided in request")
            return jsonify({
                'success': False,
                'error': 'user_id is required'
            }), 400
        
        today = date.today()
        challenges = AIChallenges.query.filter_by(
            user_id=user_id, 
            challenge_date=today
        ).order_by(AIChallenges.created_at.desc()).all()
        
        challenge_data = [challenge.to_dict() for challenge in challenges]
        logger.info(f"✅ Found {len(challenge_data)} challenges for today")
        
        return jsonify({
            'success': True,
            'data': challenge_data,
            'count': len(challenge_data)
        }), 200
    except Exception as e:
        logger.error(f"❌ Error getting today's challenges: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@ai_challenges_bp.route('/generate', methods=['POST'])
def generate_ai_challenge():
    """Generate a new AI challenge for a user"""
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        
        if not user_id:
            return jsonify({
                'success': False,
                'error': 'user_id is required'
            }), 400
        
        # Check for daily reset
        AIChallenges.ensure_daily_reset(user_id)
        
        # Check if user has already generated 3 challenges today
        today_count = AIChallenges.get_today_regeneration_count(user_id)
        if today_count >= 3:
            # Return all today's challenges when limit is reached
            today = date.today()
            challenges = AIChallenges.query.filter_by(
                user_id=user_id, 
                challenge_date=today
            ).order_by(AIChallenges.created_at.desc()).all()
            
            challenge_data = [challenge.to_dict() for challenge in challenges]
            return jsonify({
                'success': True,
                'data': challenge_data,
                'limit_reached': True,
                'message': 'Maximum 3 challenges per day reached. Please select from existing challenges.'
            }), 200
        
        # Generate a single new challenge
        challenge = generate_ai_challenge_for_user(user_id)
        
        return jsonify({
            'success': True,
            'data': challenge.to_dict(),
            'limit_reached': False,
            'remaining': 3 - (today_count + 1)
        }), 201
        
    except Exception as e:
        logger.error(f"Error generating AI challenge: {str(e)}")
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@ai_challenges_bp.route('/<int:challenge_id>/complete', methods=['PUT'])
def complete_ai_challenge(challenge_id):
    """Mark an AI challenge as completed"""
    try:
        challenge = AIChallenges.query.get_or_404(challenge_id)
        data = request.get_json()
        
        challenge.completed = data.get('completed', True)
        
        if challenge.completed:
            challenge.completed_at = datetime.utcnow()
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': challenge.to_dict()
        }), 200
        
    except Exception as e:
        logger.error(f"Error completing AI challenge: {str(e)}")
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@ai_challenges_bp.route('/<int:challenge_id>', methods=['DELETE'])
def delete_ai_challenge(challenge_id):
    """Delete an AI challenge"""
    try:
        challenge = AIChallenges.query.get_or_404(challenge_id)
        db.session.delete(challenge)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Challenge deleted successfully'
        }), 200
        
    except Exception as e:
        logger.error(f"Error deleting AI challenge: {str(e)}")
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@ai_challenges_bp.route('/analytics', methods=['GET'])
def get_challenge_analytics():
    """Get analytics about AI challenges and completion rates"""
    try:
        # Get challenges from last 30 days
        month_ago = date.today() - timedelta(days=30)
        challenges = AIChallenges.query.filter(
            AIChallenges.challenge_date >= month_ago
        ).all()
        
        total_challenges = len(challenges)
        completed_challenges = len([c for c in challenges if c.completed])
        completion_rate = (completed_challenges / total_challenges * 100) if total_challenges > 0 else 0
        
        # Average rating
        rated_challenges = [c for c in challenges if c.rating is not None]
        avg_rating = sum(c.rating for c in rated_challenges) / len(rated_challenges) if rated_challenges else 0
        
        return jsonify({
            'success': True,
            'data': {
                'total_challenges': total_challenges,
                'completed_challenges': completed_challenges,
                'completion_rate': round(completion_rate, 2),
                'average_rating': round(avg_rating, 2),
                'period_days': 30
            }
        }), 200
    except Exception as e:
        logger.error(f"Error getting challenge analytics: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@ai_challenges_bp.route('/test-gemini', methods=['GET'])
def test_gemini_connection():
    """Test Gemini API connection"""
    try:
        if not GEMINI_AVAILABLE:
            return jsonify({
                'success': False,
                'error': 'Gemini service not available'
            }), 503
        
        is_connected = gemini_service.test_connection()
        
        return jsonify({
            'success': True,
            'data': {
                'connected': is_connected,
                'service_available': GEMINI_AVAILABLE
            }
        }), 200
    except Exception as e:
        logger.error(f"Error testing Gemini connection: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@ai_challenges_bp.route('/create-ai-challenge', methods=['POST'])
def create_ai_challenge_with_gemini():
    """Create an AI challenge using Gemini based on user's problems and goals"""
    try:
        data = request.get_json()
        user_id = data.get('user_id', 'default_user')
        
        # Step 1: Read user's problems, weekly goals, and long-term goals
        weekly_goals = WeeklyGoals.get_current_week_goals()
        long_term_goals = LongTermGoals.get_active_goals()
        active_problems = Problems.query.filter_by(status='active').all()
        
        logger.info(f"Creating AI challenge for user {user_id}")
        logger.info(f"Found {len(weekly_goals)} weekly goals, {len(long_term_goals)} long-term goals, {len(active_problems)} problems")
        
        # Step 2: Use Gemini to create a challenge based on the data
        if GEMINI_AVAILABLE and gemini_service:
            try:
                challenge_data = gemini_service.generate_challenge(weekly_goals, long_term_goals, active_problems)
                if challenge_data and challenge_data.get('description'):
                    challenge_text = challenge_data['description']
                    logger.info(f"Generated challenge with Gemini: {challenge_text}")
                else:
                    # Fallback if Gemini fails
                    challenge_text = "Practice a new skill for 30 minutes"
                    logger.warning("Gemini returned empty data, using fallback")
            except Exception as e:
                logger.error(f"Gemini generation failed: {str(e)}")
                challenge_text = "Practice a new skill for 30 minutes"
        else:
            # Fallback if Gemini is not available
            challenge_text = "Practice a new skill for 30 minutes"
            logger.warning("Gemini not available, using fallback")
        
        # Step 3: Save the challenge in the database
        challenge = AIChallenges.create_daily_challenge(
            user_id=user_id,
            challenge_text=challenge_text
        )
        
        # Step 4: Return the challenge
        return jsonify({
            'success': True,
            'data': {
                'challenge': challenge.to_dict(),
                'context': {
                    'weekly_goals_count': len(weekly_goals),
                    'long_term_goals_count': len(long_term_goals),
                    'problems_count': len(active_problems),
                    'gemini_used': GEMINI_AVAILABLE and gemini_service is not None
                }
            }
        }), 201
        
    except Exception as e:
        logger.error(f"Error creating AI challenge: {str(e)}")
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@ai_challenges_bp.route('/completed', methods=['GET'])
def get_completed_challenges():
    """Get completed AI challenges for a user"""
    try:
        user_id = request.args.get('user_id')
        if not user_id:
            return jsonify({
                'success': False,
                'error': 'user_id is required'
            }), 400
        
        challenges = AIChallenges.get_completed_challenges(user_id)
        return jsonify({
            'success': True,
            'data': [challenge.to_dict() for challenge in challenges]
        }), 200
    except Exception as e:
        logger.error(f"Error getting completed AI challenges: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@ai_challenges_bp.route('/<int:challenge_id>/intensity', methods=['PUT'])
def update_challenge_intensity(challenge_id):
    """Update the intensity rating for a completed challenge"""
    try:
        data = request.get_json()
        intensity = data.get('intensity')
        
        if intensity is None:
            return jsonify({
                'success': False,
                'error': 'intensity is required'
            }), 400
        
        if not -3 <= intensity <= 3:
            return jsonify({
                'success': False,
                'error': 'intensity must be between -3 and 3'
            }), 400
        
        challenge = AIChallenges.update_intensity(challenge_id, intensity)
        
        if challenge:
            return jsonify({
                'success': True,
                'data': challenge.to_dict()
            }), 200
        else:
            return jsonify({
                'success': False,
                'error': 'Challenge not found'
            }), 404
            
    except Exception as e:
        logger.error(f"Error updating challenge intensity: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@ai_challenges_bp.route('/completed-history', methods=['GET'])
def get_completed_challenges_history():
    """Get completed challenges history for a user"""
    try:
        user_id = request.args.get('user_id')
        days_back = int(request.args.get('days', 30))
        
        if not user_id:
            return jsonify({
                'success': False,
                'error': 'user_id is required'
            }), 400
        
        challenges = AIChallenges.get_completed_challenges(user_id, days_back)
        challenge_data = [challenge.to_dict() for challenge in challenges]
        
        return jsonify({
            'success': True,
            'data': challenge_data,
            'total_challenges': len(challenge_data)
        }), 200
        
    except Exception as e:
        logger.error(f"Error getting completed challenges history: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

def generate_ai_challenge_for_user(user_id):
    """Generate an AI challenge using Gemini API based on user's problems and goals"""
    # Get user's active weekly goals for current week
    weekly_goals = WeeklyGoals.get_current_week_goals()
    
    # Get user's active long term goals
    long_term_goals = LongTermGoals.get_active_goals()
    
    # Get user's active problems
    active_problems = Problems.query.filter_by(status='active').all()
    
    # Log what data we found for debugging
    logger.info(f"Generating challenge for user {user_id}")
    logger.info(f"Weekly goals found: {len(weekly_goals)}")
    logger.info(f"Long term goals found: {len(long_term_goals)}")
    logger.info(f"Active problems found: {len(active_problems)}")
    
    try:
        # Always try Gemini first - this is the primary method
        if GEMINI_AVAILABLE and gemini_service:
            try:
                challenge_data = gemini_service.generate_challenge(weekly_goals, long_term_goals, active_problems)
                if challenge_data and challenge_data.get('description'):
                    logger.info(f"Generated challenge with Gemini for user {user_id}: {challenge_data['description']}")
                    return AIChallenges.create_daily_challenge(
                        user_id=user_id,
                        challenge_text=challenge_data['description']
                    )
                else:
                    logger.warning(f"Gemini returned empty challenge data for user {user_id}")
            except Exception as e:
                logger.error(f"Gemini generation failed for user {user_id}: {str(e)}")
        
        # If Gemini is not available or fails, use a simple fallback
        logger.warning(f"Gemini not available, using fallback for user {user_id}")
        
        # Create a simple challenge based on available data
        if weekly_goals or long_term_goals or active_problems:
            # Use the first available data to create a meaningful challenge
            if weekly_goals:
                goal = weekly_goals[0]
                challenge_text = f"Spend 30 minutes working on: {goal.title}"
            elif long_term_goals:
                goal = long_term_goals[0]
                challenge_text = f"Take one step toward: {goal.title}"
            elif active_problems:
                problem = active_problems[0]
                challenge_text = f"Take one action to address: {problem.name}"
            else:
                challenge_text = "Practice a new skill for 30 minutes"
        else:
            challenge_text = "Practice a new skill for 30 minutes"
        
        return AIChallenges.create_daily_challenge(
            user_id=user_id,
            challenge_text=challenge_text
        )
        
    except Exception as e:
        logger.error(f"Error generating challenge for user {user_id}: {str(e)}")
        # Final fallback
        return AIChallenges.create_daily_challenge(
            user_id=user_id,
            challenge_text="Practice a new skill for 30 minutes"
        )




