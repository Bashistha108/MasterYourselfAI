import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/long_term_goal.dart';

class FutureSelfAnalysisScreen extends StatefulWidget {
  @override
  _FutureSelfAnalysisScreenState createState() => _FutureSelfAnalysisScreenState();
}

class _FutureSelfAnalysisScreenState extends State<FutureSelfAnalysisScreen> {
  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    // Load long-term goals when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadLongTermGoals();
      context.read<AppState>().loadCompletedLongTermGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Future Self Analysis'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => _showHistoryDialog(context),
            tooltip: 'View History',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Future Self Analysis',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Track your long-term goal intensity over the past 8 weeks',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              
              // Individual Goal Charts
              Consumer<AppState>(
                builder: (context, appState, child) {
                  final activeGoals = appState.longTermGoals.where((goal) => 
                    goal.status == 'active' || goal.status == 'paused'
                  ).toList();
                  
                  if (activeGoals.isEmpty) {
                    return Container(
                      height: 200,
                      child: Card(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No active goals to display',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Create long-term goals to start tracking',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: activeGoals.asMap().entries.map((entry) {
                      final index = entry.key;
                      final goal = entry.value;
                      final color = _colors[index % _colors.length];
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 24),
                        child: _buildGoalChart(goal, color, appState),
                      );
                    }).toList(),
                  );
                },
              ),
              
              // Bottom padding to avoid navigation bar
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalChart(LongTermGoal goal, Color color, AppState appState) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Header
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: goal.status == 'active' ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    goal.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: goal.status == 'active' ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Chart
            Container(
              height: 250,
              child: Consumer<AppState>(
                builder: (context, appState, child) {
                  // Calculate dynamic X-axis range based on user's first sign-in
                  int maxWeeks = 8; // Default fallback
                  try {
                    if (appState.longTermGoals.isNotEmpty) {
                      final earliestGoalDate = appState.longTermGoals
                          .map((g) => g.createdAt)
                          .reduce((a, b) => a.isBefore(b) ? a : b);
                      
                      final firstWeekStart = earliestGoalDate.subtract(Duration(days: earliestGoalDate.weekday - 1));
                      final currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
                      final totalWeeks = currentWeekStart.difference(firstWeekStart).inDays ~/ 7;
                      maxWeeks = totalWeeks + 1;
                    }
                  } catch (e) {
                    // Keep default maxWeeks = 8
                  }
                  
                  return LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (maxWeeks + 1).toDouble(), // Account for (0,0) starting point
                      minY: 0,
                      maxY: 5.5,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final intValue = value.toInt();
                          // Skip showing 5 twice by not showing the last value
                          if (intValue == 5 && value == 5.5) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(''),
                            );
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              intValue.toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final weekIndex = value.toInt();
                          if (weekIndex > 0 && weekIndex <= maxWeeks + 1) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                'W${weekIndex - 1}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(''),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[400]!, width: 1),
                  ),
                  lineBarsData: [_getGoalChartData(goal, color, appState)],
                ),
              );
                },
              ),
            ),
            
            SizedBox(height: 12),
            
            // Current Intensity Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Intensity:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_getCurrentIntensity(goal, appState)}/5',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _getGoalChartData(LongTermGoal goal, Color color, AppState appState) {
    final data = <FlSpot>[];
    
    try {
      // Find the earliest goal creation date to determine user's first sign-in week
      final earliestGoalDate = appState.longTermGoals
          .map((g) => g.createdAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      
      // Calculate the week start of the earliest goal
      final firstWeekStart = earliestGoalDate.subtract(Duration(days: earliestGoalDate.weekday - 1));
      
      // Get current week start
      final currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      
      // Calculate total weeks from first sign-in to current week
      final totalWeeks = currentWeekStart.difference(firstWeekStart).inDays ~/ 7;
      final maxWeeks = totalWeeks + 1; // Include current week
      
      // Always start from origin (0,0)
      data.add(FlSpot(0.0, 0.0));
      
      // Find the last week with intensity > 0
      int lastIntensityWeek = -1;
      
      for (int week = 0; week <= maxWeeks; week++) {
        // Calculate the week start date for this data point
        final weekStart = firstWeekStart.add(Duration(days: week * 7));
        
        // Find intensity for this goal and week
        final intensity = appState.weeklyGoalIntensities
            .where((intensity) => intensity.goalId == goal.id &&
                                 intensity.weekStart.year == weekStart.year &&
                                 intensity.weekStart.month == weekStart.month &&
                                 intensity.weekStart.day == weekStart.day)
            .firstOrNull;
        
        final intensityValue = intensity?.intensity.toDouble() ?? 0.0;
        if (intensityValue > 0) {
          lastIntensityWeek = week;
        }
        data.add(FlSpot((week + 1).toDouble(), intensityValue.clamp(0.0, 5.0)));
      }
      
      // Remove points after the last intensity > 0
      if (lastIntensityWeek >= 0) {
        data.removeRange(lastIntensityWeek + 2, data.length);
      }
    } catch (e) {
      // Fallback: create empty data if there's an error
      data.add(FlSpot(0.0, 0.0));
      // Only add one more point to show a minimal curve
      data.add(FlSpot(1.0, 0.0));
    }
    
    return LineChartBarData(
      spots: data,
      isCurved: true,
      curveSmoothness: 0.2,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }

  int _getCurrentIntensity(LongTermGoal goal, AppState appState) {
    final currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final currentIntensity = appState.weeklyGoalIntensities
        .where((intensity) => intensity.goalId == goal.id &&
                             intensity.weekStart.year == currentWeekStart.year &&
                             intensity.weekStart.month == currentWeekStart.month &&
                             intensity.weekStart.day == currentWeekStart.day)
        .firstOrNull;
    
    return currentIntensity?.intensity ?? 0;
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<AppState>(
          builder: (context, appState, child) {
            final completedGoals = appState.completedLongTermGoals;
            
            return AlertDialog(
              title: Text('Goal History'),
              content: Container(
                width: double.maxFinite,
                height: 400,
                child: completedGoals.isEmpty
                    ? Center(
                        child: Text(
                          'No completed goals in history',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: completedGoals.length,
                        itemBuilder: (context, index) {
                          final goal = completedGoals[index];
                          return ListTile(
                            leading: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            title: Text(
                              goal.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'COMPLETED - ${_formatDate(goal.updatedAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.restore, color: Colors.blue),
                                  onPressed: () => _showRestoreConfirmation(context, goal),
                                  tooltip: 'Restore',
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_forever, color: Colors.red),
                                  onPressed: () => _showPermanentDeleteConfirmation(context, goal),
                                  tooltip: 'Delete Permanently',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showGoalHistoryChart(BuildContext context, LongTermGoal goal, AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${goal.title} - History'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 9, // Account for (0,0) starting point
                minY: 0,
                maxY: 5.5,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                                              getTitlesWidget: (double value, TitleMeta meta) {
                          final weekIndex = value.toInt();
                          if (weekIndex > 0 && weekIndex <= 9) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                'W${weekIndex - 1}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(''),
                          );
                        },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[400]!, width: 1),
                ),
                lineBarsData: [_getGoalChartData(goal, Colors.grey[600]!, appState)],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showRestoreConfirmation(BuildContext context, LongTermGoal goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                  await context.read<AppState>().restoreCompletedLongTermGoal(goal.id);
                  // Immediately reload the goals to update the UI
                  await context.read<AppState>().loadLongTermGoals();
                  await context.read<AppState>().loadCompletedLongTermGoals();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Goal restored successfully')),
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
        );
      },
    );
  }

  void _showPermanentDeleteConfirmation(BuildContext context, LongTermGoal goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Permanently'),
          content: Text('Are you sure you want to permanently delete "${goal.title}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await context.read<AppState>().permanentlyDeleteLongTermGoal(goal.id);
                  // Immediately reload the goals to update the UI
                  await context.read<AppState>().loadLongTermGoals();
                  await context.read<AppState>().loadCompletedLongTermGoals();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Goal deleted permanently')),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete Permanently'),
            ),
          ],
        );
      },
    );
  }
}
