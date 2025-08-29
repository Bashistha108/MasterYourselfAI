import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_yourself_ai/providers/app_state.dart';
import 'package:master_yourself_ai/models/weekly_goal.dart';

class ArchivedGoalsScreen extends StatefulWidget {
  @override
  _ArchivedGoalsScreenState createState() => _ArchivedGoalsScreenState();
}

class _ArchivedGoalsScreenState extends State<ArchivedGoalsScreen> {
  @override
  void initState() {
    super.initState();
    // Load archived goals when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadArchivedWeeklyGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archived Goals'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (appState.archivedWeeklyGoals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No archived goals',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Archived goals will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: appState.archivedWeeklyGoals.length,
            itemBuilder: (context, index) {
              final goal = appState.archivedWeeklyGoals[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    goal.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[600],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (goal.description != null && goal.description!.isNotEmpty)
                        Text(
                          goal.description!,
                          style: TextStyle(
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      SizedBox(height: 4),
                      Text(
                        'Week: ${_formatDate(goal.weekStartDate)} - ${_formatDate(goal.weekEndDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        'Archived on: ${_formatDate(goal.updatedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.restore, color: Colors.blue),
                        onPressed: () => _showRestoreConfirmation(goal),
                        tooltip: 'Restore Goal',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _showPermanentDeleteConfirmation(goal),
                        tooltip: 'Delete Permanently',
                      ),
                    ],
                  ),
                  onTap: () => _showArchivedGoalDetails(goal),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showArchivedGoalDetails(WeeklyGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Archived Goal Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${goal.title}'),
            if (goal.description != null && goal.description!.isNotEmpty)
              Text('Description: ${goal.description}'),
            Text('Week: ${_formatDate(goal.weekStartDate)} - ${_formatDate(goal.weekEndDate)}'),
            Text('Rating: ${goal.rating}/10'),
            Text('Archived on: ${_formatDate(goal.updatedAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRestoreConfirmation(WeeklyGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restore Goal'),
        content: Text('Are you sure you want to restore "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await context.read<AppState>().restoreArchivedWeeklyGoal(goal.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Goal restored successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showPermanentDeleteConfirmation(WeeklyGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Permanently'),
        content: Text(
          'Are you sure you want to permanently delete "${goal.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await context.read<AppState>().permanentlyDeleteWeeklyGoal(goal.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Goal permanently deleted!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete goal: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}
