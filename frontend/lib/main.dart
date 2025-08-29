import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:master_yourself_ai/providers/app_state.dart';
import 'package:master_yourself_ai/firebase_options.dart';
import 'package:master_yourself_ai/screens/dashboard_screen.dart';
import 'package:master_yourself_ai/screens/weekly_goals_screen.dart';
import 'package:master_yourself_ai/screens/long_term_goals_screen.dart';
import 'package:master_yourself_ai/screens/problems_screen.dart';
import 'package:master_yourself_ai/screens/ai_challenges_screen.dart';
import 'package:master_yourself_ai/screens/graphs_screen.dart';
import 'package:master_yourself_ai/screens/quick_wins_screen.dart';
import 'package:master_yourself_ai/screens/week_analysis_screen.dart';
import 'package:master_yourself_ai/screens/problems_analysis_screen.dart';
import 'package:master_yourself_ai/screens/future_self_analysis_screen.dart';
import 'package:master_yourself_ai/screens/ai_challenge_analysis_screen.dart';
import 'package:master_yourself_ai/screens/main_screen.dart';
import 'package:master_yourself_ai/screens/week_history_screen.dart';
import 'package:master_yourself_ai/screens/login_screen.dart';
import 'package:master_yourself_ai/screens/signup_screen.dart';
import 'package:master_yourself_ai/screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final appState = AppState();
        appState.checkAuthState(); // This is now async but we don't need to await it here
        return appState;
      },
      child: MaterialApp(
        title: '',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Color(0xFFFAFAFA),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.indigo,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(color: Colors.indigo),
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
          ),
        ),
        home: AuthWrapper(),
        routes: {
          '/dashboard': (context) => DashboardScreen(),
          '/weekly-goals': (context) => WeeklyGoalsScreen(),
          '/long-term-goals': (context) => LongTermGoalsScreen(),
          '/problems': (context) => ProblemsScreen(),
          '/ai-challenges': (context) => AIChallengesScreen(),
          '/graphs': (context) => GraphsScreen(),
          '/quick-wins': (context) => QuickWinsScreen(),
          '/week-analysis': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final weekNumber = args as int?;
            return WeekAnalysisScreen(weekNumber: weekNumber);
          },
          '/problems-analysis': (context) => ProblemsAnalysisScreen(),
          '/future-self-analysis': (context) => FutureSelfAnalysisScreen(),
          '/ai-challenge-analysis': (context) => AIChallengeAnalysisScreen(),
          '/week-history': (context) => WeekHistoryScreen(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
        },
      ),
    );
  }
}
