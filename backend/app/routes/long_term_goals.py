from flask import Blueprint, request, jsonify
from app.models.long_term_goals import LongTermGoals
from app.models.challenges import Challenges
from app import db
from datetime import datetime

long_term_goals_bp = Blueprint('long_term_goals', __name__)

@long_term_goals_bp.route('/', methods=['GET'])
def get_long_term_goals():
    """Get all long-term goals"""
    try:
        user_email = request.args.get('user_email')
        if not user_email:
            return jsonify({
                'success': False,
                'error': 'user_email is required'
            }), 400
        
        # Get database user ID from email
        from app.models.user import User
        user = User.get_by_email(user_email)
        if not user:
            return jsonify({
                'success': False,
                'error': 'User not found'
            }), 404
        
        goals = LongTermGoals.get_active_goals(user.id)
        return jsonify({
            'success': True,
            'data': [goal.to_dict() for goal in goals]
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@long_term_goals_bp.route('/completed', methods=['GET'])
def get_completed_long_term_goals():
    """Get all completed long-term goals"""
    try:
        user_email = request.args.get('user_email')
        if not user_email:
            return jsonify({
                'success': False,
                'error': 'user_email is required'
            }), 400
        
        # Get database user ID from email
        from app.models.user import User
        user = User.get_by_email(user_email)
        if not user:
            return jsonify({
                'success': False,
                'error': 'User not found'
            }), 404
        
        goals = LongTermGoals.get_completed_goals(user.id)
        return jsonify({
            'success': True,
            'data': [goal.to_dict() for goal in goals]
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@long_term_goals_bp.route('/archived', methods=['GET'])
def get_archived_long_term_goals():
    """Get all archived long-term goals"""
    try:
        user_email = request.args.get('user_email')
        if not user_email:
            return jsonify({
                'success': False,
                'error': 'user_email is required'
            }), 400
        
        # Get database user ID from email
        from app.models.user import User
        user = User.get_by_email(user_email)
        if not user:
            return jsonify({
                'success': False,
                'error': 'User not found'
            }), 404
        
        goals = LongTermGoals.get_archived_goals(user.id)
        return jsonify({
            'success': True,
            'data': [goal.to_dict() for goal in goals]
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@long_term_goals_bp.route('/', methods=['POST'])
def create_long_term_goal():
    """Create a new long-term goal"""
    try:
        data = request.get_json()
        
        if not data or 'title' not in data:
            return jsonify({
                'success': False,
                'error': 'Title is required'
            }), 400
        
        # Parse start_date and target_date if provided
        start_date = None
        target_date = None
        
        if data.get('start_date'):
            try:
                start_date = datetime.strptime(data['start_date'], '%Y-%m-%d')
            except ValueError:
                return jsonify({
                    'success': False,
                    'error': 'Invalid start_date format. Use YYYY-MM-DD'
                }), 400
        
        if data.get('target_date'):
            try:
                target_date = datetime.strptime(data['target_date'], '%Y-%m-%d')
            except ValueError:
                return jsonify({
                    'success': False,
                    'error': 'Invalid target_date format. Use YYYY-MM-DD'
                }), 400
        
        user_email = data.get('user_email')
        if not user_email:
            return jsonify({
                'success': False,
                'error': 'user_email is required'
            }), 400
        
        # Get database user ID from email
        from app.models.user import User
        user = User.get_by_email(user_email)
        if not user:
            return jsonify({
                'success': False,
                'error': 'User not found'
            }), 404
        
        goal = LongTermGoals(
            user_id=user.id,
            title=data['title'],
            description=data.get('description', ''),
            start_date=start_date,
            target_date=target_date
        )
        
        db.session.add(goal)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': goal.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@long_term_goals_bp.route('/<int:goal_id>', methods=['PUT'])
def update_long_term_goal(goal_id):
    """Update a long-term goal"""
    try:
        data = request.get_json()
        user_email = data.get('user_email')
        if not user_email:
            return jsonify({
                'success': False,
                'error': 'user_email is required'
            }), 400
        
        # Get database user ID from email
        from app.models.user import User
        user = User.get_by_email(user_email)
        if not user:
            return jsonify({
                'success': False,
                'error': 'User not found'
            }), 404
        
        goal = LongTermGoals.query.get_or_404(goal_id)
        
        # Check if goal belongs to the user
        if goal.user_id != user.id:
            return jsonify({
                'success': False,
                'error': 'Access denied'
            }), 403
        
        if 'title' in data:
            goal.title = data['title']
        if 'description' in data:
            goal.description = data['description']
        if 'start_date' in data:
            if data['start_date']:
                try:
                    goal.start_date = datetime.strptime(data['start_date'], '%Y-%m-%d')
                except ValueError:
                    return jsonify({
                        'success': False,
                        'error': 'Invalid start_date format. Use YYYY-MM-DD'
                    }), 400
            else:
                goal.start_date = None
        if 'target_date' in data:
            if data['target_date']:
                try:
                    goal.target_date = datetime.strptime(data['target_date'], '%Y-%m-%d')
                except ValueError:
                    return jsonify({
                        'success': False,
                        'error': 'Invalid target_date format. Use YYYY-MM-DD'
                    }), 400
            else:
                goal.target_date = None
        if 'status' in data:
            goal.status = data['status']
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': goal.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@long_term_goals_bp.route('/<int:goal_id>', methods=['DELETE'])
def delete_long_term_goal(goal_id):
    """Archive a long-term goal"""
    try:
        user_email = request.args.get('user_email')
        if not user_email:
            return jsonify({
                'success': False,
                'error': 'user_email is required'
            }), 400
        
        # Get database user ID from email
        from app.models.user import User
        user = User.get_by_email(user_email)
        if not user:
            return jsonify({
                'success': False,
                'error': 'User not found'
            }), 404
        
        goal = LongTermGoals.query.get_or_404(goal_id)
        
        # Check if goal belongs to the user
        if goal.user_id != user.id:
            return jsonify({
                'success': False,
                'error': 'Access denied'
            }), 403
        
        goal.archived = True
        goal.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': goal.to_dict(),
            'message': 'Goal archived successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@long_term_goals_bp.route('/<int:goal_id>/archive', methods=['POST'])
def archive_long_term_goal(goal_id):
    """Archive a long-term goal"""
    try:
        data = request.get_json()
        user_email = data.get('user_email')
        if not user_email:
            return jsonify({
                'success': False,
                'error': 'user_email is required'
            }), 400
        
        # Get database user ID from email
        from app.models.user import User
        user = User.get_by_email(user_email)
        if not user:
            return jsonify({
                'success': False,
                'error': 'User not found'
            }), 404
        
        goal = LongTermGoals.query.get_or_404(goal_id)
        
        # Check if goal belongs to the user
        if goal.user_id != user.id:
            return jsonify({
                'success': False,
                'error': 'Access denied'
            }), 403
        
        goal.archived = True
        goal.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': goal.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@long_term_goals_bp.route('/<int:goal_id>/restore-archived', methods=['POST'])
def restore_archived_long_term_goal(goal_id):
    """Restore an archived goal"""
    try:
        data = request.get_json()
        user_email = data.get('user_email')
        if not user_email:
            return jsonify({
                'success': False,
                'error': 'user_email is required'
            }), 400
        
        # Get database user ID from email
        from app.models.user import User
        user = User.get_by_email(user_email)
        if not user:
            return jsonify({
                'success': False,
                'error': 'User not found'
            }), 404
        
        goal = LongTermGoals.query.get_or_404(goal_id)
        
        # Check if goal belongs to the user
        if goal.user_id != user.id:
            return jsonify({
                'success': False,
                'error': 'Access denied'
            }), 403
        
        # Check if we can add more goals (max 3 active per week)
        active_goals = LongTermGoals.query.filter_by(user_id=user.id, status='active', archived=False).count()
        if active_goals >= 3:
            return jsonify({
                'success': False,
                'error': 'Already 3 goals active. Delete 1 to restore.'
            }), 400
        
        # Mark as not archived
        goal.archived = False
        goal.updated_at = datetime.utcnow()
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': goal.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@long_term_goals_bp.route('/<int:goal_id>/challenges', methods=['GET'])
def get_goal_challenges(goal_id):
    """Get challenges for a specific goal"""
    try:
        challenges = Challenges.query.filter_by(goal_id=goal_id).all()
        return jsonify({
            'success': True,
            'data': [challenge.to_dict() for challenge in challenges]
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@long_term_goals_bp.route('/<int:goal_id>/challenges', methods=['POST'])
def create_goal_challenge(goal_id):
    """Create a new challenge for a goal"""
    try:
        data = request.get_json()
        
        if not data or 'title' not in data:
            return jsonify({
                'success': False,
                'error': 'Title is required'
            }), 400
        
        challenge = Challenges(
            goal_id=goal_id,
            title=data['title'],
            description=data.get('description', ''),
            difficulty=data.get('difficulty', 'medium'),
            due_date=datetime.strptime(data['due_date'], '%Y-%m-%d').date() if data.get('due_date') else None
        )
        
        db.session.add(challenge)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': challenge.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@long_term_goals_bp.route('/challenges/<int:challenge_id>', methods=['PUT'])
def update_challenge(challenge_id):
    """Update a challenge"""
    try:
        challenge = Challenges.query.get_or_404(challenge_id)
        data = request.get_json()
        
        if 'title' in data:
            challenge.title = data['title']
        if 'description' in data:
            challenge.description = data['description']
        if 'difficulty' in data:
            challenge.difficulty = data['difficulty']
        if 'due_date' in data:
            challenge.due_date = datetime.strptime(data['due_date'], '%Y-%m-%d').date() if data['due_date'] else None
        if 'completed' in data:
            challenge.completed = data['completed']
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': challenge.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@long_term_goals_bp.route('/challenges/<int:challenge_id>', methods=['DELETE'])
def delete_challenge(challenge_id):
    """Delete a challenge"""
    try:
        challenge = Challenges.query.get_or_404(challenge_id)
        db.session.delete(challenge)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Challenge deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
