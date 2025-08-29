import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:master_yourself_ai/providers/app_state.dart';

class QuickNoteScreen extends StatefulWidget {
  @override
  _QuickNoteScreenState createState() => _QuickNoteScreenState();
}

class _QuickNoteScreenState extends State<QuickNoteScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().loadQuickNotes();
    context.read<AppState>().loadTodoItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes + Todo'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.02,
            ),
            child: Column(
              children: [
                // Notes Container
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotesEditorScreen()),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.015),
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.note_rounded, 
                                  color: Colors.blue, 
                                  size: MediaQuery.of(context).size.width * 0.06,
                                ),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                              Flexible(
                                child: Text(
                                  'Quick Notes',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    size: MediaQuery.of(context).size.width * 0.12,
                                    color: Colors.blue.withOpacity(0.4),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                                  Flexible(
                                    child: Text(
                                      'Tap to write notes',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.04,
                                        color: Colors.blue.withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Todo Container
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TodoListScreen()),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.015),
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.checklist_rounded, 
                                  color: Colors.green, 
                                  size: MediaQuery.of(context).size.width * 0.06,
                                ),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                              Flexible(
                                child: Text(
                                  'Todo List',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.task_alt,
                                    size: MediaQuery.of(context).size.width * 0.12,
                                    color: Colors.green.withOpacity(0.4),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                                  Flexible(
                                    child: Text(
                                      'Tap to manage todos',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.04,
                                        color: Colors.green.withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotesEditorScreen extends StatefulWidget {
  @override
  _NotesEditorScreenState createState() => _NotesEditorScreenState();
}

class _NotesEditorScreenState extends State<NotesEditorScreen> {
  final TextEditingController _noteController = TextEditingController();
  Timer? _periodicTimer;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    if (appState.quickNotes.isNotEmpty) {
      _noteController.text = appState.quickNotes.first.content;
    }
    
    // Auto-save every 1 second
    _periodicTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_hasUnsavedChanges) {
        _autoSave();
        _hasUnsavedChanges = false;
      }
    });
    
    // Listen for text changes
    _noteController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _noteController.removeListener(_onTextChanged);
    _periodicTimer?.cancel();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    // Save when leaving the screen
    if (_hasUnsavedChanges) {
      _autoSave();
    }
    super.deactivate();
  }

  void _onTextChanged() {
    _hasUnsavedChanges = true;
  }

  void _autoSave() async {
    if (_noteController.text.isNotEmpty) {
      final appState = context.read<AppState>();
      if (appState.quickNotes.isNotEmpty) {
        await appState.updateQuickNote(appState.quickNotes.first.id, _noteController.text);
      } else {
        await appState.createQuickNote(_noteController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Notes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.02,
            ),
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Start typing your notes...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                height: 1.6,
                color: Colors.grey[800],
              ),
              autofocus: true,
            ),
          ),
        ),
      ),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AppState>().loadTodoItems();
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  void _addTodo() async {
    if (_todoController.text.isNotEmpty) {
      await context.read<AppState>().createTodoItem(_todoController.text);
      _todoController.clear();
    }
  }

  void _removeTodo(int todoId) async {
    await context.read<AppState>().deleteTodoItem(todoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.02,
            ),
            child: Column(
              children: [
                // Add todo input
                Container(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _todoController,
                          decoration: InputDecoration(
                            hintText: 'Add a new todo...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                          onSubmitted: (value) => _addTodo(),
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      ElevatedButton(
                        onPressed: _addTodo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.04,
                            vertical: MediaQuery.of(context).size.height * 0.015,
                          ),
                        ),
                        child: Text(
                          'Add', 
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: MediaQuery.of(context).size.width * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                // Todo list
                Expanded(
                  child: Consumer<AppState>(
                    builder: (context, appState, child) {
                      final todos = appState.todoItems;
                      return todos.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.task_alt,
                                    size: MediaQuery.of(context).size.width * 0.16,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                  Flexible(
                                    child: Text(
                                      'No todos yet!',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.045,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                                  Flexible(
                                    child: Text(
                                      'Add one above to get started',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.035,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: todos.length,
                              itemBuilder: (context, index) {
                                final todo = todos[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.015),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: false,
                                      onChanged: (value) => _removeTodo(todo.id),
                                      activeColor: Colors.green,
                                    ),
                                    title: Text(
                                      todo.content,
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.04,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: MediaQuery.of(context).size.width * 0.04, 
                                      vertical: MediaQuery.of(context).size.height * 0.005,
                                    ),
                                  ),
                                );
                              },
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
