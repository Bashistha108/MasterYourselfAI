import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/app_state.dart';
import '../models/ai_challenge.dart';

class AIChallengeAnalysisScreen extends StatefulWidget {
  @override
  _AIChallengeAnalysisScreenState createState() => _AIChallengeAnalysisScreenState();
}

class _AIChallengeAnalysisScreenState extends State<AIChallengeAnalysisScreen> {
  Map<String, dynamic>? chartData;
  bool isLoading = true;
  int selectedDays = 30;
  bool isAggregatedByWeek = false;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  void _loadChartData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final data = await appState.getAIChallengePoints(days: selectedDays);
      
      setState(() {
        chartData = data;
        isLoading = false;
        // Check if data is aggregated by week
        isAggregatedByWeek = data['aggregated_by_week'] ?? false;
      });
    } catch (error) {
      print('Error loading AI challenge points: $error');
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading chart data: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showHistoryDialog(BuildContext context) async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final challenges = await appState.getCompletedChallengesHistory(days: selectedDays);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.history, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text('Completed Challenges History'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: challenges.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No completed challenges found',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: challenges.length,
                    itemBuilder: (context, index) {
                      final challenge = challenges[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            challenge.challengeText,
                            style: TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Completed: ${challenge.completedAt?.toString().split(' ')[0] ?? 'Unknown'}',
                                style: TextStyle(fontSize: 12),
                              ),
                              if (challenge.intensity != 0)
                                Container(
                                  margin: EdgeInsets.only(top: 4),
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getIntensityColor(challenge.intensity),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Intensity: ${challenge.intensity > 0 ? '+' : ''}${challenge.intensity}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
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
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading history: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getIntensityColor(int intensity) {
    switch (intensity) {
      case -3:
        return Colors.red.shade600;
      case -2:
        return Colors.red.shade400;
      case -1:
        return Colors.orange.shade400;
      case 0:
        return Colors.blueGrey.shade500;
      case 1:
        return Colors.lightGreen.shade600;
      case 2:
        return Colors.green.shade600;
      case 3:
        return Colors.teal.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Challenge Analytics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple.shade800,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: () => _showHistoryDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 32), // Extra bottom padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Range Selector
              Row(
                children: [
                  Text(
                    'Time Range: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  PopupMenuButton<int>(
                    onSelected: (days) {
                      setState(() {
                        selectedDays = days;
                      });
                      _loadChartData();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 7, child: Text('Last 7 days')),
                      PopupMenuItem(value: 30, child: Text('Last 30 days')),
                      PopupMenuItem(value: 90, child: Text('Last 90 days')),
                    ],
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${selectedDays} days',
                            style: TextStyle(
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.purple.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'AI Challenge Points',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Track your daily AI challenge completion progress',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Chart Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Colors.deepPurple,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Daily Points Progress',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Each completed AI challenge = 1 point',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'No completion in a day = -1 point',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      if (isLoading)
                        Container(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                            ),
                          ),
                        )
                      else if (chartData != null)
                        Container(
                          height: 300,
                          child: _hasData() 
                              ? LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: true,
                                      horizontalInterval: _getYAxisInterval(),
                                      verticalInterval: 1,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey.shade300,
                                          strokeWidth: 1,
                                        );
                                      },
                                      getDrawingVerticalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey.shade300,
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
                                          getTitlesWidget: (value, meta) {
                                            if (value == 0) {
                                              return SideTitleWidget(
                                                axisSide: meta.axisSide,
                                                child: Text(
                                                  '0',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            } else if (value.toInt() > 0 && value.toInt() <= chartData!['labels'].length) {
                                              return SideTitleWidget(
                                                axisSide: meta.axisSide,
                                                child: Text(
                                                  chartData!['labels'][value.toInt() - 1] as String,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
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
                                          interval: _getYAxisInterval(),
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              value.toInt().toString(),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            );
                                          },
                                          reservedSize: 42,
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    minX: 0,
                                    maxX: chartData!['labels'].length.toDouble(),
                                    minY: _getMinY(),
                                    maxY: _getMaxY(),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: _getSpots(),
                                        isCurved: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.purple.shade400,
                                            Colors.purple.shade200,
                                          ],
                                        ),
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter: (spot, percent, barData, index) {
                                            return FlDotCirclePainter(
                                              radius: 4,
                                              color: Colors.purple.shade600,
                                              strokeWidth: 2,
                                              strokeColor: Colors.white,
                                            );
                                          },
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.purple.shade200.withOpacity(0.3),
                                              Colors.purple.shade100.withOpacity(0.1),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                    ],
                                    extraLinesData: ExtraLinesData(
                                      horizontalLines: [
                                        HorizontalLine(
                                          y: 0,
                                          color: Colors.red.shade400,
                                          strokeWidth: 2,
                                          dashArray: [5, 5],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.psychology_outlined,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No Challenges Completed',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Complete some AI challenges to see your progress here',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                        )
                      else
                        Container(
                          height: 300,
                          child: Center(
                            child: Text(
                              'No data available',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Axis Labels
              if (chartData != null) ...[
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Y-Axis: Points',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'X-Axis: ${isAggregatedByWeek ? "Weeks" : "Days"}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              
              SizedBox(height: 24),
              
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Active Days',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              chartData != null ? 
                                (chartData!['datasets'][0]['data'] as List<dynamic>)
                                  .where((point) => (point as num) > 0)
                                  .length.toString() : '0',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Total Points',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              chartData != null ? 
                                (chartData!['datasets'][0]['data'] as List<dynamic>)
                                  .fold<int>(0, (sum, point) => sum + (point as num).toInt())
                                  .toString() : '0',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24),
              
              // Info Card
              Card(
                color: Colors.purple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 How Points Work',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Rate challenge completion from -3 to +3\n'
                        '• Negative ratings become "credits" that keep you at level 0\n'
                        '• Positive points first pay off credits before going above 0\n'
                        '• You must earn enough positive points to clear your credits',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
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
    );
  }

  double _getMaxY() {
    if (chartData == null) return 1;
    final data = chartData!['datasets'][0]['data'] as List<dynamic>;
    if (data.isEmpty) return 1;
    
    final maxPoint = data.fold<double>(0.0, (max, point) => 
        (point as num).toDouble() > max ? (point as num).toDouble() : max);
    
    // Ensure we never go below 0 and have at least 1 for visibility
    return maxPoint > 0 ? maxPoint + 1 : 1;
  }

  double _getMinY() {
    // With credit system, graph never goes below 0
    return 0;
  }

  List<FlSpot> _getSpots() {
    if (chartData == null) return [];
    
    final data = chartData!['datasets'][0]['data'] as List<dynamic>;
    final spots = <FlSpot>[];
    
    // Start from origin (0,0)
    spots.add(FlSpot(0, 0));
    
    // Add actual data points starting from x=1, ensuring no negative values
    for (int i = 0; i < data.length; i++) {
      final pointValue = (data[i] as num).toDouble();
      // Force all values to be non-negative - credit system keeps us at 0 or above
      final safeValue = pointValue < 0 ? 0.0 : pointValue;
      spots.add(FlSpot((i + 1).toDouble(), safeValue));
    }
    
    return spots;
  }

  bool _hasData() {
    if (chartData == null) return false;
    final data = chartData!['datasets'][0]['data'] as List<dynamic>;
    // Show chart if there are any data points (completed challenges)
    // Even if they result in 0 points due to credit system
    return data.isNotEmpty;
  }

  double _getYAxisInterval() {
    if (chartData == null) return 1;
    final data = chartData!['datasets'][0]['data'] as List<dynamic>;
    final minY = data.fold<double>(0.0, (min, point) => (point as num).toDouble() < min ? (point as num).toDouble() : min);
    final maxY = data.fold<double>(0.0, (max, point) => (point as num).toDouble() > max ? (point as num).toDouble() : max);

    final range = maxY - minY;
    if (range <= 10) {
      return 1;
    } else if (range <= 20) {
      return 2;
    } else if (range <= 50) {
      return 5;
    } else {
      return 10;
    }
  }
}

