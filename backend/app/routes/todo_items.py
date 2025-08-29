from flask import Blueprint, request, jsonify
from app import db
from app.models.todo_items import TodoItems
from datetime import datetime

todo_items_bp = Blueprint('todo_items', __name__)

@todo_items_bp.route('/', methods=['GET'])
def get_todo_items():
    """Get all todo items"""
    try:
        todos = TodoItems.query.order_by(TodoItems.created_at.desc()).all()
        return jsonify({
            'success': True,
            'data': [todo.to_dict() for todo in todos]
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@todo_items_bp.route('/', methods=['POST'])
def create_todo_item():
    """Create a new todo item"""
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
        
        # Create new todo item
        new_todo = TodoItems(content=content)
        db.session.add(new_todo)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': new_todo.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@todo_items_bp.route('/<int:todo_id>', methods=['PUT'])
def update_todo_item(todo_id):
    """Update a todo item"""
    try:
        todo = TodoItems.query.get(todo_id)
        if not todo:
            return jsonify({
                'success': False,
                'error': 'Todo item not found'
            }), 404
        
        data = request.get_json()
        
        if 'content' in data:
            content = data['content'].strip()
            if not content:
                return jsonify({
                    'success': False,
                    'error': 'Content cannot be empty'
                }), 400
            todo.content = content
        
        if 'completed' in data:
            todo.completed = bool(data['completed'])
        
        todo.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': todo.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@todo_items_bp.route('/<int:todo_id>', methods=['DELETE'])
def delete_todo_item(todo_id):
    """Delete a todo item"""
    try:
        todo = TodoItems.query.get(todo_id)
        if not todo:
            return jsonify({
                'success': False,
                'error': 'Todo item not found'
            }), 404
        
        db.session.delete(todo)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Todo item deleted successfully'
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
