from flask import Blueprint, request, jsonify
from app.models.daily_goal_intensities import DailyGoalIntensities
from app.models.weekly_goals import WeeklyGoals
from app import db
from datetime import datetime, date

daily_goal_intensities_bp = Blueprint('daily_goal_intensities', __name__)

@daily_goal_intensities_bp.route('/', methods=['GET'])
def get_daily_goal_intensities():
    """Get daily goal intensities"""
    try:
        goal_id = request.args.get('goal_id', type=int)
        intensity_date = request.args.get('intensity_date')
        
        query = DailyGoalIntensities.query
        
        if goal_id:
            query = query.filter_by(goal_id=goal_id)
        if intensity_date:
            try:
                date_obj = datetime.strptime(intensity_date, '%Y-%m-%d').date()
                query = query.filter_by(intensity_date=date_obj)
            except ValueError:
                return jsonify({
                    'success': False,
                    'error': 'Invalid date format. Use YYYY-MM-DD'
                }), 400
        
        intensities = query.order_by(DailyGoalIntensities.intensity_date.desc()).all()
        
        return jsonify({
            'success': True,
            'data': [intensity.to_dict() for intensity in intensities]
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@daily_goal_intensities_bp.route('/', methods=['POST'])
def create_daily_goal_intensity():
    """Create or update a daily goal intensity"""
    try:
        data = request.get_json()
        
        if not data or 'goal_id' not in data or 'intensity_date' not in data or 'intensity' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing required fields: goal_id, intensity_date, intensity'
            }), 400
        
        goal_id = data['goal_id']
        intensity_date_str = data['intensity_date']
        intensity = data['intensity']
        
        # Parse intensity_date
        try:
            intensity_date = datetime.strptime(intensity_date_str, '%Y-%m-%d').date()
        except ValueError:
            return jsonify({
                'success': False,
                'error': 'Invalid intensity_date format. Use YYYY-MM-DD'
            }), 400
        
        # Validate intensity range (1-10)
        if not (1 <= intensity <= 10):
            return jsonify({
                'success': False,
                'error': 'Intensity must be between 1 and 10'
            }), 400
        
        # Get or create daily intensity
        daily_intensity = DailyGoalIntensities.get_or_create_daily_intensity(goal_id, intensity_date)
        daily_intensity.intensity = intensity
        daily_intensity.updated_at = datetime.utcnow()
        
        db.session.commit()
        
        # Check and update completion status for the goal
        goal = WeeklyGoals.query.get(goal_id)
        if goal:
            goal.check_and_update_completion_status()
        
        return jsonify({
            'success': True,
            'data': daily_intensity.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@daily_goal_intensities_bp.route('/<int:intensity_id>', methods=['PUT'])
def update_daily_goal_intensity(intensity_id):
    """Update a daily goal intensity"""
    try:
        intensity = DailyGoalIntensities.query.get_or_404(intensity_id)
        data = request.get_json()
        
        if 'intensity' in data:
            new_intensity = data['intensity']
            if not (1 <= new_intensity <= 10):
                return jsonify({
                    'success': False,
                    'error': 'Intensity must be between 1 and 10'
                }), 400
            intensity.intensity = new_intensity
        
        intensity.updated_at = datetime.utcnow()
        db.session.commit()
        
        # Check and update completion status for the goal
        goal = WeeklyGoals.query.get(intensity.goal_id)
        if goal:
            goal.check_and_update_completion_status()
        
        return jsonify({
            'success': True,
            'data': intensity.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@daily_goal_intensities_bp.route('/<int:intensity_id>', methods=['DELETE'])
def delete_daily_goal_intensity(intensity_id):
    """Delete a daily goal intensity"""
    try:
        intensity = DailyGoalIntensities.query.get_or_404(intensity_id)
        goal_id = intensity.goal_id
        
        db.session.delete(intensity)
        db.session.commit()
        
        # Check and update completion status for the goal
        goal = WeeklyGoals.query.get(goal_id)
        if goal:
            goal.check_and_update_completion_status()
        
        return jsonify({
            'success': True,
            'message': 'Daily goal intensity deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
