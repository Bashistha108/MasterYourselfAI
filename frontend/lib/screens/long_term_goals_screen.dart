import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_yourself_ai/providers/app_state.dart';
import 'package:master_yourself_ai/models/long_term_goal.dart';
import 'package:master_yourself_ai/models/weekly_goal_intensity.dart';

import 'package:master_yourself_ai/models/goal_note.dart'; // Added import for GoalNote
import 'package:master_yourself_ai/screens/archived_long_term_goals_screen.dart';

class LongTermGoalsScreen extends StatefulWidget {
  @override
  _LongTermGoalsScreenState createState() => _LongTermGoalsScreenState();
}

class _LongTermGoalsScreenState extends State<LongTermGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedTargetDate;
  
  // State for inline note functionality
  Map<int, bool> _showNoteField = {};
  Map<int, TextEditingController> _noteControllers = {};
  int? _editingNoteId; // Track which note is being edited

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    appState.loadLongTermGoals().then((_) {
      // Load notes for all goals after goals are loaded
      for (final goal in appState.longTermGoals) {
        appState.loadGoalNotes(goal.id);
      }
    });
    appState.loadArchivedLongTermGoals();
    appState.loadCompletedLongTermGoals();
    appState.loadWeeklyGoalIntensities();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    // Dispose note controllers
    for (final controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showAddGoalDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedStartDate = null;
    _selectedTargetDate = null;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Add Long-term Goal'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Goal Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a goal title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text('Start Date (optional)'),
                    subtitle: Text(_selectedStartDate == null 
                      ? 'No date set' 
                      : '${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedStartDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          _selectedStartDate = date;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text('Target Date (optional)'),
                    subtitle: Text(_selectedTargetDate == null 
                      ? 'No date set' 
                      : '${_selectedTargetDate!.day}/${_selectedTargetDate!.month}/${_selectedTargetDate!.year}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedTargetDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          _selectedTargetDate = date;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await context.read<AppState>().createLongTermGoal(
                      _titleController.text,
                      _descriptionController.text.isEmpty ? null : _descriptionController.text,
                      _selectedStartDate,
                      _selectedTargetDate,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Add Goal'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditGoalDialog(LongTermGoal goal) {
    _titleController.text = goal.title;
    _descriptionController.text = goal.description ?? '';
    _selectedStartDate = goal.startDate;
    _selectedTargetDate = goal.targetDate;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Edit Long-term Goal'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Goal Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a goal title';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text('Start Date (optional)'),
                    subtitle: Text(_selectedStartDate == null 
                      ? 'No date set' 
                      : '${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedStartDate ?? goal.startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          _selectedStartDate = date;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text('Target Date (optional)'),
                    subtitle: Text(_selectedTargetDate == null 
                      ? 'No date set' 
                      : '${_selectedTargetDate!.day}/${_selectedTargetDate!.month}/${_selectedTargetDate!.year}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedTargetDate ?? goal.targetDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          _selectedTargetDate = date;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await context.read<AppState>().updateLongTermGoal(
                      goal.id,
                      title: _titleController.text,
                      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                      startDate: _selectedStartDate,
                      targetDate: _selectedTargetDate,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Update Goal'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(LongTermGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AppState>().deleteLongTermGoal(goal.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCompleteConfirmation(LongTermGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Goal'),
        content: Text('Are you sure you want to mark "${goal.title}" as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AppState>().updateLongTermGoal(goal.id, status: 'completed');
                // Immediately reload the goals to update the UI
                await context.read<AppState>().loadLongTermGoals();
                await context.read<AppState>().loadCompletedLongTermGoals();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Goal "${goal.title}" marked as completed!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to complete goal: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(LongTermGoal goal) {
    // Load notes for this goal
    context.read<AppState>().loadGoalNotes(goal.id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notes for "${goal.title}"'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: Consumer<AppState>(
            builder: (context, appState, child) {
              final notes = appState.getNotesForGoal(goal.id);
              
              return Column(
                children: [
                  // Add new note section
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Add New Note',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _showAddNoteDialog(goal),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Notes list
                  Expanded(
                    child: notes.isEmpty
                        ? Center(
                            child: Text(
                              'No notes yet. Click + to add a note.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: notes.length,
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(
                                    note.title,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(note.content),
                                      SizedBox(height: 4),
                                      Text(
                                        'Created: ${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditNoteDialog(note);
                                      } else if (value == 'delete') {
                                        _showDeleteNoteConfirmation(note);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(LongTermGoal goal) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Note Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Note Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                try {
                  await context.read<AppState>().createGoalNote(
                    goal.id,
                    titleController.text,
                    contentController.text,
                  );
                  Navigator.pop(context);
                } catch (e) {
                  // Simple error handling - just continue
                  Navigator.pop(context);
                }
              }
            },
            child: Text('Add Note'),
          ),
        ],
      ),
    );
  }

  void _showEditNoteDialog(GoalNote note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Note Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Note Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                try {
                  await context.read<AppState>().updateGoalNote(
                    note.id,
                    title: titleController.text,
                    content: contentController.text,
                  );
                  Navigator.pop(context);
                } catch (e) {
                  // Simple error handling - just continue
                  Navigator.pop(context);
                }
              }
            },
            child: Text('Update Note'),
          ),
        ],
      ),
    );
  }

  void _showDeleteNoteConfirmation(GoalNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppState>().deleteGoalNote(note.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensityChooser(BuildContext context, LongTermGoal goal, AppState appState) {
    // For now, use local state since backend API doesn't exist yet
    return StatefulBuilder(
      builder: (context, setState) {
        // Get current week's intensity from local state
        final currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
        final currentIntensity = appState.weeklyGoalIntensities
            .where((intensity) => intensity.goalId == goal.id && 
                                 intensity.weekStart.year == currentWeekStart.year &&
                                 intensity.weekStart.month == currentWeekStart.month &&
                                 intensity.weekStart.day == currentWeekStart.day)
            .firstOrNull;
        
        int currentValue = currentIntensity?.intensity ?? 0;
        
        // Color coding based on intensity
        Color getIntensityColor(int value) {
          if (value == 0) return Colors.grey[400]!;
          if (value <= 2) return Colors.red;
          if (value <= 3) return Colors.orange;
          if (value <= 4) return Colors.yellow[700]!;
          return Colors.green;
        }
        
        String getIntensityLabel(int value) {
          if (value == 0) return 'Not set';
          if (value <= 2) return 'Low';
          if (value <= 3) return 'Medium';
          if (value <= 4) return 'High';
          return 'Very High';
        }
        
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Intensity: $currentValue/5',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: getIntensityColor(currentValue),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getIntensityColor(currentValue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: getIntensityColor(currentValue).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    getIntensityLabel(currentValue),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: getIntensityColor(currentValue),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: getIntensityColor(currentValue),
                inactiveTrackColor: Colors.grey[300],
                thumbColor: getIntensityColor(currentValue),
                overlayColor: getIntensityColor(currentValue).withOpacity(0.2),
                valueIndicatorColor: getIntensityColor(currentValue),
                valueIndicatorTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                trackHeight: 8.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14.0),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
                mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
              ),
              child: Slider(
                value: currentValue.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: currentValue.toString(),
                onChanged: (value) {
                  final newIntensity = value.toInt();
                  
                  // Save to local state and backend
                  appState.saveWeeklyGoalIntensity(goal.id, currentWeekStart, newIntensity);
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Intensity updated to ${getIntensityLabel(newIntensity)}'),
                      backgroundColor: getIntensityColor(newIntensity),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Low',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Medium',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.yellow[700],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'High',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Very High',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Build Your Best Self'),
        actions: [
          IconButton(
            icon: Icon(Icons.archive),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArchivedLongTermGoalsScreen()),
              );
            },
            tooltip: 'Archived Goals',
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Long-term Goals (${appState.longTermGoals.length}/3)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: appState.longTermGoals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.trending_up_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No long-term goals yet',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add your first goal to build your best self',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: appState.longTermGoals.length,
                          itemBuilder: (context, index) {
                            final goal = appState.longTermGoals[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                title: Text(
                                  goal.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Status indicator
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: goal.isCompleted 
                                            ? Colors.green.withOpacity(0.1)
                                            : goal.isPaused 
                                                ? Colors.orange.withOpacity(0.1)
                                                : Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        goal.status.toUpperCase(),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: goal.isCompleted 
                                              ? Colors.green
                                              : goal.isPaused 
                                                  ? Colors.orange
                                                  : Colors.blue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    // Start date
                                    if (goal.startDate != null)
                                      Text(
                                        'Start: ${goal.startDate!.day.toString().padLeft(2, '0')}/${goal.startDate!.month.toString().padLeft(2, '0')}/${goal.startDate!.year}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    // Target date
                                    if (goal.targetDate != null)
                                      Text(
                                        'Target: ${goal.targetDate!.day.toString().padLeft(2, '0')}/${goal.targetDate!.month.toString().padLeft(2, '0')}/${goal.targetDate!.year}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    // Time remaining
                                    if (goal.timeRemainingString != null)
                                      Text(
                                        goal.timeRemainingString!,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: goal.daysRemaining! <= 7 ? Colors.red : Colors.grey[600],
                                          fontWeight: goal.daysRemaining! <= 7 ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.note_add, size: 20, color: Colors.blue),
                                      onPressed: () {
                                        setState(() {
                                          _showNoteField[goal.id] = !(_showNoteField[goal.id] ?? false);
                                          if (_showNoteField[goal.id] == true) {
                                            _noteControllers[goal.id] = TextEditingController();
                                          } else {
                                            _noteControllers[goal.id]?.dispose();
                                            _noteControllers.remove(goal.id);
                                          }
                                        });
                                      },
                                    ),
                                    if (!goal.isCompleted)
                                      IconButton(
                                        icon: Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                                        onPressed: () => _showCompleteConfirmation(goal),
                                      ),
                                    IconButton(
                                      icon: Icon(Icons.edit, size: 20),
                                      onPressed: () => _showEditGoalDialog(goal),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () => _showDeleteConfirmation(goal),
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Progress bar
                                        Container(
                                          margin: EdgeInsets.only(bottom: 16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Progress',
                                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${(goal.progressPercentage * 100).round()}%',
                                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.indigo,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  goal.startDate != null && goal.targetDate != null
                                                      ? '${goal.daysRemaining ?? 0} days remaining'
                                                      : goal.startDate == null && goal.targetDate == null
                                                          ? 'Set start and target dates to track progress'
                                                          : goal.startDate == null
                                                              ? 'Set start date to track progress'
                                                              : 'Set target date to track progress',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                LinearProgressIndicator(
                                                  value: goal.progressPercentage,
                                                  backgroundColor: Colors.grey.shade200,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    goal.progressPercentage >= 1.0 
                                                        ? Colors.green 
                                                        : goal.progressPercentage >= 0.7 
                                                            ? Colors.orange 
                                                            : Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ),
                                        
                                        // Weekly Intensity Chooser
                                        Container(
                                          margin: EdgeInsets.only(bottom: 16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'This Week\'s Intensity',
                                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Resets weekly',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.grey[500],
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              _buildIntensityChooser(context, goal, appState),
                                            ],
                                          ),
                                        ),
                                        
                                        // Inline Note Field
                                        if (_showNoteField[goal.id] == true)
                                          Container(
                                            margin: EdgeInsets.only(bottom: 16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      _editingNoteId != null ? 'Edit Note' : 'Add Note',
                                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(Icons.check, color: Colors.green),
                                                          onPressed: () async {
                                                            final noteText = _noteControllers[goal.id]?.text ?? '';
                                                            if (noteText.isNotEmpty) {
                                                              final appState = context.read<AppState>();
                                                              
                                                              if (_editingNoteId != null) {
                                                                // Update existing note
                                                                await appState.updateGoalNote(_editingNoteId!, content: noteText);
                                                              } else {
                                                                // Create new note
                                                                final existingNotes = appState.getNotesForGoal(goal.id);
                                                                final nextNumber = existingNotes.length + 1;
                                                                final autoTitle = 'Note $nextNumber';
                                                                await appState.createGoalNote(goal.id, autoTitle, noteText);
                                                              }
                                                              
                                                              await appState.loadGoalNotes(goal.id);
                                                              
                                                              setState(() {
                                                                _noteControllers[goal.id]?.clear();
                                                                _showNoteField[goal.id] = false;
                                                                _editingNoteId = null;
                                                              });
                                                            }
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: Icon(Icons.close, color: Colors.red),
                                                          onPressed: () {
                                                            setState(() {
                                                              _noteControllers[goal.id]?.clear();
                                                              _showNoteField[goal.id] = false;
                                                              _editingNoteId = null;
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                TextField(
                                                  controller: _noteControllers[goal.id],
                                                  decoration: InputDecoration(
                                                    hintText: 'Write your note here...',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ],
                                            ),
                                          ),
                                        
                                        // Display Existing Notes
                                        Consumer<AppState>(
                                          builder: (context, appState, child) {
                                            final notes = appState.getNotesForGoal(goal.id);
                                            if (notes.isNotEmpty) {
                                              return Container(
                                                margin: EdgeInsets.only(bottom: 16),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Notes (${notes.length})',
                                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    ...notes.map((note) => Card(
                                                      margin: EdgeInsets.only(bottom: 4),
                                                      child: ListTile(
                                                        title: Text(
                                                          note.title,
                                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                        ),
                                                        subtitle: Text(note.content),
                                                        trailing: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(Icons.edit, size: 16),
                                                              onPressed: () {
                                                                setState(() {
                                                                  _showNoteField[goal.id] = true;
                                                                  _noteControllers[goal.id] = TextEditingController(text: note.content);
                                                                  // Store the note being edited
                                                                  _editingNoteId = note.id;
                                                                });
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: Icon(Icons.delete, size: 16, color: Colors.red),
                                                              onPressed: () => _showDeleteNoteConfirmation(note),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )).toList(),
                                                  ],
                                                ),
                                              );
                                            }
                                            return SizedBox.shrink();
                                          },
                                        ),
                                        
                                        // Description
                                        if (goal.description != null && goal.description!.isNotEmpty)
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.all(12),
                                            margin: EdgeInsets.only(bottom: 16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.grey.shade200),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Description:',
                                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  goal.description!,
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: appState.longTermGoals.length >= 3
                        ? null
                        : _showAddGoalDialog,
                    icon: Icon(Icons.add),
                    label: Text('Create New Goal'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
