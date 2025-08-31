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
import 'package:master_yourself_ai/screens/mailbox_screen.dart';
import 'package:master_yourself_ai/screens/password_reset_screen.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _linkSubscription;
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinkHandling();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinkHandling() {
    // Handle initial link if app was launched from a link
    _appLinks.getInitialAppLink().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    // Handle links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      print('Deep link error: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    print('Received deep link: $uri');
    
    if (uri.scheme == 'masteryourselfai' && uri.host == 'reset-password') {
      final token = uri.queryParameters['token'];
      
      if (token != null) {
        // Navigate to password reset screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PasswordResetScreen(resetToken: token),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Master Yourself AI',
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
          '/main': (context) => MainScreen(),
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
          '/mailbox': (context) => MailboxScreen(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
        },
      ),
    );
  }
}
