import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_yourself_ai/providers/app_state.dart';
import 'package:master_yourself_ai/screens/login_screen.dart';
import 'package:master_yourself_ai/screens/dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Show loading screen while checking auth state
        if (appState.isCheckingAuth) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade900,
                    Colors.blue.shade700,
                    Colors.blue.shade500,
                    Colors.purple.shade400,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.psychology,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 40),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Master Yourself AI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Initializing...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Return appropriate screen based on authentication state
        if (appState.isAuthenticated) {
          return DashboardScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
