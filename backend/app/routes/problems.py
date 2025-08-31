from flask import Blueprint, request, jsonify
from app.models.problems import Problems
from app.models.problem_logs import ProblemLogs
from app import db
from datetime import datetime, date

problems_bp = Blueprint('problems', __name__)

@problems_bp.route('/', methods=['GET'])
def get_problems():
    """Get all problems"""
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
        
        problems = Problems.query.filter_by(user_id=user.id).all()
        return jsonify({
            'success': True,
            'data': [problem.to_dict() for problem in problems]
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@problems_bp.route('/', methods=['POST'])
def create_problem():
    """Create a new problem"""
    try:
        data = request.get_json()
        
        if not data or 'title' not in data:
            return jsonify({
                'success': False,
                'error': 'Title is required'
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
        
        problem = Problems(
            user_id=user.id,
            name=data['title'],
            description=data.get('description', ''),
            category=data.get('category', 'general')
        )
        
        db.session.add(problem)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': problem.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@problems_bp.route('/<int:problem_id>', methods=['PUT'])
def update_problem(problem_id):
    """Update a problem"""
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
        
        problem = Problems.query.get_or_404(problem_id)
        
        # Check if problem belongs to the user
        if problem.user_id != user.id:
            return jsonify({
                'success': False,
                'error': 'Access denied'
            }), 403
        
        if 'title' in data:
            problem.name = data['title']
        if 'description' in data:
            problem.description = data['description']
        if 'category' in data:
            problem.category = data['category']
        if 'status' in data:
            problem.status = data['status']
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': problem.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@problems_bp.route('/<int:problem_id>', methods=['DELETE'])
def delete_problem(problem_id):
    """Delete a problem"""
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
        
        problem = Problems.query.get_or_404(problem_id)
        
        # Check if problem belongs to the user
        if problem.user_id != user.id:
            return jsonify({
                'success': False,
                'error': 'Access denied'
            }), 403
        
        db.session.delete(problem)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Problem deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@problems_bp.route('/logs', methods=['GET'])
def get_problem_logs():
    """Get problem logs for a specific date or today"""
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
        
        date_str = request.args.get('date')
        if date_str:
            log_date = datetime.strptime(date_str, '%Y-%m-%d').date()
            logs = ProblemLogs.query.filter_by(user_id=user.id, log_date=log_date).all()
        else:
            # Return all logs for the user if no date specified
            logs = ProblemLogs.query.filter_by(user_id=user.id).all()
        
        return jsonify({
            'success': True,
            'data': [log.to_dict() for log in logs],
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@problems_bp.route('/logs', methods=['POST'])
def create_problem_log():
    """Create a new problem log entry"""
    try:
        data = request.get_json()
        
        if not data or 'problem_id' not in data:
            return jsonify({
                'success': False,
                'error': 'Problem ID is required'
            }), 400
        
        user_email = data.get('user_email')
        if not user_email:
            # Get the first user as default (for backward compatibility)
            from app.models.user import User
            default_user = User.query.first()
            if not default_user:
                return jsonify({
                    'success': False,
                    'error': 'No users found in database'
                }), 500
            user = default_user
        else:
            # Get database user ID from email
            from app.models.user import User
            user = User.get_by_email(user_email)
            if not user:
                return jsonify({
                    'success': False,
                    'error': 'User not found'
                }), 404
        
        # Check if log already exists for today
        existing_log = ProblemLogs.query.filter_by(
            user_id=user.id,
            problem_id=data['problem_id'],
            log_date=date.today()
        ).first()
        
        if existing_log:
            return jsonify({
                'success': False,
                'error': 'Problem log already exists for today'
            }), 400
        
        log = ProblemLogs(
            user_id=user.id,
            problem_id=data['problem_id'],
            intensity=data.get('intensity', 5),
            notes=data.get('notes', '')
        )
        
        db.session.add(log)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': log.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@problems_bp.route('/logs/<int:log_id>', methods=['PUT'])
def update_problem_log(log_id):
    """Update a problem log entry"""
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
        
        log = ProblemLogs.query.get_or_404(log_id)
        
        # Check if log belongs to the user
        if log.user_id != user.id:
            return jsonify({
                'success': False,
                'error': 'Access denied'
            }), 403
        
        if 'intensity' in data:
            log.intensity = max(1, min(10, data['intensity']))
        if 'notes' in data:
            log.notes = data['notes']
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': log.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
