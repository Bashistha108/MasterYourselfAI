import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_yourself_ai/providers/app_state.dart';
import 'package:master_yourself_ai/screens/login_screen.dart';
import 'package:master_yourself_ai/screens/main_screen.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('🔍 AuthWrapper: Starting auth state check...');
        context.read<AppState>().checkAuthState();
        
        // Also try to force restore session after a delay
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            print('🔍 AuthWrapper: Force checking session restoration...');
            context.read<AppState>().forceCheckAndRestoreSession();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        print('🔍 AuthWrapper: isCheckingAuth=${appState.isCheckingAuth}, isAuthenticated=${appState.isAuthenticated}');
        
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
          print('🔍 User is authenticated, showing MainScreen');
          return MainScreen();
        } else {
          print('🔍 User is NOT authenticated, showing LoginScreen');
          return LoginScreen();
        }
      },
    );
  }
}
