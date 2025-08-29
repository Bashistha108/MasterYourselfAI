import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_state.dart';

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
        return Colors.red;
      case -2:
        return Colors.orange;
      case -1:
        return Colors.yellow.shade700;
      case 0:
        return Colors.grey;
      case 1:
        return Colors.lightGreen;
      case 2:
        return Colors.green;
      case 3:
        return Colors.deepGreen;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Challenge Analysis'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: () => _showHistoryDialog(context),
            tooltip: 'View Challenge History',
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
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${selectedDays}d'),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                horizontalInterval: 1,
                                verticalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  if (value == 0) {
                                    return FlLine(
                                      color: Colors.red.shade400,
                                      strokeWidth: 2,
                                      dashArray: [5, 5],
                                    );
                                  }
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
                                    interval: selectedDays > 30 ? 7 : 1,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      final labels = chartData!['labels'] as List<dynamic>;
                                      if (labels.length > value.toInt() && value.toInt() >= 0) {
                                        final label = labels[value.toInt()] as String;
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(
                                            isAggregatedByWeek ? label : label.split('-').last, // Show week label or just day
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
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              minX: 0,
                              maxX: ((chartData!['labels'] as List<dynamic>).length - 1).toDouble(),
                              minY: _getMinY(),
                              maxY: _getMaxY(),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _getSpots(),
                                  isCurved: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.deepPurple.withOpacity(0.8),
                                      Colors.purple.withOpacity(0.8),
                                    ],
                                  ),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.deepPurple,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.deepPurple.withOpacity(0.3),
                                        Colors.purple.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
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
              if (chartData != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${(chartData!['datasets'][0]['data'] as List<dynamic>).where((point) => (point as num) > 0).length}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                              Text(
                                'Active Days',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.deepPurple,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${(chartData!['datasets'][0]['data'] as List<dynamic>).fold<int>(0, (sum, point) => sum + (point as num).toInt())}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              Text(
                                'Total Points',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              SizedBox(height: 24),
              
              // Info Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'How it works',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        '• Rate challenge intensity from -3 to +3 when completing\n'
                        '• -3 to -1: Easy/Simple challenges\n'
                        '• 0: Neutral difficulty\n'
                        '• +1 to +3: Challenging/Difficult tasks\n'
                        '• No intensity selected = -1 point\n'
                        '• Points are tracked daily and aggregated by weeks when needed\n'
                        '• The graph shows your progress over time\n'
                        '• Positive points = good performance, negative = needs improvement',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          height: 1.5,
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
    if (chartData == null) return 10;
    final data = chartData!['datasets'][0]['data'] as List<dynamic>;
    final maxPoint = data.fold<double>(-double.infinity, (max, point) => 
        (point as num).toDouble() > max ? (point as num).toDouble() : max);
    return maxPoint > 0 ? maxPoint + 1 : 1;
  }

  double _getMinY() {
    if (chartData == null) return 0;
    final data = chartData!['datasets'][0]['data'] as List<dynamic>;
    final minPoint = data.fold<double>(double.infinity, (min, point) => 
        (point as num).toDouble() < min ? (point as num).toDouble() : min);
    return minPoint < 0 ? minPoint - 1 : 0;
  }

  List<FlSpot> _getSpots() {
    if (chartData == null) return [];
    
    List<FlSpot> spots = [];
    final data = chartData!['datasets'][0]['data'] as List<dynamic>;
    print('Debug: Data length: ${data.length}');
    for (int i = 0; i < data.length; i++) {
      final point = (data[i] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), point));
      print('Debug: Point $i: $point');
    }
    print('Debug: Total spots: ${spots.length}');
    return spots;
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
