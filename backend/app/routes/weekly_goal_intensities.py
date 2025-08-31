from flask import Blueprint, request, jsonify
from app import db
from app.models.weekly_goal_intensities import WeeklyGoalIntensities
from datetime import datetime

weekly_goal_intensities_bp = Blueprint('weekly_goal_intensities', __name__)

@weekly_goal_intensities_bp.route('/', methods=['GET'])
def get_weekly_goal_intensities():
    """Get all weekly goal intensities"""
    try:
        goal_id = request.args.get('goal_id', type=int)
        
        if goal_id:
            intensities = WeeklyGoalIntensities.get_by_goal(goal_id)
        else:
            intensities = WeeklyGoalIntensities.query.all()
        
        return jsonify({
            'success': True,
            'data': [intensity.to_dict() for intensity in intensities]
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weekly_goal_intensities_bp.route('/', methods=['POST'])
def create_weekly_goal_intensity():
    """Create a new weekly goal intensity"""
    try:
        data = request.get_json()
        
        if not data or 'goal_id' not in data or 'week_start' not in data or 'intensity' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing required fields: goal_id, week_start, intensity'
            }), 400
        
        goal_id = data['goal_id']
        week_start_str = data['week_start']
        intensity = data['intensity']
        
        # Parse week_start date
        try:
            week_start = datetime.strptime(week_start_str, '%Y-%m-%d').date()
        except ValueError:
            return jsonify({
                'success': False,
                'error': 'Invalid week_start format. Use YYYY-MM-DD'
            }), 400
        
        # Check if intensity already exists for this goal and week
        existing_intensity = WeeklyGoalIntensities.get_by_goal_and_week(goal_id, week_start)
        if existing_intensity:
            return jsonify({
                'success': False,
                'error': 'Intensity already exists for this goal and week'
            }), 400
        
        # Get the first user as default (for backward compatibility)
        from app.models.user import User
        default_user = User.query.first()
        if not default_user:
            return jsonify({
                'success': False,
                'error': 'No users found in database'
            }), 500
        
        # Create new intensity
        new_intensity = WeeklyGoalIntensities(
            user_id=default_user.id,
            goal_id=goal_id,
            week_start=week_start,
            intensity=intensity
        )
        
        db.session.add(new_intensity)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': new_intensity.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weekly_goal_intensities_bp.route('/<int:intensity_id>', methods=['PUT'])
def update_weekly_goal_intensity(intensity_id):
    """Update a weekly goal intensity"""
    try:
        intensity = WeeklyGoalIntensities.query.get(intensity_id)
        if not intensity:
            return jsonify({
                'success': False,
                'error': 'Weekly goal intensity not found'
            }), 404
        
        data = request.get_json()
        if not data or 'intensity' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing intensity field'
            }), 400
        
        intensity.intensity = data['intensity']
        intensity.updated_at = datetime.utcnow()
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': intensity.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weekly_goal_intensities_bp.route('/<int:intensity_id>', methods=['DELETE'])
def delete_weekly_goal_intensity(intensity_id):
    """Delete a weekly goal intensity"""
    try:
        intensity = WeeklyGoalIntensities.query.get(intensity_id)
        if not intensity:
            return jsonify({
                'success': False,
                'error': 'Weekly goal intensity not found'
            }), 404
        
        db.session.delete(intensity)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Weekly goal intensity deleted successfully'
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
