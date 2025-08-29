import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_yourself_ai/providers/app_state.dart';
import 'package:master_yourself_ai/widgets/navigation_card.dart';

class ManageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            if (appState.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (appState.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error: ${appState.error}',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo.withOpacity(0.1), Colors.purple.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.settings_rounded,
                            color: Colors.indigo,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manage Your Goals',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Track and organize your personal development',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Management options
                  Text(
                    'What would you like to manage?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      NavigationCard(
                        title: 'Weekly Goals',
                        subtitle: 'Set & Track',
                        icon: Icons.flag_rounded,
                        color: Colors.blue,
                        onTap: () => Navigator.pushNamed(context, '/weekly-goals'),
                      ),
                      NavigationCard(
                        title: 'Long-term Goals',
                        subtitle: 'Future Vision',
                        icon: Icons.trending_up_rounded,
                        color: Colors.green,
                        onTap: () => Navigator.pushNamed(context, '/long-term-goals'),
                      ),
                      NavigationCard(
                        title: 'Problems',
                        subtitle: 'Track Issues',
                        icon: Icons.track_changes_rounded,
                        color: Colors.red,
                        onTap: () => Navigator.pushNamed(context, '/problems'),
                      ),
                      NavigationCard(
                        title: 'AI Challenges',
                        subtitle: 'Smart Tasks',
                        icon: Icons.psychology_rounded,
                        color: Colors.purple,
                        onTap: () => Navigator.pushNamed(context, '/ai-challenges'),
                      ),
                      NavigationCard(
                        title: 'Quick Wins',
                        subtitle: 'Small Wins',
                        icon: Icons.star_rounded,
                        color: Colors.orange,
                        onTap: () => Navigator.pushNamed(context, '/quick-wins'),
                      ),
                      NavigationCard(
                        title: 'Analytics',
                        subtitle: 'View Progress',
                        icon: Icons.analytics_rounded,
                        color: Colors.teal,
                        onTap: () => Navigator.pushNamed(context, '/graphs'),
                      ),
                    ],
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
