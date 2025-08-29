import 'package:flutter/material.dart';

class WeekHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentWeek = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays ~/ 7 + 1;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Week History'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: currentWeek,
        itemBuilder: (context, index) {
          final weekNumber = currentWeek - index;
          final averageScore = 7 + (index % 3) + (index % 5) / 10.0;
          
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.indigo,
                  size: 20,
                ),
              ),
              title: Text(
                'Week $weekNumber',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Average Score: ${averageScore.toStringAsFixed(1)}/10',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context, 
                  '/week-analysis',
                  arguments: weekNumber,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
