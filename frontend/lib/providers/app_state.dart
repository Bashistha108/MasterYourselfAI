import 'package:flutter/foundation.dart';
import 'package:master_yourself_ai/models/weekly_goal.dart';
import 'package:master_yourself_ai/models/long_term_goal.dart';
import 'package:master_yourself_ai/models/problem.dart';
import 'package:master_yourself_ai/models/daily_problem_log.dart';
import 'package:master_yourself_ai/models/weekly_goal_intensity.dart';
import 'package:master_yourself_ai/models/daily_goal_intensity.dart';
import 'package:master_yourself_ai/models/ai_challenge.dart';
import 'package:master_yourself_ai/models/quick_win.dart';
import 'package:master_yourself_ai/models/goal_note.dart';
import 'package:master_yourself_ai/models/quick_note.dart';
import 'package:master_yourself_ai/models/todo_item.dart';
import 'package:master_yourself_ai/models/email.dart';
import 'package:master_yourself_ai/services/api_service.dart';
import 'package:master_yourself_ai/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Added for Timer
import 'package:flutter/material.dart'; // Added for AppLifecycleState

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  
  // Data
  List<WeeklyGoal> _weeklyGoals = [];
  List<WeeklyGoal> _archivedWeeklyGoals = [];
  List<LongTermGoal> _longTermGoals = [];
  List<LongTermGoal> _completedLongTermGoals = [];
  List<LongTermGoal> _archivedLongTermGoals = [];
  List<Problem> _problems = [];
  List<DailyProblemLog> _dailyProblemLogs = [];
  List<WeeklyGoalIntensity> _weeklyGoalIntensities = [];
  List<DailyGoalIntensity> _dailyGoalIntensities = [];
  List<AIChallenge> _aiChallenges = [];
  List<QuickWin> _quickWins = [];
  List<GoalNote> _goalNotes = [];
  List<QuickNote> _quickNotes = [];
  List<TodoItem> _todoItems = [];
  List<Email> _emails = [];
  
  // Loading states
  bool _isLoading = false;
  String? _error;
  
  // Authentication state
  bool _isAuthenticated = false;
  bool _isCheckingAuth = true; // Add this to track auth checking
  String? _userEmail;
  String? _userName;
  String? _userProfilePicture;
  
  // Getters
  List<WeeklyGoal> get weeklyGoals => _weeklyGoals;
  List<WeeklyGoal> get activeWeeklyGoals => _weeklyGoals.where((goal) => !goal.completed && !goal.archived).toList();
  List<WeeklyGoal> get completedWeeklyGoals => _weeklyGoals.where((goal) => goal.completed && !goal.archived).toList();
  List<WeeklyGoal> get archivedWeeklyGoals => _archivedWeeklyGoals;
  List<LongTermGoal> get longTermGoals => _longTermGoals.where((goal) => !goal.archived).toList();
  List<LongTermGoal> get completedLongTermGoals => _completedLongTermGoals;
  List<LongTermGoal> get archivedLongTermGoals => _archivedLongTermGoals;
  List<Problem> get problems => _problems;
  List<Problem> get activeProblems => _problems.where((problem) => problem.status == 'active').toList();
  List<Problem> get solvedProblems => _problems.where((problem) => problem.status == 'resolved').toList();
  List<Problem> get archivedProblems => _problems.where((problem) => problem.status == 'archived').toList();
  List<DailyProblemLog> get dailyProblemLogs => _dailyProblemLogs;
  List<WeeklyGoalIntensity> get weeklyGoalIntensities => _weeklyGoalIntensities;
  List<DailyGoalIntensity> get dailyGoalIntensities => _dailyGoalIntensities;
  List<AIChallenge> get aiChallenges => _aiChallenges;
  List<QuickWin> get quickWins => _quickWins;
  List<GoalNote> get goalNotes => _goalNotes;
  List<QuickNote> get quickNotes => _quickNotes;
  List<TodoItem> get todoItems => _todoItems;
  List<Email> get emails => _emails;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Authentication getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userProfilePicture => _userProfilePicture;
  
  // Initialize app data
  Future<void> initializeApp() async {
    setLoading(true);
    try {
      await Future.wait([
        loadWeeklyGoals(),
        loadLongTermGoals(),
        loadArchivedLongTermGoals(),
        loadCompletedLongTermGoals(),
        loadProblems(),
        loadDailyProblemLogs(),
        loadWeeklyGoalIntensities(),
        loadQuickNotes(),
        loadTodoItems(),
        loadAIChallenges(), // Load all AI challenges instead of just today's
      ]);
      setError(null);
      
      // Start token refresh timer to prevent auto-logout
      _startTokenRefreshTimer();
      
    } catch (e) {
      setError('Failed to load app data: $e');
    } finally {
      setLoading(false);
    }
  }

  // Start token refresh timer
  void _startTokenRefreshTimer() {
    // Refresh token every 30 minutes to prevent expiration
    Timer.periodic(Duration(minutes: 30), (timer) async {
      if (_isAuthenticated && _userEmail != null) {
        try {
          print('🔍 Refreshing user token...');
          final success = await _authService.refreshUserToken();
          if (success) {
            print('✅ Token refreshed successfully');
          } else {
            print('⚠️ Token refresh failed, user may need to re-authenticate');
          }
        } catch (e) {
          print('❌ Error during token refresh: $e');
        }
      } else {
        // Stop timer if user is not authenticated
        timer.cancel();
      }
    });
  }
  
  // Weekly Goals
  Future<void> loadWeeklyGoals() async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final goals = await _apiService.getAllWeeklyGoals(_userEmail!);
      _weeklyGoals = goals;
      notifyListeners();
    } catch (e) {
      setError('Failed to load weekly goals: $e');
    }
  }
  
  Future<void> loadArchivedWeeklyGoals() async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final archivedGoals = await _apiService.getArchivedWeeklyGoals(_userEmail!);
      _archivedWeeklyGoals = archivedGoals;
      notifyListeners();
    } catch (e) {
      setError('Failed to load archived weekly goals: $e');
    }
  }
  
  Future<void> createWeeklyGoal(String title, String? description) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final goal = await _apiService.createWeeklyGoal(title, description, _userEmail!);
      _weeklyGoals.add(goal);
      notifyListeners();
    } catch (e) {
      setError('Failed to create weekly goal: $e');
    }
  }
  
  Future<void> updateWeeklyGoal(int id, {String? title, String? description, int? rating, bool? completed}) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final updatedGoal = await _apiService.updateWeeklyGoal(id, title: title, description: description, rating: rating, completed: completed, userEmail: _userEmail!);
      final index = _weeklyGoals.indexWhere((goal) => goal.id == id);
      if (index != -1) {
        // Ensure the completed status is set correctly even if API doesn't return it
        final finalGoal = completed != null ? updatedGoal.copyWith(completed: completed) : updatedGoal;
        _weeklyGoals[index] = finalGoal;
        notifyListeners();
      }
    } catch (e) {
      // Update local state even if API fails
      final index = _weeklyGoals.indexWhere((goal) => goal.id == id);
      if (index != -1) {
        final oldGoal = _weeklyGoals[index];
        _weeklyGoals[index] = oldGoal.copyWith(
          title: title,
          description: description,
          rating: rating,
          completed: completed,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    }
  }
  
  Future<void> deleteWeeklyGoal(int id) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      // Archive the goal instead of permanently deleting
      final archivedGoal = await _apiService.archiveWeeklyGoal(id, _userEmail!);
      // Remove from main goals list
      _weeklyGoals.removeWhere((goal) => goal.id == id);
      // Add to archived goals list
      _archivedWeeklyGoals.add(archivedGoal);
      notifyListeners();
    } catch (e) {
      setError('Failed to archive weekly goal: $e');
    }
  }
  
  Future<void> permanentlyDeleteWeeklyGoal(int id) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      await _apiService.deleteWeeklyGoal(id, _userEmail!);
      _weeklyGoals.removeWhere((goal) => goal.id == id);
      notifyListeners();
    } catch (e) {
      setError('Failed to permanently delete weekly goal: $e');
    }
  }
  
  Future<void> restoreWeeklyGoal(int id) async {
    try {
      // Check if we can add more goals (max 3 active per week)
      if (activeWeeklyGoals.length >= 3) {
        throw Exception('Already 3 goals active. Delete 1 to restore.');
      }
      
      // Update the goal to mark it as not completed without triggering automatic completion check
      final index = _weeklyGoals.indexWhere((goal) => goal.id == id);
      if (index != -1) {
        final oldGoal = _weeklyGoals[index];
        _weeklyGoals[index] = oldGoal.copyWith(
          completed: false,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
      
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      // Also update on the backend using the special restore endpoint
      final restoredGoal = await _apiService.restoreWeeklyGoal(id, _userEmail!);
      // Update the local state with the restored goal from backend
      final goalIndex = _weeklyGoals.indexWhere((goal) => goal.id == id);
      if (goalIndex != -1) {
        _weeklyGoals[goalIndex] = restoredGoal;
        notifyListeners();
      }
    } catch (e) {
      // Don't set error for user action errors (like 3 goals limit)
      // Only set error for system errors
      if (!e.toString().contains('Already 3 goals active')) {
        setError('Failed to restore weekly goal: $e');
      }
      throw e; // Re-throw to handle in UI
    }
  }
  
  Future<void> restoreArchivedWeeklyGoal(int id) async {
    try {
      // Check if we can add more goals (max 3 active per week)
      if (activeWeeklyGoals.length >= 3) {
        throw Exception('Already 3 goals active. Delete 1 to restore.');
      }
      
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      // Also update on the backend using the restore archived endpoint
      final restoredGoal = await _apiService.restoreArchivedWeeklyGoal(id, _userEmail!);
      // Remove from archived goals list
      _archivedWeeklyGoals.removeWhere((goal) => goal.id == id);
      // Add to main goals list
      _weeklyGoals.add(restoredGoal);
      notifyListeners();
    } catch (e) {
      // Don't set error for user action errors (like 3 goals limit)
      // Only set error for system errors
      if (!e.toString().contains('Already 3 goals active')) {
        setError('Failed to restore archived weekly goal: $e');
      }
      throw e; // Re-throw to handle in UI
    }
  }
  
  Future<void> checkAndUpdateGoalCompletion(int goalId) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final result = await _apiService.checkGoalCompletion(goalId, _userEmail!);
      final updatedGoal = WeeklyGoal.fromJson(result);
      
      // Update the goal in the local list
      final index = _weeklyGoals.indexWhere((goal) => goal.id == goalId);
      if (index != -1) {
        _weeklyGoals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to check goal completion: $e');
    }
  }
  
  Future<double> getGoalAverageRating(int goalId) async {
    try {
      return await _apiService.getGoalAverageRating(goalId);
    } catch (e) {
      setError('Failed to get goal average rating: $e');
      return 0.0;
    }
  }
  
  Future<double> getGoalAverageIntensity(int goalId) async {
    try {
      return await _apiService.getGoalAverageIntensity(goalId);
    } catch (e) {
      setError('Failed to get goal average intensity: $e');
      return 0.0;
    }
  }
  
  // Daily Goal Intensities
  Future<void> loadDailyGoalIntensities({int? goalId, String? intensityDate}) async {
    try {
      final intensities = await _apiService.getDailyGoalIntensities(goalId: goalId, intensityDate: intensityDate);
      _dailyGoalIntensities = intensities;
      notifyListeners();
    } catch (e) {
      setError('Failed to load daily goal intensities: $e');
    }
  }
  
  Future<void> createDailyGoalIntensity(int goalId, DateTime intensityDate, int intensity) async {
    try {
      final newIntensity = await _apiService.createDailyGoalIntensity(goalId, intensityDate, intensity);
      _dailyGoalIntensities.add(newIntensity);
      notifyListeners();
    } catch (e) {
      setError('Failed to create daily goal intensity: $e');
    }
  }
  
  Future<void> updateDailyGoalIntensity(int intensityId, int intensity) async {
    try {
      final updatedIntensity = await _apiService.updateDailyGoalIntensity(intensityId, intensity);
      final index = _dailyGoalIntensities.indexWhere((item) => item.id == intensityId);
      if (index != -1) {
        _dailyGoalIntensities[index] = updatedIntensity;
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to update daily goal intensity: $e');
    }
  }
  
  Future<void> deleteDailyGoalIntensity(int intensityId) async {
    try {
      await _apiService.deleteDailyGoalIntensity(intensityId);
      _dailyGoalIntensities.removeWhere((item) => item.id == intensityId);
      notifyListeners();
    } catch (e) {
      setError('Failed to delete daily goal intensity: $e');
    }
  }
  
  // Long Term Goals
  Future<void> loadLongTermGoals() async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final goals = await _apiService.getLongTermGoals(_userEmail!);
      _longTermGoals = goals;
      notifyListeners();
    } catch (e) {
      setError('Failed to load long term goals: $e');
    }
  }
  
  Future<void> createLongTermGoal(String title, String? description, DateTime? startDate, DateTime? targetDate) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final goal = await _apiService.createLongTermGoal(title, description, startDate, targetDate, _userEmail!);
      _longTermGoals.add(goal);
      notifyListeners();
    } catch (e) {
      setError('Failed to create long term goal: $e');
    }
  }
  
  Future<void> updateLongTermGoal(int id, {String? title, String? description, DateTime? startDate, DateTime? targetDate, String? status}) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final updatedGoal = await _apiService.updateLongTermGoal(id, title: title, description: description, startDate: startDate, targetDate: targetDate, status: status, userEmail: _userEmail!);
      final index = _longTermGoals.indexWhere((goal) => goal.id == id);
      if (index != -1) {
        _longTermGoals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to update long term goal: $e');
    }
  }
  
  Future<void> deleteLongTermGoal(int id) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      // Archive the goal instead of permanently deleting
      final archivedGoal = await _apiService.archiveLongTermGoal(id, _userEmail!);
      // Remove from main goals list
      _longTermGoals.removeWhere((goal) => goal.id == id);
      // Add to archived goals list
      _archivedLongTermGoals.add(archivedGoal);
      notifyListeners();
    } catch (e) {
      setError('Failed to archive long term goal: $e');
    }
  }
  
  Future<void> loadCompletedLongTermGoals() async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final goals = await _apiService.getCompletedLongTermGoals(_userEmail!);
      _completedLongTermGoals = goals;
      notifyListeners();
    } catch (e) {
      setError('Failed to load completed long term goals: $e');
    }
  }
  
  Future<void> loadArchivedLongTermGoals() async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final goals = await _apiService.getArchivedLongTermGoals(_userEmail!);
      _archivedLongTermGoals = goals;
      notifyListeners();
    } catch (e) {
      setError('Failed to load archived long term goals: $e');
    }
  }
  
  Future<void> restoreArchivedLongTermGoal(int id) async {
    try {
      // Check if we can add more goals (max 3 active)
      if (_longTermGoals.where((goal) => goal.status == 'active' && !goal.archived).length >= 3) {
        throw Exception('Already 3 goals active. Delete 1 to restore.');
      }
      
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      // Restore the goal
      final restoredGoal = await _apiService.restoreArchivedLongTermGoal(id, _userEmail!);
      // Remove from archived goals list
      _archivedLongTermGoals.removeWhere((goal) => goal.id == id);
      // Add to main goals list
      _longTermGoals.add(restoredGoal);
      notifyListeners();
    } catch (e) {
      // Don't set error for user action errors (like 3 goals limit)
      // Only set error for system errors
      if (!e.toString().contains('Already 3 goals active')) {
        setError('Failed to restore archived long term goal: $e');
      }
      throw e; // Re-throw to handle in UI
    }
  }
  
  Future<void> restoreCompletedLongTermGoal(int id) async {
    try {
      // Check if we can add more goals (max 3 active)
      if (_longTermGoals.where((goal) => goal.status == 'active' && !goal.archived).length >= 3) {
        throw Exception('Already 3 goals active. Delete 1 to restore.');
      }
      
      // Update the goal to mark it as active
      final index = _longTermGoals.indexWhere((goal) => goal.id == id);
      if (index != -1) {
        final oldGoal = _longTermGoals[index];
        _longTermGoals[index] = oldGoal.copyWith(
          status: 'active',
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
      
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      // Also update on the backend
      await _apiService.updateLongTermGoal(id, status: 'active', userEmail: _userEmail!);
    } catch (e) {
      // Don't set error for user action errors (like 3 goals limit)
      // Only set error for system errors
      if (!e.toString().contains('Already 3 goals active')) {
        setError('Failed to restore completed long term goal: $e');
      }
      throw e; // Re-throw to handle in UI
    }
  }
  
  Future<void> permanentlyDeleteLongTermGoal(int id) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      await _apiService.deleteLongTermGoal(id, _userEmail!);
      _longTermGoals.removeWhere((goal) => goal.id == id);
      _completedLongTermGoals.removeWhere((goal) => goal.id == id);
      _archivedLongTermGoals.removeWhere((goal) => goal.id == id);
      notifyListeners();
    } catch (e) {
      setError('Failed to permanently delete long term goal: $e');
    }
  }
  
  // Problems
  Future<void> loadProblems() async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final problems = await _apiService.getProblems(_userEmail!);
      _problems = problems;
      notifyListeners();
    } catch (e) {
      setError('Failed to load problems: $e');
    }
  }
  
  Future<void> createProblem(String title, String? description, String? category) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final problem = await _apiService.createProblem(title, description, category, _userEmail!);
      _problems.add(problem);
      notifyListeners();
    } catch (e) {
      setError('Failed to create problem: $e');
    }
  }
  
  Future<void> updateProblem(int id, {String? title, String? description, String? category, String? status}) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final updatedProblem = await _apiService.updateProblem(id, title: title, description: description, category: category, status: status, userEmail: _userEmail!);
      final index = _problems.indexWhere((problem) => problem.id == id);
      if (index != -1) {
        _problems[index] = updatedProblem;
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to update problem: $e');
    }
  }
  
  Future<void> deleteProblem(int id) async {
    try {
      // Find the problem to check if it's active, resolved, or archived
      final problem = _problems.firstWhere((problem) => problem.id == id);
      
      if (problem.status == 'active') {
        // If it's an active problem, archive it
        await updateProblem(id, status: 'archived');
      } else if (problem.status == 'resolved') {
        // If it's already resolved, permanently delete it
        await _apiService.deleteProblem(id, _userEmail!);
        _problems.removeWhere((problem) => problem.id == id);
      } else if (problem.status == 'archived') {
        // If it's already archived, permanently delete it
        await _apiService.deleteProblem(id, _userEmail!);
        _problems.removeWhere((problem) => problem.id == id);
      }
      notifyListeners();
    } catch (e) {
      setError('Failed to delete problem: $e');
    }
  }
  
  Future<void> solveProblem(int id) async {
    try {
      await updateProblem(id, status: 'resolved');
    } catch (e) {
      setError('Failed to solve problem: $e');
    }
  }
  
  Future<void> restoreProblem(int id) async {
    try {
      await updateProblem(id, status: 'active');
    } catch (e) {
      setError('Failed to restore problem: $e');
    }
  }
  
  Future<void> restoreArchivedProblem(int id) async {
    try {
      await updateProblem(id, status: 'active');
    } catch (e) {
      setError('Failed to restore archived problem: $e');
    }
  }
  
  Future<void> permanentlyDeleteProblem(int id) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      await _apiService.deleteProblem(id, _userEmail!);
      _problems.removeWhere((problem) => problem.id == id);
      notifyListeners();
    } catch (e) {
      setError('Failed to permanently delete problem: $e');
    }
  }
  
  Future<void> logProblemIntensity(int problemId, int intensity) async {
    try {
      await _apiService.logProblemIntensity(problemId, intensity);
      // Refresh problems to get updated data
      await loadProblems();
    } catch (e) {
      setError('Failed to log problem intensity: $e');
    }
  }
  
  // Daily Problem Logging
  Future<void> loadDailyProblemLogs() async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      print('🔄 AppState: Loading daily problem logs for user: $_userEmail');
      final logs = await _apiService.getDailyProblemLogs(userEmail: _userEmail);
      print('✅ AppState: Loaded ${logs.length} daily problem logs');
      for (var log in logs) {
        print('📋 Log: Problem ${log.problemId}, Date: ${log.date}, Faced: ${log.faced}, Intensity: ${log.intensity}');
      }
      _dailyProblemLogs = logs;
      notifyListeners();
    } catch (e) {
      print('❌ AppState: Error loading daily problem logs: $e');
      setError('Failed to load daily problem logs: $e');
    }
  }
  
  Future<void> logDailyProblem(int problemId, DateTime date, bool faced, [int intensity = 0]) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      
      final log = await _apiService.logDailyProblem(problemId, date, faced, intensity, _userEmail);
      
      // Remove existing log for this problem and date if it exists
      _dailyProblemLogs.removeWhere((existingLog) => 
        existingLog.problemId == problemId && 
        existingLog.date.year == date.year &&
        existingLog.date.month == date.month &&
        existingLog.date.day == date.day
      );
      
      // Add the new log
      if (faced) {
        _dailyProblemLogs.add(log);
      }
      
      notifyListeners();
    } catch (e) {
      setError('Failed to log daily problem: $e');
    }
  }
  
  // AI Challenges
  Future<void> loadAIChallenges() async {
    try {
      final userId = _authService.currentUser?.uid ?? '';
      print('🔄 AppState: Loading AI challenges for user: $userId');
      print('🔄 AppState: Current user: ${_authService.currentUser?.email ?? 'no email'}');
      print('🔄 AppState: Is authenticated: ${_authService.currentUser != null}');
      
      if (_userEmail == null) {
        print('⚠️ AppState: No user email available');
        _aiChallenges = [];
        notifyListeners();
        return;
      }
      
      final challenges = await _apiService.getAIChallenges(_userEmail!);
      print('✅ AppState: Received ${challenges.length} challenges from API');
      for (var challenge in challenges) {
        print('📋 Challenge: ${challenge.challengeText} (Date: ${challenge.challengeDate})');
      }
      _aiChallenges = challenges;
      notifyListeners();
    } catch (e) {
      print('❌ AppState: Error loading AI challenges: $e');
      setError('Failed to load AI challenges: $e');
    }
  }
  
  Future<void> loadTodayAIChallenge() async {
    try {
      print('🔄 AppState: Loading today\'s AI challenge for user: $_userEmail');
      if (_userEmail == null) {
        print('⚠️ AppState: No user email available');
        return;
      }
      final challenge = await _apiService.getTodayAIChallenge(_userEmail!);
      if (challenge != null) {
        print('✅ AppState: Today\'s challenge: ${challenge.challengeText}');
        // Update or add today's challenge
        final index = _aiChallenges.indexWhere((c) => c.id == challenge.id);
        if (index != -1) {
          _aiChallenges[index] = challenge;
          print('✅ AppState: Updated existing challenge at index $index');
        } else {
          _aiChallenges.add(challenge);
          print('✅ AppState: Added new challenge to list');
        }
        notifyListeners();
      } else {
        print('⚠️ AppState: No today\'s challenge found');
      }
    } catch (e) {
      print('❌ AppState: Error loading today\'s AI challenge: $e');
      setError('Failed to load today\'s AI challenge: $e');
    }
  }
  
  Future<Map<String, dynamic>> generateAIChallenge() async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final result = await _apiService.generateAIChallenge(_userEmail!);
      
      if (result['limit_reached'] == true) {
        // Limit reached, return all today's challenges
        return {
          'limit_reached': true,
          'challenges': result['challenges'],
          'message': result['message'],
        };
      } else {
        // Return the new challenge without modifying internal list
        return {
          'limit_reached': false,
          'challenge': result['challenge'],
          'remaining': result['remaining'],
        };
      }
    } catch (e) {
      setError('Failed to generate AI challenge: $e');
      throw e;
    }
  }
  
  Future<List<AIChallenge>> getTodayAIChallenges() async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      return await _apiService.getTodayAIChallenges(_userEmail!);
    } catch (e) {
      setError('Failed to load today\'s AI challenges: $e');
      throw e;
    }
  }

  Future<void> completeAIChallenge(int challengeId, {bool completed = true}) async {
    try {
      final response = await _apiService.completeAIChallenge(challengeId, completed: completed);
      
      // Update the challenge in the local list
      final index = _aiChallenges.indexWhere((challenge) => challenge.id == challengeId);
      if (index != -1) {
        _aiChallenges[index] = response;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteAIChallenge(int challengeId) async {
    try {
      await _apiService.deleteAIChallenge(challengeId);
      
      // Remove the challenge from the local list
      _aiChallenges.removeWhere((challenge) => challenge.id == challengeId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
  
  Future<Map<String, dynamic>> getAIChallengePoints({int days = 30}) async {
    try {
      return await _apiService.getAIChallengePoints(days: days);
    } catch (e) {
      setError('Failed to load AI challenge points: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> updateChallengeIntensity(int challengeId, int intensity) async {
    try {
      return await _apiService.updateChallengeIntensity(challengeId, intensity);
    } catch (e) {
      setError('Failed to update challenge intensity: $e');
      throw e;
    }
  }

  Future<List<AIChallenge>> getCompletedChallengesHistory({int days = 30}) async {
    try {
      return await _apiService.getCompletedChallengesHistory(_authService.currentUser?.uid ?? '', days: days);
    } catch (e) {
      setError('Failed to load completed challenges history: $e');
      throw e;
    }
  }
  
  // Quick Wins
  Future<void> loadQuickWins() async {
    try {
      final wins = await _apiService.getQuickWins();
      _quickWins = wins;
      notifyListeners();
    } catch (e) {
      setError('Failed to load quick wins: $e');
    }
  }
  
  Future<void> createQuickWin(String title, String? description, String? category, int points) async {
    try {
      final win = await _apiService.createQuickWin(title, description, category, points);
      _quickWins.add(win);
      notifyListeners();
    } catch (e) {
      setError('Failed to create quick win: $e');
    }
  }

  // Weekly Goal Intensities
  Future<void> loadWeeklyGoalIntensities() async {
    try {
      final intensities = await _apiService.getWeeklyGoalIntensities();
      _weeklyGoalIntensities = intensities;
      notifyListeners();
    } catch (e) {
      print('Failed to load weekly goal intensities: $e');
      // Keep existing local intensities if API fails
    }
  }
  
  Future<void> saveWeeklyGoalIntensity(int goalId, DateTime weekStart, int intensity) async {
    // Always update local state first
    final existingIndex = _weeklyGoalIntensities.indexWhere((i) => 
      i.goalId == goalId && 
      i.weekStart.year == weekStart.year &&
      i.weekStart.month == weekStart.month &&
      i.weekStart.day == weekStart.day
    );
    
    if (existingIndex != -1) {
      // Update existing local intensity
      _weeklyGoalIntensities[existingIndex] = WeeklyGoalIntensity(
        id: _weeklyGoalIntensities[existingIndex].id,
        goalId: goalId,
        weekStart: weekStart,
        intensity: intensity,
        createdAt: _weeklyGoalIntensities[existingIndex].createdAt,
        updatedAt: DateTime.now(),
      );
    } else {
      // Create new local intensity
      _weeklyGoalIntensities.add(WeeklyGoalIntensity(
        id: DateTime.now().millisecondsSinceEpoch,
        goalId: goalId,
        weekStart: weekStart,
        intensity: intensity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    notifyListeners();
    
    // Try to save to backend (but don't fail if it doesn't work)
    try {
      if (existingIndex != -1) {
        await _apiService.updateWeeklyGoalIntensity(_weeklyGoalIntensities[existingIndex].id, intensity);
      } else {
        await _apiService.createWeeklyGoalIntensity(goalId, weekStart, intensity);
      }
    } catch (e) {
      print('Failed to save weekly goal intensity to backend: $e');
      // Local state is already updated, so this is fine
    }
  }
  
  // Goal Notes
  Future<void> loadGoalNotes(int goalId) async {
    try {
      final notes = await _apiService.getGoalNotes(goalId);
      // Remove existing notes for this goal and add new ones
      _goalNotes.removeWhere((note) => note.goalId == goalId);
      _goalNotes.addAll(notes);
      notifyListeners();
    } catch (e) {
      print('Failed to load goal notes: $e');
      // Don't clear existing notes if API fails - keep local notes
    }
  }
  
  Future<void> createGoalNote(int goalId, String title, String content) async {
    try {
      final note = await _apiService.createGoalNote(goalId, title, content);
      _goalNotes.add(note);
      notifyListeners();
    } catch (e) {
      print('Failed to create goal note via API: $e');
      // If API fails, create note locally
      final localNote = GoalNote(
        id: DateTime.now().millisecondsSinceEpoch,
        goalId: goalId,
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _goalNotes.add(localNote);
      notifyListeners();
    }
  }
  
  Future<void> updateGoalNote(int noteId, {String? title, String? content}) async {
    try {
      final updatedNote = await _apiService.updateGoalNote(noteId, title: title, content: content);
      final index = _goalNotes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        _goalNotes[index] = updatedNote;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to update goal note via API: $e');
      // Update local state even if API fails
      final index = _goalNotes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        _goalNotes[index] = GoalNote(
          id: _goalNotes[index].id,
          goalId: _goalNotes[index].goalId,
          title: title ?? _goalNotes[index].title,
          content: content ?? _goalNotes[index].content,
          createdAt: _goalNotes[index].createdAt,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    }
  }
  
  Future<void> deleteGoalNote(int noteId) async {
    try {
      await _apiService.deleteGoalNote(noteId);
      _goalNotes.removeWhere((note) => note.id == noteId);
      notifyListeners();
    } catch (e) {
      print('Failed to delete goal note via API: $e');
      // Remove from local state even if API fails
      _goalNotes.removeWhere((note) => note.id == noteId);
      notifyListeners();
    }
  }
  
  // Get notes for a specific goal
  List<GoalNote> getNotesForGoal(int goalId) {
    return _goalNotes.where((note) => note.goalId == goalId).toList();
  }
  
  // Utility methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Authentication methods
  Future<bool> login(String email, String password) async {
    try {
      setLoading(true);
      
      // Use Flask backend for login instead of Firebase
      final response = await _apiService.login(email, password);
      
      if (response != null && response['success'] == true) {
        _isAuthenticated = true;
        _isCheckingAuth = false;
        _userEmail = email;
        _userName = response['user']?['display_name'] ?? email.split('@')[0];
        _userProfilePicture = null; // Flask backend doesn't have profile pictures
        
        notifyListeners();
        return true;
      } else {
        setError('Login failed: Invalid email or password');
        return false;
      }
    } catch (e) {
      setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  Future<bool> googleLogin() async {
    try {
      setLoading(true);
      print("🔄 Starting Google login process...");
      
      // Get Google ID token from Firebase
      UserCredential? result = await _authService.signInWithGoogle();
      
      if (result != null && result.user != null) {
        print("✅ Firebase Google sign-in successful for: ${result.user!.email}");
        
        // Get the ID token
        String? idToken = await result.user!.getIdToken();
        
        if (idToken != null) {
          print("✅ Got ID token from Firebase");
          
          // Send ID token to Flask backend
          final response = await _apiService.googleLogin(idToken);
          print("🔄 Backend response: $response");
          
          if (response['success'] == true) {
            _isAuthenticated = true;
            _isCheckingAuth = false;
            _userEmail = result.user!.email;
            _userName = response['user']?['display_name'] ?? result.user!.displayName ?? result.user!.email?.split('@')[0];
            _userProfilePicture = result.user!.photoURL;
            
            print("✅ Google login successful for: $_userEmail");
            notifyListeners();
            return true;
          } else {
            print("❌ Backend login failed: ${response['error'] ?? 'Unknown error'}");
            // Sign out from Firebase if backend login failed
            await _authService.signOut();
            setError('Google login failed: ${response['error'] ?? 'Unknown error'}');
            return false;
          }
        } else {
          print("❌ Failed to get Google ID token");
          await _authService.signOut();
          setError('Failed to get Google ID token');
          return false;
        }
      } else {
        print("❌ Firebase Google sign-in failed");
        return false;
      }
    } catch (e) {
      print("❌ Google login error: $e");
      // Sign out from Firebase on error
      try {
        await _authService.signOut();
      } catch (signOutError) {
        print("❌ Error signing out: $signOutError");
      }
      setError('Google login failed: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  Future<bool> signup(String name, String email, String password) async {
    try {
      setLoading(true);
      
      final response = await _apiService.signup(email, password, name);
      
      if (response['success'] == true) {
        _isAuthenticated = true;
        _isCheckingAuth = false;
        _userEmail = email;
        _userName = name;
        
        notifyListeners();
        return true;
      } else {
        setError('Signup failed: ${response['error'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      setError('Signup failed: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      setLoading(true);
      
      // Clear stored user data first
      await _authService.clearStoredUserData();
      
      // Sign out from Firebase
      await _authService.signOut();
      
      // Clear local state
      _isAuthenticated = false;
      _userEmail = null;
      _userName = null;
      _userProfilePicture = null;
      
      // Clear all app data
      _weeklyGoals.clear();
      _archivedWeeklyGoals.clear();
      _longTermGoals.clear();
      _completedLongTermGoals.clear();
      _archivedLongTermGoals.clear();
      _problems.clear();
      _dailyProblemLogs.clear();
      _weeklyGoalIntensities.clear();
      _dailyGoalIntensities.clear();
      _aiChallenges.clear();
      _quickWins.clear();
      _goalNotes.clear();
      _quickNotes.clear();
      _todoItems.clear();
      _emails.clear();
      
      notifyListeners();
      print('✅ User signed out successfully');
    } catch (e) {
      setError('Failed to sign out: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  // Check current auth state
  Future<void> checkAuthState() async {
    try {
      print('🔍 Starting auth state check...');
      
      // First, try to get stored user data from SharedPreferences
      final storedUserData = await _authService.getStoredUserData();
      final storedEmail = storedUserData['email'];
      
      // Try to get current Firebase user with token refresh
      final currentUser = await _authService.getCurrentUserWithRefresh();
      print('🔍 Current Firebase user: ${currentUser?.email ?? 'null'}');
      
      if (currentUser != null) {
        print('🔍 Firebase user is valid, using Firebase data');
        _isAuthenticated = true;
        _userEmail = currentUser.email;
        _userName = currentUser.displayName ?? currentUser.email?.split('@')[0];
        _userProfilePicture = currentUser.photoURL;
        
        // Store user data persistently
        await _authService.storeUserData(currentUser);
        
        // Initialize app data when authenticated
        await initializeApp();
      } else if (storedEmail != null && storedEmail.isNotEmpty) {
        print('🔍 No Firebase user, but found stored data: $storedEmail');
        // Check if we can restore the session
        try {
          // Try to refresh the token to see if user is still valid
          final isStillValid = await _authService.refreshUserToken();
          if (isStillValid) {
            print('🔍 Token refresh successful, user still valid');
            _isAuthenticated = true;
            _userEmail = storedEmail;
            _userName = storedUserData['name'] ?? storedEmail.split('@')[0];
            _userProfilePicture = storedUserData['photo'];
            
            await initializeApp();
          } else {
            print('🔍 Token refresh failed, clearing stored data');
            await _authService.clearStoredUserData();
            _isAuthenticated = false;
            _userEmail = null;
            _userName = null;
            _userProfilePicture = null;
          }
        } catch (e) {
          print('🔍 Error during token refresh: $e');
          // On error, try to use stored data as fallback
          _isAuthenticated = true;
          _userEmail = storedEmail;
          _userName = storedUserData['name'] ?? storedEmail.split('@')[0];
          _userProfilePicture = storedUserData['photo'];
          
          await initializeApp();
        }
      } else {
        print('🔍 No Firebase user and no stored data');
        _isAuthenticated = false;
        _userEmail = null;
        _userName = null;
        _userProfilePicture = null;
      }
      
      // Set up auth state listener for real-time changes
      _authService.authStateChanges.listen((User? user) {
        print('🔍 Auth state changed: ${user?.email ?? 'null'}');
        if (user != null) {
          _isAuthenticated = true;
          _userEmail = user.email;
          _userName = user.displayName ?? user.email?.split('@')[0];
          _userProfilePicture = user.photoURL;
          
          // Store user data persistently
          _authService.storeUserData(user);
          
          // Initialize app data when authenticated
          initializeApp();
        } else {
          // Only clear auth state if user explicitly signed out
          // Don't auto-logout on app restart
          if (_isAuthenticated) {
            print('🔍 User explicitly signed out, clearing state');
            _isAuthenticated = false;
            _userEmail = null;
            _userName = null;
            _userProfilePicture = null;
            _authService.clearStoredUserData();
          }
        }
        _isCheckingAuth = false;
        notifyListeners();
      });
      
    } catch (e) {
      print('❌ Error checking auth state: $e');
      // On error, try to use stored data as fallback
      try {
        final storedUserData = await _authService.getStoredUserData();
        final storedEmail = storedUserData['email'];
        
        if (storedEmail != null && storedEmail.isNotEmpty) {
          print('🔍 Using stored data as fallback: $storedEmail');
          _isAuthenticated = true;
          _userEmail = storedEmail;
          _userName = storedUserData['name'] ?? storedEmail.split('@')[0];
          _userProfilePicture = storedUserData['photo'];
          
          await initializeApp();
        } else {
          _isAuthenticated = false;
        }
      } catch (fallbackError) {
        print('❌ Fallback also failed: $fallbackError');
        _isAuthenticated = false;
      }
    } finally {
      _isCheckingAuth = false; // Done checking auth
      print('🔍 Auth state check completed. Authenticated: $_isAuthenticated');
      notifyListeners();
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      setLoading(true);
      final response = await _apiService.sendPasswordResetEmail(email);
      return response;
    } catch (e) {
      setError('Failed to send password reset email: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      setLoading(true);
      final response = await _apiService.resetPassword(token, newPassword);
      return response;
    } catch (e) {
      setError('Failed to reset password: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      setLoading(true);
      if (_userEmail == null) {
        throw Exception('User email not available');
      }
      
      final success = await _apiService.changePassword(_userEmail!, currentPassword, newPassword);
      if (success) {
        print('✅ Password changed successfully');
        return true;
      } else {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      setError('Failed to change password: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Check if user has email/password capability
  bool hasEmailPasswordCapability() {
    return _authService.hasEmailPasswordCapability();
  }

  // Setup password for Google user
  Future<bool> setupPasswordForGoogleUser(String email, String password) async {
    try {
      setLoading(true);
      await _authService.setupPasswordForGoogleUser(email, password);
      return true;
    } catch (e) {
      setError('Failed to setup password: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Quick Notes
  Future<void> loadQuickNotes() async {
    try {
      final notes = await _apiService.getQuickNotes();
      _quickNotes = notes;
      notifyListeners();
    } catch (e) {
      print('Failed to load quick notes: $e');
      // Keep existing local notes if API fails
    }
  }

  Future<void> createQuickNote(String content) async {
    try {
      final note = await _apiService.createQuickNote(content);
      _quickNotes.add(note);
      notifyListeners();
    } catch (e) {
      print('Failed to create quick note via API: $e');
      // Create locally if API fails
      final localNote = QuickNote(
        id: DateTime.now().millisecondsSinceEpoch,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _quickNotes.add(localNote);
      notifyListeners();
    }
  }

  Future<void> updateQuickNote(int noteId, String content) async {
    try {
      final updatedNote = await _apiService.updateQuickNote(noteId, content);
      final index = _quickNotes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        _quickNotes[index] = updatedNote;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to update quick note via API: $e');
      // Update locally if API fails
      final index = _quickNotes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        _quickNotes[index] = QuickNote(
          id: _quickNotes[index].id,
          content: content,
          createdAt: _quickNotes[index].createdAt,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    }
  }

  // Todo Items
  Future<void> loadTodoItems() async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final todos = await _apiService.getTodoItems(_userEmail!);
      _todoItems = todos;
      notifyListeners();
    } catch (e) {
      print('Failed to load todo items: $e');
      // Keep existing local todos if API fails
    }
  }

  Future<void> createTodoItem(String content) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final todo = await _apiService.createTodoItem(content, _userEmail!);
      _todoItems.add(todo);
      notifyListeners();
    } catch (e) {
      print('Failed to create todo item via API: $e');
      // Create locally if API fails
      final localTodo = TodoItem(
        id: DateTime.now().millisecondsSinceEpoch,
        content: content,
        completed: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _todoItems.add(localTodo);
      notifyListeners();
    }
  }

  Future<void> updateTodoItem(int todoId, {String? content, bool? completed}) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      final updatedTodo = await _apiService.updateTodoItem(todoId, content: content, completed: completed, userEmail: _userEmail!);
      final index = _todoItems.indexWhere((todo) => todo.id == todoId);
      if (index != -1) {
        _todoItems[index] = updatedTodo;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to update todo item via API: $e');
      // Update locally if API fails
      final index = _todoItems.indexWhere((todo) => todo.id == todoId);
      if (index != -1) {
        final oldTodo = _todoItems[index];
        _todoItems[index] = TodoItem(
          id: oldTodo.id,
          content: content ?? oldTodo.content,
          completed: completed ?? oldTodo.completed,
          createdAt: oldTodo.createdAt,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    }
  }

  Future<void> deleteTodoItem(int todoId) async {
    try {
      if (_userEmail == null) {
        throw Exception('No user email available');
      }
      await _apiService.deleteTodoItem(todoId, _userEmail!);
      _todoItems.removeWhere((todo) => todo.id == todoId);
      notifyListeners();
    } catch (e) {
      print('Failed to delete todo item via API: $e');
      // Remove locally even if API fails
      _todoItems.removeWhere((todo) => todo.id == todoId);
      notifyListeners();
    }
  }

  // Save user data to database
  Future<void> _saveUserToDatabase(User user) async {
    try {
      await _apiService.saveUserData(
        userId: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? user.email?.split('@')[0] ?? 'User',
        profilePicture: user.photoURL,
      );
    } catch (e) {
      print('Failed to save user data to database: $e');
      // Continue even if database save fails - this is expected when backend is not running
    }
  }

  // Feedback
  Future<void> submitFeedback({
    required String subject,
    required String body,
    String type = 'general',
  }) async {
    if (_userEmail == null) {
      throw Exception('User email not available');
    }
    
    try {
      await _apiService.submitFeedback(
        userEmail: _userEmail!,
        subject: subject,
        body: body,
        type: type,
      );
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  // Get emails
  Future<List<Email>> getEmails() async {
    try {
      final emails = await _apiService.getEmails(userEmail: _userEmail);
      _emails = emails;
      notifyListeners();
      return emails;
    } catch (e) {
      setError('Failed to load emails: $e');
      throw e;
    }
  }
  
  // Delete email
  Future<void> deleteEmail(String emailId) async {
    try {
      await _apiService.deleteEmail(emailId);
      _emails.removeWhere((email) => email.id == emailId);
      notifyListeners();
    } catch (e) {
      setError('Failed to delete email: $e');
      throw e;
    }
  }
  
  // Add admin reply
  Future<void> addAdminReply({
    required String subject,
    required String userEmail,
    required String content,
  }) async {
    try {
      await _apiService.addAdminReply(
        subject: subject,
        userEmail: userEmail,
        content: content,
      );
      // Refresh emails to show the new reply
      await getEmails();
    } catch (e) {
      setError('Failed to add admin reply: $e');
      throw e;
    }
  }
  
  // Handle app lifecycle changes
  void onAppLifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print('🔍 App resumed - checking auth state');
        // Refresh token when app comes back to foreground
        if (_isAuthenticated && _userEmail != null) {
          _authService.refreshUserToken();
        }
        break;
      case AppLifecycleState.inactive:
        print('🔍 App inactive');
        break;
      case AppLifecycleState.paused:
        print('🔍 App paused - storing current state');
        // Store current auth state when app goes to background
        if (_isAuthenticated && _userEmail != null) {
          // Ensure user data is stored
          _authService.getStoredUserData().then((storedData) {
            if (storedData['email'] != _userEmail) {
              // Update stored data if it's different
              print('🔍 Updating stored user data before app pause');
            }
          });
        }
        break;
      case AppLifecycleState.detached:
        print('🔍 App detached');
        break;
      case AppLifecycleState.hidden:
        print('🔍 App hidden');
        break;
    }
  }

}
