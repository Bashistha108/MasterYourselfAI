import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_yourself_ai/providers/app_state.dart';
import 'package:master_yourself_ai/models/problem.dart';
import 'package:master_yourself_ai/models/daily_problem_log.dart';

class ProblemsScreen extends StatefulWidget {
  @override
  _ProblemsScreenState createState() => _ProblemsScreenState();
}

class _ProblemsScreenState extends State<ProblemsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'general';
  Timer? _timer;

  final List<String> _categories = [
    'general',
    'health',
    'work',
    'relationships',
    'finance',
    'personal',
    'other'
  ];

  @override
  void initState() {
    super.initState();
    // Load problems when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadProblems();
    });
    
    // Start timer to update reset countdown every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild to update the countdown
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _showAddProblemDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedCategory = 'general';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Problem'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Problem Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a problem title';
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
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
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
                await context.read<AppState>().createProblem(
                  _titleController.text,
                  _descriptionController.text.isEmpty ? null : _descriptionController.text,
                  _selectedCategory,
                );
                Navigator.pop(context);
              }
            },
            child: Text('Add Problem'),
          ),
        ],
      ),
    );
  }

  void _showEditProblemDialog(Problem problem) {
    _titleController.text = problem.title;
    _descriptionController.text = problem.description ?? '';
    _selectedCategory = problem.category ?? 'general';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Problem'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Problem Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a problem title';
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
              DropdownButtonFormField<String>(
                value: _selectedCategory ?? 'general',
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
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
                await context.read<AppState>().updateProblem(
                  problem.id,
                  title: _titleController.text,
                  description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                  category: _selectedCategory,
                );
                Navigator.pop(context);
              }
            },
            child: Text('Update Problem'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Problem problem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(problem.status == 'active' ? 'Archive Problem' : 'Delete Problem'),
        content: Text(problem.status == 'active' 
            ? 'Are you sure you want to archive "${problem.title}"? It will be moved to archived problems.'
            : 'Are you sure you want to delete "${problem.title}" permanently? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AppState>().deleteProblem(problem.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(problem.status == 'active' 
                        ? 'Problem archived!' 
                        : 'Problem deleted permanently!'),
                    backgroundColor: problem.status == 'active' ? Colors.orange : Colors.red,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete problem: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: problem.status == 'active' ? Colors.orange : Colors.red),
            child: Text(problem.status == 'active' ? 'Archive' : 'Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _showIntensityDialog(Problem problem, DateTime date) {
    int selectedIntensity = 1;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Problem Intensity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How intense was "${problem.title}" today?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Text(
                      'Intensity: $selectedIntensity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: selectedIntensity == 1 ? Colors.green : 
                               selectedIntensity == 2 ? Colors.orange : Colors.red,
                      ),
                    ),
                    SizedBox(height: 16),
                    Slider(
                      value: selectedIntensity.toDouble(),
                      min: 1,
                      max: 3,
                      divisions: 2,
                      activeColor: selectedIntensity == 1 ? Colors.green : 
                                  selectedIntensity == 2 ? Colors.orange : Colors.red,
                      onChanged: (value) {
                        setState(() {
                          selectedIntensity = value.toInt();
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mild (1)', style: TextStyle(color: Colors.green)),
                        Text('Moderate (2)', style: TextStyle(color: Colors.orange)),
                        Text('Severe (3)', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ],
                );
              },
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
              try {
                await context.read<AppState>().logDailyProblem(problem.id, date, true, selectedIntensity);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Problem logged with intensity: $selectedIntensity'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to log problem: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Log Problem'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Problems'),
        actions: [
          Consumer<AppState>(
            builder: (context, appState, child) {
              if (appState.archivedProblems.isNotEmpty) {
                return IconButton(
                  icon: Icon(Icons.archive),
                  onPressed: () => _showArchivedProblems(context, appState),
                  tooltip: 'Archived Problems',
                );
              }
              return SizedBox.shrink();
            },
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
                  'My Problems (${appState.activeProblems.length} active)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: appState.problems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.track_changes_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No problems tracked yet',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add problems to track their intensity over time',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: appState.activeProblems.length,
                          itemBuilder: (context, index) {
                            final problem = appState.activeProblems[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  problem.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (problem.description != null && problem.description!.isNotEmpty)
                                      Text(
                                        problem.description!,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            (problem.category ?? 'general').toUpperCase(),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Consumer<AppState>(
                                          builder: (context, appState, child) {
                                            final now = DateTime.now();
                                            final today = DateTime(now.year, now.month, now.day);
                                            final tomorrow = today.add(Duration(days: 1));
                                            
                                            final todayLog = appState.dailyProblemLogs.firstWhere(
                                              (log) => 
                                                log.problemId == problem.id && 
                                                log.date.year == today.year &&
                                                log.date.month == today.month &&
                                                log.date.day == today.day,
                                              orElse: () => DailyProblemLog(
                                                id: 0,
                                                problemId: problem.id,
                                                date: today,
                                                faced: false,
                                                createdAt: today,
                                              ),
                                            );
                                            
                                            final isCheckedToday = todayLog.faced;
                                            final intensity = todayLog.intensity ?? 0;
                                            
                                            String statusText = isCheckedToday ? '✓ Faced today' : '☐ Not faced today';
                                            if (isCheckedToday && intensity > 0) {
                                              statusText += ' (Intensity: $intensity)';
                                            }
                                            
                                            // Add reset time info
                                            if (isCheckedToday) {
                                              final timeUntilReset = tomorrow.difference(now);
                                              final hours = timeUntilReset.inHours;
                                              final minutes = timeUntilReset.inMinutes % 60;
                                              statusText += '\nResets in ${hours}h ${minutes}m';
                                            }
                                            
                                            return Text(
                                              statusText,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: isCheckedToday ? Colors.green : Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Daily tracking button with intensity
                                    Consumer<AppState>(
                                      builder: (context, appState, child) {
                                        final now = DateTime.now();
                                        final today = DateTime(now.year, now.month, now.day);
                                        
                                        final todayLog = appState.dailyProblemLogs.firstWhere(
                                          (log) => 
                                            log.problemId == problem.id && 
                                            log.date.year == today.year &&
                                            log.date.month == today.month &&
                                            log.date.day == today.day,
                                          orElse: () => DailyProblemLog(
                                            id: 0,
                                            problemId: problem.id,
                                            date: today,
                                            faced: false,
                                            createdAt: today,
                                          ),
                                        );
                                        
                                        final isCheckedToday = todayLog.faced;
                                        final intensity = todayLog.intensity ?? 0;
                                        
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Checkbox
                                            Checkbox(
                                              value: isCheckedToday,
                                              onChanged: (bool? value) async {
                                                if (value == true) {
                                                  // Show intensity dialog when checking
                                                  _showIntensityDialog(problem, today);
                                                } else {
                                                  // Immediately uncheck and log
                                                  try {
                                                    await appState.logDailyProblem(problem.id, today, false, 0);
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Failed to uncheck problem: $e'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              activeColor: Colors.blue,
                                            ),
                                            // Intensity indicator
                                            if (isCheckedToday && intensity > 0)
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: intensity == 1 ? Colors.green : 
                                                         intensity == 2 ? Colors.orange : Colors.red,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '$intensity',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.check_circle, size: 20, color: Colors.green),
                                      onPressed: () => _showSolveConfirmation(problem),
                                      tooltip: 'Mark as Solved',
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, size: 20),
                                      onPressed: () => _showEditProblemDialog(problem),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () => _showDeleteConfirmation(problem),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showAddProblemDialog,
                    icon: Icon(Icons.add),
                    label: Text('Add Problem'),
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

  void _showSolveConfirmation(Problem problem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark Problem as Solved'),
        content: Text('Are you sure you want to mark "${problem.title}" as solved? It will be moved to solved problems history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AppState>().solveProblem(problem.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Problem marked as solved!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to solve problem: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Mark as Solved'),
          ),
        ],
      ),
    );
  }

  void _showArchivedProblems(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.archive, color: Colors.orange, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Archived Problems',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 20),
              
              // Content
              Expanded(
                child: Consumer<AppState>(
                  builder: (context, appState, child) {
                    if (appState.archivedProblems.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.archive_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No archived problems',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: appState.archivedProblems.length,
                      itemBuilder: (context, index) {
                        final problem = appState.archivedProblems[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.archive,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              problem.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (problem.description != null && problem.description!.isNotEmpty)
                                  Text(
                                    problem.description!,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (problem.category ?? 'general').toUpperCase(),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.restore, size: 20, color: Colors.blue),
                                  onPressed: () => _showRestoreArchivedConfirmation(problem),
                                  tooltip: 'Restore Problem',
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_forever, size: 20, color: Colors.red),
                                  onPressed: () => _showPermanentDeleteConfirmation(problem),
                                  tooltip: 'Delete Permanently',
                                ),
                              ],
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
    );
  }

  void _showRestoreArchivedConfirmation(Problem problem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restore Problem'),
        content: Text('Are you sure you want to restore "${problem.title}"? It will be moved back to active problems.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AppState>().restoreArchivedProblem(problem.id);
                Navigator.pop(context); // Close restore dialog
                Navigator.pop(context); // Close archive dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Problem restored successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to restore problem: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showPermanentDeleteConfirmation(Problem problem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Permanently'),
        content: Text('Are you sure you want to delete "${problem.title}" permanently? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AppState>().permanentlyDeleteProblem(problem.id);
                Navigator.pop(context); // Close delete dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Problem deleted permanently!'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete problem: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}
