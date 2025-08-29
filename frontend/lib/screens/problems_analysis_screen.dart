import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:master_yourself_ai/providers/app_state.dart';
import 'package:master_yourself_ai/models/problem.dart';
import 'package:master_yourself_ai/models/daily_problem_log.dart';
import 'package:master_yourself_ai/screens/solved_problems_screen.dart';

class ProblemsAnalysisScreen extends StatefulWidget {
  @override
  _ProblemsAnalysisScreenState createState() => _ProblemsAnalysisScreenState();
}

class _ProblemsAnalysisScreenState extends State<ProblemsAnalysisScreen> {
  Timer? _timer;
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  // Color scheme for problems
  final List<Color> _colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow[700]!,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];
  
  // Color coding based on intensity
  Color getIntensityColor(int value) {
    if (value == 0) return Colors.grey[400]!;
    if (value <= 2) return Colors.red;
    if (value <= 3) return Colors.orange;
    if (value <= 4) return Colors.yellow[700]!;
    return Colors.green;
  }

  @override
  void initState() {
    super.initState();
    // Load all data when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      appState.loadProblems();
      appState.loadDailyProblemLogs();
    });
    
    // Start timer to update data every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild to update the data
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Problems Analysis'),
      ),
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Problems Analysis',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                
                  // Chart
                  Consumer<AppState>(
                    builder: (context, appState, child) {
                      List<LineChartBarData> chartData = [];
                      int colorIndex = 0;
                      
                      // Get all unique dates from daily logs to determine X-axis range
                      final allDates = <DateTime>{};
                      for (final log in appState.dailyProblemLogs) {
                        allDates.add(DateTime(log.date.year, log.date.month, log.date.day));
                      }
                      
                      if (allDates.isEmpty) {
                        // If no logs, show last 7 days
                        final now = DateTime.now();
                        for (int i = 6; i >= 0; i--) {
                          allDates.add(now.subtract(Duration(days: i)));
                        }
                      }
                      
                      final sortedDates = allDates.toList()..sort();
                      final maxDays = sortedDates.length;
                      
                      // Set Y-axis range to 1, 2, 3
                      final yAxisMax = 3.0;
                      
                      // Add Problems data based on daily logs
                      if (appState.activeProblems.isNotEmpty) {
                        for (final problem in appState.activeProblems) {
                          final color = _colors[colorIndex % _colors.length];
                          colorIndex++;
                          
                          // Generate data points for each day
                          final data = <FlSpot>[];
                          
                          // Start from origin (0,0)
                          data.add(FlSpot(0.0, 0.0));
                          
                          // Find the last point with intensity > 0
                          int lastIntensityIndex = -1;
                          for (int i = 0; i < sortedDates.length; i++) {
                            final dayDate = sortedDates[i];
                            final dayLog = appState.dailyProblemLogs.firstWhere(
                              (log) => log.problemId == problem.id &&
                                       log.date.year == dayDate.year &&
                                       log.date.month == dayDate.month &&
                                       log.date.day == dayDate.day,
                              orElse: () => DailyProblemLog(
                                id: 0,
                                problemId: problem.id,
                                date: dayDate,
                                faced: false,
                                createdAt: dayDate,
                              ),
                            );
                            
                            // Use intensity if faced, otherwise 0
                            final intensity = dayLog.faced ? (dayLog.intensity ?? 1) : 0;
                            if (intensity > 0) {
                              lastIntensityIndex = i;
                            }
                            data.add(FlSpot((i + 1).toDouble(), intensity.toDouble()));
                          }
                          
                          // Remove points after the last intensity > 0
                          if (lastIntensityIndex >= 0) {
                            data.removeRange(lastIntensityIndex + 2, data.length);
                          }
                          
                          chartData.add(LineChartBarData(
                            spots: data,
                            isCurved: true,
                            curveSmoothness: 0.2,
                            color: color,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 2,
                                  color: color,
                                  strokeWidth: 1,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: false,
                            ),
                          ));
                        }
                      } else {
                        // Add sample data if no active problems
                        chartData.add(LineChartBarData(
                          spots: [
                            FlSpot(0.0, 0.0),
                            FlSpot(1.0, 1.0),
                            FlSpot(2.0, 2.0),
                            FlSpot(3.0, 3.0), // End at highest point
                          ],
                          isCurved: true,
                          curveSmoothness: 0.2,
                          color: Colors.blue,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 2,
                                color: Colors.blue,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: false,
                          ),
                        ));
                      }
                      
                      return Container(
                        height: 300,
                        child: LineChart(
                          LineChartData(
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
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    final index = value.toInt();
                                    if (index > 0 && index <= sortedDates.length) {
                                      final date = sortedDates[index - 1];
                                      final startOfYear = DateTime(date.year, 1, 1);
                                      final weekNumber = ((date.difference(startOfYear).inDays) / 7).floor() + 1;
                                      final dayOfWeek = date.weekday;
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(
                                          'W$weekNumber/$dayOfWeek',
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
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1, // Show 1, 2, 3
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
                                  reservedSize: 42,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.grey[400]!,
                                width: 1,
                              ),
                            ),
                            minX: 0,
                            maxX: maxDays.toDouble(), // Account for (0,0) starting point
                            minY: 0,
                            maxY: yAxisMax, // Use dynamic yAxisMax
                            lineBarsData: chartData,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Legend
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Consumer<AppState>(
                      builder: (context, appState, child) {
                        List<Widget> legendItems = [];
                        int colorIndex = 0;
                        
                        // Problems
                        if (appState.activeProblems.isNotEmpty) {
                          legendItems.add(
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Problems:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          );
                          
                          for (final problem in appState.activeProblems) {
                            final color = _colors[colorIndex % _colors.length];
                            colorIndex++;
                            
                            // Calculate total intensity for all tracked days
                            final allLogs = appState.dailyProblemLogs.where((log) => 
                              log.problemId == problem.id
                            ).toList();
                            
                            final totalIntensity = allLogs.fold<int>(0, (sum, log) => 
                              sum + (log.faced ? (log.intensity ?? 1) : 0)
                            );
                            
                            legendItems.add(
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        problem.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      'Total: $totalIntensity pts',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }
                        
                        if (legendItems.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No problems to display',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          );
                        }
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: legendItems,
                        );
                      },
                    ),
                  ),
                  
                  // Solved Problems Button
                  SizedBox(height: 24),
                  Consumer<AppState>(
                    builder: (context, appState, child) {
                      if (appState.solvedProblems.isNotEmpty) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SolvedProblemsScreen(),
                                ),
                              );
                            },
                            icon: Icon(Icons.check_circle, color: Colors.white),
                            label: Text('View Solved Problems (${appState.solvedProblems.length})'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }






}
