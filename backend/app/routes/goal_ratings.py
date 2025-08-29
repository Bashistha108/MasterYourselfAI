from flask import Blueprint, request, jsonify
from app.models.goal_ratings import GoalRatings
from app.models.weekly_goals import WeeklyGoals
from app import db
from datetime import datetime

goal_ratings_bp = Blueprint('goal_ratings', __name__)

@goal_ratings_bp.route('/', methods=['GET'])
def get_goal_ratings():
    """Get all goal ratings"""
    try:
        goal_id = request.args.get('goal_id', type=int)
        goal_type = request.args.get('goal_type')
        week = request.args.get('week')
        
        query = GoalRatings.query
        
        if goal_id:
            query = query.filter_by(goal_id=goal_id)
        if goal_type:
            query = query.filter_by(goal_type=goal_type)
        if week:
            query = query.filter_by(week=week)
        
        ratings = query.order_by(GoalRatings.created_at.desc()).all()
        
        return jsonify({
            'success': True,
            'data': [rating.to_dict() for rating in ratings]
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@goal_ratings_bp.route('/', methods=['POST'])
def create_goal_rating():
    """Create a new goal rating"""
    try:
        data = request.get_json()
        
        if not data or 'goal_id' not in data or 'goal_type' not in data or 'week' not in data or 'rating' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing required fields: goal_id, goal_type, week, rating'
            }), 400
        
        goal_id = data['goal_id']
        goal_type = data['goal_type']
        week = data['week']
        rating = data['rating']
        notes = data.get('notes')
        
        # Validate rating range
        if not (0 <= rating <= 10):
            return jsonify({
                'success': False,
                'error': 'Rating must be between 0 and 10'
            }), 400
        
        # Check if rating already exists for this goal and week
        existing_rating = GoalRatings.get_week_rating(goal_id, goal_type, week)
        if existing_rating:
            return jsonify({
                'success': False,
                'error': 'Rating already exists for this goal and week'
            }), 400
        
        # Create new rating
        new_rating = GoalRatings(
            goal_id=goal_id,
            goal_type=goal_type,
            week=week,
            rating=rating,
            notes=notes
        )
        
        db.session.add(new_rating)
        db.session.commit()
        
        # If this is a weekly goal, check and update completion status
        if goal_type == 'weekly':
            goal = WeeklyGoals.query.get(goal_id)
            if goal:
                goal.check_and_update_completion_status()
        
        return jsonify({
            'success': True,
            'data': new_rating.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@goal_ratings_bp.route('/<int:rating_id>', methods=['PUT'])
def update_goal_rating(rating_id):
    """Update a goal rating"""
    try:
        rating = GoalRatings.query.get_or_404(rating_id)
        data = request.get_json()
        
        if 'rating' in data:
            new_rating = data['rating']
            if not (0 <= new_rating <= 10):
                return jsonify({
                    'success': False,
                    'error': 'Rating must be between 0 and 10'
                }), 400
            rating.rating = new_rating
        
        if 'notes' in data:
            rating.notes = data['notes']
        
        rating.updated_at = datetime.utcnow()
        db.session.commit()
        
        # If this is a weekly goal, check and update completion status
        if rating.goal_type == 'weekly':
            goal = WeeklyGoals.query.get(rating.goal_id)
            if goal:
                goal.check_and_update_completion_status()
        
        return jsonify({
            'success': True,
            'data': rating.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@goal_ratings_bp.route('/<int:rating_id>', methods=['DELETE'])
def delete_goal_rating(rating_id):
    """Delete a goal rating"""
    try:
        rating = GoalRatings.query.get_or_404(rating_id)
        goal_id = rating.goal_id
        goal_type = rating.goal_type
        
        db.session.delete(rating)
        db.session.commit()
        
        # If this is a weekly goal, check and update completion status
        if goal_type == 'weekly':
            goal = WeeklyGoals.query.get(goal_id)
            if goal:
                goal.check_and_update_completion_status()
        
        return jsonify({
            'success': True,
            'message': 'Goal rating deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
