import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_yourself_ai/providers/app_state.dart';
import 'package:master_yourself_ai/models/weekly_goal.dart';

class CompletedGoalsScreen extends StatefulWidget {
  @override
  _CompletedGoalsScreenState createState() => _CompletedGoalsScreenState();
}

class _CompletedGoalsScreenState extends State<CompletedGoalsScreen> {
  @override
  void initState() {
    super.initState();
    // Load weekly goals when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadWeeklyGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Goals History'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            if (appState.completedWeeklyGoals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No Completed Goals Yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Complete some weekly goals to see them here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: appState.completedWeeklyGoals.length,
              itemBuilder: (context, index) {
                final goal = appState.completedWeeklyGoals[index];
                final weekStart = goal.weekStartDate;
                final weekEnd = goal.weekEndDate;
                final weekLabel = '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}';
                
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      goal.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Week: $weekLabel',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Rating: ${goal.rating}/10',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Completed on: ${goal.updatedAt.day}/${goal.updatedAt.month}/${goal.updatedAt.year}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.restore, size: 20, color: Colors.blue),
                          onPressed: () => _showRestoreConfirmation(goal),
                          tooltip: 'Restore Goal',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_forever, size: 20, color: Colors.red),
                          onPressed: () => _showPermanentDeleteConfirmation(goal),
                          tooltip: 'Delete Permanently',
                        ),
                      ],
                    ),
                    onTap: () {
                      _showCompletedGoalDetails(goal);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showRestoreConfirmation(WeeklyGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.restore, color: Colors.blue),
            SizedBox(width: 8),
            Text('Restore Goal'),
          ],
        ),
        content: Text('Are you sure you want to restore "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AppState>().restoreWeeklyGoal(goal.id);
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Goal restored successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context); // Close dialog
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
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Permanently'),
          ],
        ),
        content: Text('Are you sure you want to permanently delete "${goal.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AppState>().permanentlyDeleteWeeklyGoal(goal.id);
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Goal deleted permanently!'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCompletedGoalDetails(WeeklyGoal goal) {
    final weekStart = goal.weekStartDate;
    final weekEnd = goal.weekEndDate;
    final weekLabel = '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Completed Goal Details'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Week: $weekLabel'),
            Text('Rating: ${goal.rating}/10'),
            if (goal.description != null) ...[
              SizedBox(height: 8),
              Text('Description: ${goal.description}'),
            ],
            SizedBox(height: 8),
            Text(
              'Completed on: ${goal.updatedAt.day}/${goal.updatedAt.month}/${goal.updatedAt.year}',
              style: TextStyle(
                color: Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
}
