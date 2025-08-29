import 'package:flutter/material.dart';
import 'package:master_yourself_ai/widgets/analysis_card.dart';

class GraphsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Progress Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              children: [
                // Enhanced Header
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 24),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purple.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.4),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.analytics_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analytics Dashboard',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Track your personal growth journey',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Responsive Analytics Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    double screenHeight = MediaQuery.of(context).size.height;
                    
                    // Dynamic spacing and sizing - More aggressive for smaller screens
                    double spacing = screenWidth < 400 ? 8.0 : 12.0;
                    double cardHeight = screenHeight < 600 ? 120.0 : (screenHeight < 700 ? 130.0 : 150.0);
                    
                    return Column(
                      children: [
                        // First Row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: cardHeight,
                                margin: EdgeInsets.only(bottom: spacing),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => Navigator.pushNamed(context, '/week-analysis'),
                                                                         child: Padding(
                                       padding: EdgeInsets.all(16),
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Row(
                                             children: [
                                               Container(
                                                 padding: EdgeInsets.all(8),
                                                 decoration: BoxDecoration(
                                                   color: Colors.white.withOpacity(0.2),
                                                   borderRadius: BorderRadius.circular(10),
                                                 ),
                                                 child: Icon(
                                                   Icons.timeline,
                                                   color: Colors.white,
                                                   size: 20,
                                                 ),
                                               ),
                                               Spacer(),
                                               Icon(
                                                 Icons.arrow_forward_ios,
                                                 color: Colors.white.withOpacity(0.7),
                                                 size: 14,
                                               ),
                                             ],
                                           ),
                                           Spacer(),
                                           Text(
                                             'Week Analysis',
                                             style: TextStyle(
                                               color: Colors.white,
                                               fontSize: 16,
                                               fontWeight: FontWeight.bold,
                                             ),
                                           ),
                                           SizedBox(height: 2),
                                           Text(
                                             'Daily Progress Tracking',
                                             style: TextStyle(
                                               color: Colors.white.withOpacity(0.9),
                                               fontSize: 12,
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: spacing),
                            Expanded(
                              child: Container(
                                height: cardHeight,
                                margin: EdgeInsets.only(bottom: spacing),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [Colors.red.shade400, Colors.red.shade600],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => Navigator.pushNamed(context, '/problems-analysis'),
                                                                         child: Padding(
                                       padding: EdgeInsets.all(16),
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Row(
                                             children: [
                                               Container(
                                                 padding: EdgeInsets.all(8),
                                                 decoration: BoxDecoration(
                                                   color: Colors.white.withOpacity(0.2),
                                                   borderRadius: BorderRadius.circular(10),
                                                 ),
                                                 child: Icon(
                                                   Icons.track_changes,
                                                   color: Colors.white,
                                                   size: 20,
                                                 ),
                                               ),
                                               Spacer(),
                                               Icon(
                                                 Icons.arrow_forward_ios,
                                                 color: Colors.white.withOpacity(0.7),
                                                 size: 14,
                                               ),
                                             ],
                                           ),
                                           Spacer(),
                                           Text(
                                             'Problems Analysis',
                                             style: TextStyle(
                                               color: Colors.white,
                                               fontSize: 16,
                                               fontWeight: FontWeight.bold,
                                             ),
                                           ),
                                           SizedBox(height: 2),
                                           Text(
                                             'Issue Tracking & Trends',
                                             style: TextStyle(
                                               color: Colors.white.withOpacity(0.9),
                                               fontSize: 12,
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Second Row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: cardHeight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [Colors.green.shade400, Colors.green.shade600],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => Navigator.pushNamed(context, '/future-self-analysis'),
                                                                         child: Padding(
                                       padding: EdgeInsets.all(16),
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Row(
                                             children: [
                                               Container(
                                                 padding: EdgeInsets.all(8),
                                                 decoration: BoxDecoration(
                                                   color: Colors.white.withOpacity(0.2),
                                                   borderRadius: BorderRadius.circular(10),
                                                 ),
                                                 child: Icon(
                                                   Icons.trending_up,
                                                   color: Colors.white,
                                                   size: 20,
                                                 ),
                                               ),
                                               Spacer(),
                                               Icon(
                                                 Icons.arrow_forward_ios,
                                                 color: Colors.white.withOpacity(0.7),
                                                 size: 14,
                                               ),
                                             ],
                                           ),
                                           Spacer(),
                                           Text(
                                             'Future Self Analysis',
                                             style: TextStyle(
                                               color: Colors.white,
                                               fontSize: 16,
                                               fontWeight: FontWeight.bold,
                                             ),
                                           ),
                                           SizedBox(height: 2),
                                           Text(
                                             'Long-term Goals Progress',
                                             style: TextStyle(
                                               color: Colors.white.withOpacity(0.9),
                                               fontSize: 12,
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: spacing),
                            Expanded(
                              child: Container(
                                height: cardHeight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => Navigator.pushNamed(context, '/ai-challenge-analysis'),
                                                                         child: Padding(
                                       padding: EdgeInsets.all(16),
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Row(
                                             children: [
                                               Container(
                                                 padding: EdgeInsets.all(8),
                                                 decoration: BoxDecoration(
                                                   color: Colors.white.withOpacity(0.2),
                                                   borderRadius: BorderRadius.circular(10),
                                                 ),
                                                 child: Icon(
                                                   Icons.psychology,
                                                   color: Colors.white,
                                                   size: 20,
                                                 ),
                                               ),
                                               Spacer(),
                                               Icon(
                                                 Icons.arrow_forward_ios,
                                                 color: Colors.white.withOpacity(0.7),
                                                 size: 14,
                                               ),
                                             ],
                                           ),
                                           Spacer(),
                                           Text(
                                             'AI Challenge Analysis',
                                             style: TextStyle(
                                               color: Colors.white,
                                               fontSize: 16,
                                               fontWeight: FontWeight.bold,
                                             ),
                                           ),
                                           SizedBox(height: 2),
                                           Text(
                                             'Challenge Progress & Points',
                                             style: TextStyle(
                                               color: Colors.white.withOpacity(0.9),
                                               fontSize: 12,
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
