from flask import Blueprint, request, jsonify
from app import db
from app.models.goal_notes import GoalNotes
from app.models.long_term_goals import LongTermGoals

goal_notes_bp = Blueprint('goal_notes', __name__, url_prefix='/api/goal-notes')

@goal_notes_bp.route('/', methods=['GET'])
def get_goal_notes():
    """Get all notes for a specific goal"""
    goal_id = request.args.get('goal_id', type=int)
    if not goal_id:
        return jsonify({'error': 'goal_id parameter is required'}), 400
    
    # Check if goal exists
    goal = LongTermGoals.query.get(goal_id)
    if not goal:
        return jsonify({'error': 'Goal not found'}), 404
    
    notes = GoalNotes.query.filter_by(goal_id=goal_id).order_by(GoalNotes.created_at.desc()).all()
    return jsonify([note.to_dict() for note in notes])

@goal_notes_bp.route('/', methods=['POST'])
def create_goal_note():
    """Create a new note for a goal"""
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    goal_id = data.get('goal_id')
    title = data.get('title')
    content = data.get('content')
    
    if not goal_id or not title or not content:
        return jsonify({'error': 'goal_id, title, and content are required'}), 400
    
    # Check if goal exists
    goal = LongTermGoals.query.get(goal_id)
    if not goal:
        return jsonify({'error': 'Goal not found'}), 404
    
    try:
        note = GoalNotes(
            goal_id=goal_id,
            title=title,
            content=content
        )
        db.session.add(note)
        db.session.commit()
        
        return jsonify(note.to_dict()), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@goal_notes_bp.route('/<int:note_id>', methods=['PUT'])
def update_goal_note(note_id):
    """Update an existing note"""
    note = GoalNotes.query.get(note_id)
    if not note:
        return jsonify({'error': 'Note not found'}), 404
    
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    try:
        if 'title' in data:
            note.title = data['title']
        if 'content' in data:
            note.content = data['content']
        
        db.session.commit()
        return jsonify(note.to_dict())
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@goal_notes_bp.route('/<int:note_id>', methods=['DELETE'])
def delete_goal_note(note_id):
    """Delete a note"""
    note = GoalNotes.query.get(note_id)
    if not note:
        return jsonify({'error': 'Note not found'}), 404
    
    try:
        db.session.delete(note)
        db.session.commit()
        return jsonify({'message': 'Note deleted successfully'})
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
