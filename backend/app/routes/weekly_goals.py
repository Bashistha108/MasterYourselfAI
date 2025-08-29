from flask import Blueprint, request, jsonify
from app.models.weekly_goals import WeeklyGoals
from app import db
from datetime import datetime, timedelta

weekly_goals_bp = Blueprint('weekly_goals', __name__)

@weekly_goals_bp.route('/', methods=['GET'])
def get_weekly_goals():
    """Get all weekly goals for current week"""
    try:
        goals = WeeklyGoals.get_current_week_goals()
        return jsonify({
            'success': True,
            'data': [goal.to_dict() for goal in goals]
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weekly_goals_bp.route('/all', methods=['GET'])
def get_all_weekly_goals():
    """Get all weekly goals (current and past weeks)"""
    try:
        goals = WeeklyGoals.get_all_goals()
        return jsonify({
            'success': True,
            'data': [goal.to_dict() for goal in goals]
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weekly_goals_bp.route('/completed', methods=['GET'])
def get_completed_weekly_goals():
    """Get all completed weekly goals"""
    try:
        goals = WeeklyGoals.get_completed_goals()
        return jsonify({
            'success': True,
            'data': [goal.to_dict() for goal in goals]
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weekly_goals_bp.route('/archived', methods=['GET'])
def get_archived_weekly_goals():
    """Get all archived weekly goals"""
    try:
        goals = WeeklyGoals.get_archived_goals()
        return jsonify({
            'success': True,
            'data': [goal.to_dict() for goal in goals]
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weekly_goals_bp.route('/', methods=['POST'])
def create_weekly_goal():
    """Create a new weekly goal"""
    try:
        data = request.get_json()
        
        if not data or 'title' not in data:
            return jsonify({
                'success': False,
                'error': 'Title is required'
            }), 400
        
        # Check if we can add more goals (max 3 active per week)
        if not WeeklyGoals.can_add_goal():
            return jsonify({
                'success': False,
                'error': 'Maximum 3 active weekly goals allowed per week. Complete some goals to add new ones.'
            }), 400
        
        goal = WeeklyGoals(
            title=data['title'],
            description=data.get('description')
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

@weekly_goals_bp.route('/<int:goal_id>', methods=['PUT'])
def update_weekly_goal(goal_id):
    """Update a weekly goal"""
    try:
        goal = WeeklyGoals.query.get_or_404(goal_id)
        data = request.get_json()
        
        if 'title' in data:
            goal.title = data['title']
        if 'description' in data:
            goal.description = data['description']
        if 'rating' in data:
            goal.rating = max(0, min(10, data['rating']))  # Ensure 0-10 range
        if 'completed' in data:
            goal.completed = bool(data['completed'])
        
        # Only check and update completion status if completed field is not explicitly set
        # This prevents automatic uncompletion of manually completed goals
        if 'completed' not in data:
            goal.check_and_update_completion_status()
        
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

@weekly_goals_bp.route('/<int:goal_id>', methods=['DELETE'])
def delete_weekly_goal(goal_id):
    """Delete a weekly goal"""
    try:
        goal = WeeklyGoals.query.get_or_404(goal_id)
        db.session.delete(goal)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Goal deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weekly_goals_bp.route('/<int:goal_id>/check-completion', methods=['POST'])
def check_goal_completion(goal_id):
    """Check and update goal completion status based on average rating"""
    try:
        goal = WeeklyGoals.query.get_or_404(goal_id)
        
        # Check and update completion status
        was_updated = goal.check_and_update_completion_status()
        
        return jsonify({
            'success': True,
            'data': goal.to_dict(),
            'was_updated': was_updated
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weekly_goals_bp.route('/<int:goal_id>/archive', methods=['POST'])
def archive_weekly_goal(goal_id):
    """Archive a weekly goal (soft delete)"""
    try:
        goal = WeeklyGoals.query.get_or_404(goal_id)
        
        # Mark as archived
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

@weekly_goals_bp.route('/<int:goal_id>/restore', methods=['POST'])
def restore_weekly_goal(goal_id):
    """Restore a completed goal without triggering automatic completion check"""
    try:
        goal = WeeklyGoals.query.get_or_404(goal_id)
        
        # Check if we can add more goals (max 3 active per week)
        current_week_goals = WeeklyGoals.get_current_week_goals()
        active_goals = [g for g in current_week_goals if not g.completed]
        
        if len(active_goals) >= 3:
            return jsonify({
                'success': False,
                'error': 'Already 3 goals active. Delete 1 to restore.'
            }), 400
        
        # Mark as not completed without checking completion status
        goal.completed = False
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

@weekly_goals_bp.route('/<int:goal_id>/restore-archived', methods=['POST'])
def restore_archived_weekly_goal(goal_id):
    """Restore an archived goal"""
    try:
        goal = WeeklyGoals.query.get_or_404(goal_id)
        
        # Check if the goal is from the current week and if we can add more goals (max 3 active per week)
        now = datetime.utcnow()
        start_of_week = now - timedelta(days=now.weekday())
        start_of_week = start_of_week.replace(hour=0, minute=0, second=0, microsecond=0)
        end_of_week = start_of_week + timedelta(days=7)
        
        # Check if the goal is from the current week
        if (goal.week_start_date >= start_of_week and goal.week_start_date < end_of_week):
            # If it's from current week, check the 3 goals limit
            # Get all goals from current week (including archived ones)
            current_week_goals = WeeklyGoals.query.filter(
                WeeklyGoals.week_start_date >= start_of_week,
                WeeklyGoals.week_start_date < end_of_week
            ).all()
            
            # Count active goals (not completed and not archived)
            active_goals = [g for g in current_week_goals if not g.completed and not g.archived]
            
            # If the goal being restored is currently archived, we need to check if restoring it would exceed the limit
            if goal.archived and len(active_goals) >= 3:
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

@weekly_goals_bp.route('/<int:goal_id>/average-rating', methods=['GET'])
def get_goal_average_rating(goal_id):
    """Get average rating for a goal"""
    try:
        goal = WeeklyGoals.query.get_or_404(goal_id)
        average_rating = goal.calculate_average_rating()
        
        return jsonify({
            'success': True,
            'data': {
                'goal_id': goal_id,
                'average_rating': average_rating
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weekly_goals_bp.route('/<int:goal_id>/average-intensity', methods=['GET'])
def get_goal_average_intensity(goal_id):
    """Get average intensity for a goal"""
    try:
        goal = WeeklyGoals.query.get_or_404(goal_id)
        average_intensity = goal.calculate_average_intensity()
        
        return jsonify({
            'success': True,
            'data': {
                'goal_id': goal_id,
                'average_intensity': average_intensity
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
