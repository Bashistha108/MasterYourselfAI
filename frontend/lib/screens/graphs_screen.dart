import 'package:flutter/material.dart';
import 'package:master_yourself_ai/widgets/analysis_card.dart';

class GraphsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Analytics'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics Dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  AnalysisCard(
                    title: 'Week Analyse',
                    subtitle: 'Daily Progress',
                    icon: Icons.timeline,
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(context, '/week-analysis'),
                  ),
                  AnalysisCard(
                    title: 'Problems Analyze',
                    subtitle: 'Issue Tracking',
                    icon: Icons.track_changes,
                    color: Colors.red,
                    onTap: () => Navigator.pushNamed(context, '/problems-analysis'),
                  ),
                  AnalysisCard(
                    title: 'Future Self Analyze',
                    subtitle: 'Long-term Goals',
                    icon: Icons.trending_up,
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(context, '/future-self-analysis'),
                  ),
                  AnalysisCard(
                    title: 'AI Challenge Analyse',
                    subtitle: 'Challenge Progress',
                    icon: Icons.psychology,
                    color: Colors.purple,
                    onTap: () => Navigator.pushNamed(context, '/ai-challenge-analysis'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
