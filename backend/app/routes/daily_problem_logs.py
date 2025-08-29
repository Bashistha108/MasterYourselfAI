from flask import Blueprint, request, jsonify
from app.models.daily_problem_logs import DailyProblemLogs
from app.models.problems import Problems
from app import db
from datetime import datetime

daily_problem_logs_bp = Blueprint('daily_problem_logs', __name__)

@daily_problem_logs_bp.route('/', methods=['GET'])
def get_daily_problem_logs():
    """Get all daily problem logs"""
    try:
        logs = DailyProblemLogs.query.all()
        return jsonify({
            'success': True,
            'data': [log.to_dict() for log in logs]
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@daily_problem_logs_bp.route('/', methods=['POST'])
def create_daily_problem_log():
    """Create a new daily problem log"""
    try:
        data = request.get_json()
        
        # Validate required fields
        if not data.get('problem_id'):
            return jsonify({
                'success': False,
                'error': 'problem_id is required'
            }), 400
        
        if not data.get('date'):
            return jsonify({
                'success': False,
                'error': 'date is required'
            }), 400
        
        # Check if problem exists
        problem = Problems.query.get(data['problem_id'])
        if not problem:
            return jsonify({
                'success': False,
                'error': 'Problem not found'
            }), 404
        
        # Parse date
        try:
            log_date = datetime.strptime(data['date'], '%Y-%m-%d').date()
        except ValueError:
            return jsonify({
                'success': False,
                'error': 'Invalid date format. Use YYYY-MM-DD'
            }), 400
        
        # Check if log already exists for this problem and date
        existing_log = DailyProblemLogs.query.filter_by(
            problem_id=data['problem_id'],
            date=log_date
        ).first()
        
        if existing_log:
            # Update existing log
            existing_log.faced = data.get('faced', False)
            existing_log.intensity = data.get('intensity', 0) if data.get('faced') else 0
            existing_log.updated_at = datetime.utcnow()
            db.session.commit()
            
            return jsonify({
                'success': True,
                'data': existing_log.to_dict()
            })
        else:
            # Create new log
            log = DailyProblemLogs(
                problem_id=data['problem_id'],
                date=log_date,
                faced=data.get('faced', False),
                intensity=data.get('intensity', 0) if data.get('faced') else 0
            )
            
            db.session.add(log)
            db.session.commit()
            
            return jsonify({
                'success': True,
                'data': log.to_dict()
            })
            
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@daily_problem_logs_bp.route('/<int:log_id>', methods=['PUT'])
def update_daily_problem_log(log_id):
    """Update a daily problem log"""
    try:
        log = DailyProblemLogs.query.get(log_id)
        if not log:
            return jsonify({
                'success': False,
                'error': 'Daily problem log not found'
            }), 404
        
        data = request.get_json()
        
        if 'faced' in data:
            log.faced = data['faced']
        
        if 'intensity' in data:
            log.intensity = data['intensity'] if data.get('faced') else 0
        
        log.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': log.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@daily_problem_logs_bp.route('/<int:log_id>', methods=['DELETE'])
def delete_daily_problem_log(log_id):
    """Delete a daily problem log"""
    try:
        log = DailyProblemLogs.query.get(log_id)
        if not log:
            return jsonify({
                'success': False,
                'error': 'Daily problem log not found'
            }), 404
        
        db.session.delete(log)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Daily problem log deleted successfully'
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
