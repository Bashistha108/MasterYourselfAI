from flask import Blueprint, request, jsonify
from app.models.quick_wins import QuickWins
from app import db
from datetime import datetime, date, timedelta

quick_wins_bp = Blueprint('quick_wins', __name__)

@quick_wins_bp.route('/', methods=['GET'])
def get_quick_wins():
    """Get quick wins for a specific date or today"""
    try:
        date_str = request.args.get('date')
        if date_str:
            win_date = datetime.strptime(date_str, '%Y-%m-%d').date()
        else:
            win_date = date.today()
        
        wins = QuickWins.query.filter_by(win_date=win_date).all()
        return jsonify({
            'success': True,
            'data': [win.to_dict() for win in wins],
            'date': win_date.isoformat()
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@quick_wins_bp.route('/', methods=['POST'])
def create_quick_win():
    """Create a new quick win"""
    try:
        data = request.get_json()
        
        if not data or 'title' not in data:
            return jsonify({
                'success': False,
                'error': 'Title is required'
            }), 400
        
        win = QuickWins(
            title=data['title'],
            description=data.get('description', ''),
            category=data.get('category', 'general'),
            points=data.get('points', 1)
        )
        
        db.session.add(win)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': win.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@quick_wins_bp.route('/<int:win_id>', methods=['PUT'])
def update_quick_win(win_id):
    """Update a quick win"""
    try:
        win = QuickWins.query.get_or_404(win_id)
        data = request.get_json()
        
        if 'title' in data:
            win.title = data['title']
        if 'description' in data:
            win.description = data['description']
        if 'category' in data:
            win.category = data['category']
        if 'points' in data:
            win.points = max(1, data['points'])
        if 'completed' in data:
            win.completed = data['completed']
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': win.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@quick_wins_bp.route('/<int:win_id>', methods=['DELETE'])
def delete_quick_win(win_id):
    """Delete a quick win"""
    try:
        win = QuickWins.query.get_or_404(win_id)
        db.session.delete(win)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Quick win deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@quick_wins_bp.route('/suggestions', methods=['GET'])
def get_quick_win_suggestions():
    """Get suggested quick wins based on category"""
    try:
        category = request.args.get('category', 'general')
        
        suggestions = {
            'health': [
                {'title': 'Drink 8 glasses of water', 'points': 2},
                {'title': 'Take a 20-minute walk', 'points': 3},
                {'title': 'Eat a healthy breakfast', 'points': 2},
                {'title': 'Do 10 minutes of stretching', 'points': 2},
                {'title': 'Get 8 hours of sleep', 'points': 3}
            ],
            'productivity': [
                {'title': 'Organize your workspace', 'points': 2},
                {'title': 'Create a to-do list', 'points': 1},
                {'title': 'Complete one important task', 'points': 3},
                {'title': 'Learn something new for 15 minutes', 'points': 2},
                {'title': 'Review your goals', 'points': 1}
            ],
            'wellness': [
                {'title': 'Practice 10 minutes of meditation', 'points': 3},
                {'title': 'Write down 3 things you\'re grateful for', 'points': 2},
                {'title': 'Call a friend or family member', 'points': 2},
                {'title': 'Read a book for 20 minutes', 'points': 2},
                {'title': 'Do something creative', 'points': 2}
            ],
            'general': [
                {'title': 'Make your bed', 'points': 1},
                {'title': 'Clean one area of your home', 'points': 2},
                {'title': 'Try a new recipe', 'points': 3},
                {'title': 'Listen to a podcast', 'points': 1},
                {'title': 'Write in a journal', 'points': 2}
            ]
        }
        
        return jsonify({
            'success': True,
            'data': suggestions.get(category, suggestions['general'])
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@quick_wins_bp.route('/stats', methods=['GET'])
def get_quick_win_stats():
    """Get quick win statistics"""
    try:
        # Get wins from last 7 days
        week_ago = date.today() - timedelta(days=7)
        recent_wins = QuickWins.query.filter(
            QuickWins.win_date >= week_ago
        ).all()
        
        total_wins = len(recent_wins)
        completed_wins = len([w for w in recent_wins if w.completed])
        total_points = sum(w.points for w in recent_wins if w.completed)
        
        # Category breakdown
        categories = {}
        for win in recent_wins:
            if win.completed:
                if win.category not in categories:
                    categories[win.category] = {'count': 0, 'points': 0}
                categories[win.category]['count'] += 1
                categories[win.category]['points'] += win.points
        
        return jsonify({
            'success': True,
            'data': {
                'total_wins': total_wins,
                'completed_wins': completed_wins,
                'completion_rate': round((completed_wins / total_wins * 100) if total_wins > 0 else 0, 2),
                'total_points': total_points,
                'categories': categories,
                'period_days': 7
            }
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
