from flask import Blueprint, request, jsonify
from app import db
from app.models.quick_notes import QuickNotes
from datetime import datetime

quick_notes_bp = Blueprint('quick_notes', __name__)

@quick_notes_bp.route('/', methods=['GET'])
def get_quick_notes():
    """Get all quick notes"""
    try:
        notes = QuickNotes.query.order_by(QuickNotes.created_at.desc()).all()
        return jsonify({
            'success': True,
            'data': [note.to_dict() for note in notes]
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@quick_notes_bp.route('/', methods=['POST'])
def create_quick_note():
    """Create a new quick note"""
    try:
        data = request.get_json()
        
        if not data or 'content' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing content field'
            }), 400
        
        content = data['content'].strip()
        if not content:
            return jsonify({
                'success': False,
                'error': 'Content cannot be empty'
            }), 400
        
        # Create new note
        new_note = QuickNotes(content=content)
        db.session.add(new_note)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': new_note.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@quick_notes_bp.route('/<int:note_id>', methods=['PUT'])
def update_quick_note(note_id):
    """Update a quick note"""
    try:
        note = QuickNotes.query.get(note_id)
        if not note:
            return jsonify({
                'success': False,
                'error': 'Quick note not found'
            }), 404
        
        data = request.get_json()
        if not data or 'content' not in data:
            return jsonify({
                'success': False,
                'error': 'Missing content field'
            }), 400
        
        content = data['content'].strip()
        if not content:
            return jsonify({
                'success': False,
                'error': 'Content cannot be empty'
            }), 400
        
        note.content = content
        note.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': note.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@quick_notes_bp.route('/<int:note_id>', methods=['DELETE'])
def delete_quick_note(note_id):
    """Delete a quick note"""
    try:
        note = QuickNotes.query.get(note_id)
        if not note:
            return jsonify({
                'success': False,
                'error': 'Quick note not found'
            }), 404
        
        db.session.delete(note)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Quick note deleted successfully'
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
