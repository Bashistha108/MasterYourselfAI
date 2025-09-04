import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:master_yourself_ai/models/weekly_goal.dart';
import 'package:master_yourself_ai/models/long_term_goal.dart';
import 'package:master_yourself_ai/models/problem.dart';
import 'package:master_yourself_ai/models/daily_problem_log.dart';
import 'package:master_yourself_ai/models/ai_challenge.dart';
import 'package:master_yourself_ai/models/quick_win.dart';
import 'package:master_yourself_ai/models/goal_note.dart';
import 'package:master_yourself_ai/models/weekly_goal_intensity.dart';
import 'package:master_yourself_ai/models/daily_goal_intensity.dart';
import 'package:master_yourself_ai/models/quick_note.dart';
import 'package:master_yourself_ai/models/todo_item.dart';
import 'package:master_yourself_ai/models/email.dart';

class ApiService {
  // static const String baseUrl = 'http://localhost:5000/api';

  // For production
  static const String baseUrl = 'https://masteryourselfai.onrender.com/api';
  // static const String baseUrl = 'https://masteryourselfai-solve.onrender.com/api';
  // Helper method for making HTTP requests
  Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
    
    try {
      http.Response response;
      
      switch (method) {
        case 'GET':
          response = await http.get(uri).timeout(Duration(seconds: 30));
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body != null ? json.encode(body) : null,
          ).timeout(Duration(seconds: 30));
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body != null ? json.encode(body) : null,
          ).timeout(Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await http.delete(uri).timeout(Duration(seconds: 30));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
        throw Exception('Backend server is not running. Please start the Flask server first.');
      }
      throw Exception('Network error: $e');
    }
  }
  
  // Weekly Goals
  Future<List<WeeklyGoal>> getWeeklyGoals(String userEmail) async {
    final response = await _makeRequest('/weekly-goals/', queryParams: {'user_email': userEmail});
    if (response['success']) {
      return (response['data'] as List)
          .map((json) => WeeklyGoal.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load weekly goals');
  }
  
  Future<WeeklyGoal> createWeeklyGoal(String title, String? description, String userEmail) async {
    final response = await _makeRequest(
      '/weekly-goals/',
      method: 'POST',
      body: {
        'title': title,
        if (description != null) 'description': description,
        'user_email': userEmail,
      },
    );
    if (response['success']) {
      return WeeklyGoal.fromJson(response['data']);
    }
    throw Exception('Failed to create weekly goal');
  }
  
  Future<WeeklyGoal> updateWeeklyGoal(
    int id, {
    String? title,
    String? description,
    int? rating,
    bool? completed,
    required String userEmail,
  }) async {
    final body = <String, dynamic>{'user_email': userEmail};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (rating != null) body['rating'] = rating;
    if (completed != null) body['completed'] = completed;
    
    final response = await _makeRequest(
      '/weekly-goals/$id',
      method: 'PUT',
      body: body,
    );
    if (response['success']) {
      return WeeklyGoal.fromJson(response['data']);
    }
    throw Exception('Failed to update weekly goal');
  }
  
  Future<void> deleteWeeklyGoal(int id, String userEmail) async {
    final response = await _makeRequest(
      '/weekly-goals/$id',
      method: 'DELETE',
      queryParams: {'user_email': userEmail},
    );
    if (!response['success']) {
      throw Exception('Failed to delete weekly goal');
    }
  }
  
  Future<List<WeeklyGoal>> getAllWeeklyGoals(String userEmail) async {
    final response = await _makeRequest('/weekly-goals/all', queryParams: {'user_email': userEmail});
    if (response['success']) {
      return (response['data'] as List)
          .map((json) => WeeklyGoal.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load all weekly goals');
  }
  
  Future<List<WeeklyGoal>> getCompletedWeeklyGoals(String userEmail) async {
    final response = await _makeRequest('/weekly-goals/completed', queryParams: {'user_email': userEmail});
    if (response['success']) {
      return (response['data'] as List)
          .map((json) => WeeklyGoal.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load completed weekly goals');
  }
  
  Future<List<WeeklyGoal>> getArchivedWeeklyGoals(String userEmail) async {
    final response = await _makeRequest('/weekly-goals/archived', queryParams: {'user_email': userEmail});
    if (response['success']) {
      return (response['data'] as List)
          .map((json) => WeeklyGoal.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load archived weekly goals');
  }
  
  Future<Map<String, dynamic>> checkGoalCompletion(int goalId, String userEmail) async {
    final response = await _makeRequest(
      '/weekly-goals/$goalId/check-completion',
      method: 'POST',
      body: {'user_email': userEmail},
    );
    if (response['success']) {
      return response['data'];
    }
    throw Exception('Failed to check goal completion');
  }
  
  Future<WeeklyGoal> restoreWeeklyGoal(int goalId, String userEmail) async {
    final response = await _makeRequest(
      '/weekly-goals/$goalId/restore',
      method: 'POST',
      body: {'user_email': userEmail},
    );
    if (response['success']) {
      return WeeklyGoal.fromJson(response['data']);
    }
    throw Exception('Failed to restore weekly goal');
  }
  
  Future<WeeklyGoal> archiveWeeklyGoal(int goalId, String userEmail) async {
    final response = await _makeRequest(
      '/weekly-goals/$goalId/archive',
      method: 'POST',
      body: {'user_email': userEmail},
    );
    if (response['success']) {
      return WeeklyGoal.fromJson(response['data']);
    }
    throw Exception('Failed to archive weekly goal');
  }
  
  Future<WeeklyGoal> restoreArchivedWeeklyGoal(int goalId, String userEmail) async {
    final response = await _makeRequest(
      '/weekly-goals/$goalId/restore-archived',
      method: 'POST',
      body: {'user_email': userEmail},
    );
    if (response['success']) {
      return WeeklyGoal.fromJson(response['data']);
    }
    throw Exception('Failed to restore archived weekly goal');
  }
  
  Future<double> getGoalAverageRating(int goalId) async {
    final response = await _makeRequest('/weekly-goals/$goalId/average-rating');
    if (response['success']) {
      return response['data']['average_rating'].toDouble();
    }
    throw Exception('Failed to get goal average rating');
  }
  
  Future<double> getGoalAverageIntensity(int goalId) async {
    final response = await _makeRequest('/weekly-goals/$goalId/average-intensity');
    if (response['success']) {
      return response['data']['average_intensity'].toDouble();
    }
    throw Exception('Failed to get goal average intensity');
  }
  
  // Daily Goal Intensities
  Future<List<DailyGoalIntensity>> getDailyGoalIntensities({int? goalId, String? intensityDate}) async {
    final queryParams = <String, String>{};
    if (goalId != null) queryParams['goal_id'] = goalId.toString();
    if (intensityDate != null) queryParams['intensity_date'] = intensityDate;
    
    final response = await _makeRequest('/daily-goal-intensities/', queryParams: queryParams);
    if (response['success']) {
      return (response['data'] as List)
          .map((json) => DailyGoalIntensity.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load daily goal intensities');
  }
  
  Future<DailyGoalIntensity> createDailyGoalIntensity(int goalId, DateTime intensityDate, int intensity) async {
    final response = await _makeRequest(
      '/daily-goal-intensities/',
      method: 'POST',
      body: {
        'goal_id': goalId,
        'intensity_date': intensityDate.toIso8601String().split('T')[0],
        'intensity': intensity,
      },
    );
    if (response['success']) {
      return DailyGoalIntensity.fromJson(response['data']);
    }
    throw Exception('Failed to create daily goal intensity');
  }
  
  Future<DailyGoalIntensity> updateDailyGoalIntensity(int intensityId, int intensity) async {
    final response = await _makeRequest(
      '/daily-goal-intensities/$intensityId',
      method: 'PUT',
      body: {
        'intensity': intensity,
      },
    );
    if (response['success']) {
      return DailyGoalIntensity.fromJson(response['data']);
    }
    throw Exception('Failed to update daily goal intensity');
  }
  
  Future<void> deleteDailyGoalIntensity(int intensityId) async {
    final response = await _makeRequest(
      '/daily-goal-intensities/$intensityId',
      method: 'DELETE',
    );
    if (!response['success']) {
      throw Exception('Failed to delete daily goal intensity');
    }
  }
  
  // Long Term Goals
  Future<List<LongTermGoal>> getLongTermGoals(String userEmail) async {
    final response = await _makeRequest('/long-term-goals/', queryParams: {'user_email': userEmail});
    if (response['success']) {
      return (response['data'] as List)
          .map((json) => LongTermGoal.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load long term goals');
  }
  
  Future<LongTermGoal> createLongTermGoal(
    String title,
    String? description,
    DateTime? startDate,
    DateTime? targetDate,
    String userEmail,
  ) async {
    final response = await _makeRequest(
      '/long-term-goals/',
      method: 'POST',
      body: {
        'title': title,
        if (description != null) 'description': description,
        if (startDate != null) 'start_date': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
        if (targetDate != null) 'target_date': '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}',
        'user_email': userEmail,
      },
    );
    if (response['success']) {
      return LongTermGoal.fromJson(response['data']);
    }
    throw Exception('Failed to create long term goal');
  }
  
  Future<LongTermGoal> updateLongTermGoal(
    int id, {
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? targetDate,
    String? status,
    required String userEmail,
  }) async {
    final body = <String, dynamic>{'user_email': userEmail};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (startDate != null) body['start_date'] = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    if (targetDate != null) body['target_date'] = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
    if (status != null) body['status'] = status;
    
    final response = await _makeRequest(
      '/long-term-goals/$id',
      method: 'PUT',
      body: body,
    );
    if (response['success']) {
      return LongTermGoal.fromJson(response['data']);
    }
    throw Exception('Failed to update long term goal');
  }
  
  Future<void> deleteLongTermGoal(int id, String userEmail) async {
    final response = await _makeRequest(
      '/long-term-goals/$id',
      method: 'DELETE',
      queryParams: {'user_email': userEmail},
    );
    if (!response['success']) {
      throw Exception('Failed to delete long term goal');
    }
  }
  
  Future<List<LongTermGoal>> getCompletedLongTermGoals(String userEmail) async {
    final response = await _makeRequest('/long-term-goals/completed', queryParams: {'user_email': userEmail});
    if (response['success']) {
      return (response['data'] as List)
          .map((json) => LongTermGoal.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load completed long term goals');
  }
  
  Future<List<LongTermGoal>> getArchivedLongTermGoals(String userEmail) async {
    final response = await _makeRequest('/long-term-goals/archived', queryParams: {'user_email': userEmail});
    if (response['success']) {
      return (response['data'] as List)
          .map((json) => LongTermGoal.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load archived long term goals');
  }
  
  Future<LongTermGoal> archiveLongTermGoal(int id, String userEmail) async {
    final response = await _makeRequest(
      '/long-term-goals/$id/archive',
      method: 'POST',
      body: {'user_email': userEmail},
    );
    if (response['success']) {
      return LongTermGoal.fromJson(response['data']);
    }
    throw Exception('Failed to archive long term goal');
  }
  
  Future<LongTermGoal> restoreArchivedLongTermGoal(int id, String userEmail) async {
    final response = await _makeRequest(
      '/long-term-goals/$id/restore-archived',
      method: 'POST',
      body: {'user_email': userEmail},
    );
    if (response['success']) {
      return LongTermGoal.fromJson(response['data']);
    }
    throw Exception('Failed to restore archived long term goal');
  }
  
  // Problems
  Future<List<Problem>> getProblems(String userEmail) async {
    final response = await _makeRequest('/problems/', queryParams: {'user_email': userEmail});
    if (response['success']) {
      return (response['data'] as List)
          .map((json) => Problem.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load problems');
  }
  
  Future<Problem> createProblem(
    String title,
    String? description,
    String? category,
    String userEmail,
  ) async {
    final response = await _makeRequest(
      '/problems/',
      method: 'POST',
      body: {
        'title': title,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        'user_email': userEmail,
      },
    );
    if (response['success']) {
      return Problem.fromJson(response['data']);
    }
    throw Exception('Failed to create problem');
  }
  
  Future<Problem> updateProblem(
    int id, {
    String? title,
    String? description,
    String? category,
    String? status,
    required String userEmail,
  }) async {
    final body = <String, dynamic>{'user_email': userEmail};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (category != null) body['category'] = category;
    if (status != null) body['status'] = status;
    
    final response = await _makeRequest(
      '/problems/$id',
      method: 'PUT',
      body: body,
    );
    if (response['success']) {
      return Problem.fromJson(response['data']);
    }
    throw Exception('Failed to update problem');
  }
  
  Future<void> deleteProblem(int id, String userEmail) async {
    final response = await _makeRequest(
      '/problems/$id',
      method: 'DELETE',
      queryParams: {'user_email': userEmail},
    );
    if (!response['success']) {
      throw Exception('Failed to delete problem');
    }
  }
  
  Future<void> logProblemIntensity(int problemId, int intensity) async {
    final response = await _makeRequest(
      '/problems/$problemId/log',
      method: 'POST',
      body: {
        'intensity': intensity,
        'date': DateTime.now().toIso8601String(),
      },
    );
    if (!response['success']) {
      throw Exception('Failed to log problem intensity');
    }
  }
  
  // Daily Problem Logging
  Future<List<DailyProblemLog>> getDailyProblemLogs({String? userEmail}) async {
    print('🔄 API: Getting daily problem logs for user: $userEmail');
    final queryParams = <String, String>{};
    if (userEmail != null) {
      queryParams['user_email'] = userEmail;
    }
    
    final response = await _makeRequest('/problems/logs', queryParams: queryParams);
    print('✅ API: Daily problem logs response: ${response['success']} with ${response['data']?.length ?? 0} logs');
    if (response['success']) {
      final logs = (response['data'] as List)
          .map((json) => DailyProblemLog.fromJson(json))
          .toList();
      print('✅ API: Parsed ${logs.length} daily problem logs');
      for (var log in logs) {
        print('📋 API Log: Problem ${log.problemId}, Date: ${log.date}, Faced: ${log.faced}');
      }
      return logs;
    }
    throw Exception('Failed to load daily problem logs');
  }
  
  Future<DailyProblemLog> logDailyProblem(int problemId, DateTime date, bool faced, [int intensity = 0, String? userEmail]) async {
    final body = {
      'problem_id': problemId,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'faced': faced,
      'intensity': intensity,
    };
    
    if (userEmail != null) {
      body['user_email'] = userEmail;
    }
    
    final response = await _makeRequest(
      '/problems/logs',
      method: 'POST',
      body: body,
    );
    if (response['success']) {
      return DailyProblemLog.fromJson(response['data']);
    }
    throw Exception('Failed to log daily problem');
  }
  
  // AI Challenges
  Future<List<AIChallenge>> getAIChallenges(String userEmail) async {
    print('🔄 API: Getting AI challenges for user: $userEmail');
    final response = await _makeRequest('/ai-challenges/', queryParams: {'user_email': userEmail});
    print('✅ API: Received response: ${response['success']} with ${response['data']?.length ?? 0} challenges');
    if (response['success']) {
      final challenges = (response['data'] as List)
          .map((json) => AIChallenge.fromJson(json))
          .toList();
      print('✅ API: Parsed ${challenges.length} challenges');
      return challenges;
    }
    throw Exception('Failed to load AI challenges');
  }
  
  Future<AIChallenge?> getTodayAIChallenge(String userEmail) async {
    print('🔄 API: Getting today\'s AI challenge for user: $userEmail');
    final response = await _makeRequest('/ai-challenges/today', queryParams: {'user_email': userEmail});
    print('✅ API: Today\'s challenge response: ${response['success']}');
    if (response['success']) {
      if (response['data'] != null) {
        final challenge = AIChallenge.fromJson(response['data']);
        print('✅ API: Today\'s challenge: ${challenge.challengeText}');
        return challenge;
      } else {
        print('⚠️ API: No today\'s challenge data');
        return null;
      }
    }
    throw Exception('Failed to load today\'s AI challenge');
  }
  
  Future<List<AIChallenge>> getTodayAIChallenges(String userEmail) async {
    print('🔄 API: Getting today\'s AI challenges for user: $userEmail');
    final response = await _makeRequest('/ai-challenges/today-challenges', queryParams: {'user_email': userEmail});
    print('✅ API: Today\'s challenges response: ${response['success']} with ${response['data']?.length ?? 0} challenges');
    if (response['success']) {
      final challenges = (response['data'] as List)
          .map((json) => AIChallenge.fromJson(json))
          .toList();
      print('✅ API: Parsed ${challenges.length} today\'s challenges');
      return challenges;
    }
    throw Exception('Failed to load today\'s AI challenges');
  }
  
  Future<Map<String, dynamic>> generateAIChallenge(String userEmail) async {
    final response = await _makeRequest(
      '/ai-challenges/generate',
      method: 'POST',
      body: {'user_email': userEmail},
    );
    if (response['success']) {
      if (response['limit_reached'] == true) {
        // Return all today's challenges when limit is reached
        final challenges = (response['data'] as List)
            .map((json) => AIChallenge.fromJson(json))
            .toList();
        return {
          'limit_reached': true,
          'challenges': challenges,
          'message': response['message'],
        };
      } else {
        // Return single challenge when limit not reached
        return {
          'limit_reached': false,
          'challenge': AIChallenge.fromJson(response['data']),
          'remaining': response['remaining'],
        };
      }
    }
    throw Exception('Failed to generate AI challenge');
  }
  
  Future<AIChallenge> completeAIChallenge(int id, {bool completed = true}) async {
    final response = await _makeRequest(
      '/ai-challenges/$id/complete',
      method: 'PUT',
      body: {
        'completed': completed,
      },
    );
    return AIChallenge.fromJson(response['data']);
  }

  Future<void> deleteAIChallenge(int id) async {
    await _makeRequest(
      '/ai-challenges/$id',
      method: 'DELETE',
    );
  }
  
  Future<Map<String, dynamic>> updateChallengeIntensity(int challengeId, int intensity) async {
    final response = await _makeRequest('/ai-challenges/$challengeId/intensity', 
        method: 'PUT', 
        body: {'intensity': intensity});
    if (response['success']) {
      return response['data'];
    }
    throw Exception('Failed to update challenge intensity');
  }

  Future<List<AIChallenge>> getCompletedChallengesHistory(String userId, {int days = 30}) async {
    final response = await _makeRequest('/ai-challenges/completed-history', 
        queryParams: {'user_id': userId, 'days': days.toString()});
    if (response['success']) {
      return (response['data'] as List)
          .map((json) => AIChallenge.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load completed challenges history');
  }
  
  // Quick Wins
  Future<List<QuickWin>> getQuickWins() async {
    final response = await _makeRequest('/quick-wins/');
    if (response['success']) {
      return (response['data'] as List)
          .map((json) => QuickWin.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load quick wins');
  }
  
  Future<QuickWin> createQuickWin(
    String title,
    String? description,
    String? category,
    int points,
  ) async {
    final response = await _makeRequest(
      '/quick-wins/',
      method: 'POST',
      body: {
        'title': title,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        'points': points,
      },
    );
    if (response['success']) {
      return QuickWin.fromJson(response['data']);
    }
    throw Exception('Failed to create quick win');
  }
  
  Future<QuickWin> updateQuickWin(
    int id, {
    String? title,
    String? description,
    String? category,
    int? points,
    bool? completed,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (category != null) body['category'] = category;
    if (points != null) body['points'] = points;
    if (completed != null) body['completed'] = completed;
    
    final response = await _makeRequest(
      '/quick-wins/$id',
      method: 'PUT',
      body: body,
    );
    if (response['success']) {
      return QuickWin.fromJson(response['data']);
    }
    throw Exception('Failed to update quick win');
  }
  
  // Graphs/Analytics
  Future<Map<String, dynamic>> getWeeklyGoalsProgress({int weeks = 4}) async {
    final response = await _makeRequest('/graphs/weekly-goals-progress?weeks=$weeks');
    if (response['success']) {
      return response['data'];
    }
    throw Exception('Failed to load weekly goals progress');
  }
  
  Future<Map<String, dynamic>> getProblemIntensityTrends({int days = 30}) async {
    final response = await _makeRequest('/graphs/problem-intensity-trends?days=$days');
    if (response['success']) {
      return response['data'];
    }
    throw Exception('Failed to load problem intensity trends');
  }
  
  Future<Map<String, dynamic>> getAIChallengesCompletion({int days = 30}) async {
    final response = await _makeRequest('/graphs/ai-challenges-completion?days=$days');
    if (response['success']) {
      return response['data'];
    }
    throw Exception('Failed to load AI challenges completion');
  }
  
  Future<Map<String, dynamic>> getQuickWinsAccumulation({int days = 7}) async {
    final response = await _makeRequest('/graphs/quick-wins-accumulation?days=$days');
    if (response['success']) {
      return response['data'];
    }
    throw Exception('Failed to load quick wins accumulation');
  }
  
  Future<Map<String, dynamic>> getOverallProgress() async {
    final response = await _makeRequest('/graphs/overall-progress');
    if (response['success']) {
      return response['data'];
    }
    throw Exception('Failed to load overall progress');
  }

  Future<Map<String, dynamic>> getAIChallengePoints({int days = 30}) async {
    final response = await _makeRequest('/graphs/ai-challenge-points', queryParams: {'days': days.toString()});
    if (response['success']) {
      return response['data'];
    }
    throw Exception('Failed to load AI challenge points data');
  }
  
  // Weekly Goal Intensities
  Future<List<WeeklyGoalIntensity>> getWeeklyGoalIntensities() async {
    final response = await _makeRequest('/weekly-goal-intensities/');
    if (response['success']) {
      return (response['data'] as List)
          .map((json) => WeeklyGoalIntensity.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load weekly goal intensities');
  }
  
  Future<WeeklyGoalIntensity> createWeeklyGoalIntensity(int goalId, DateTime weekStart, int intensity) async {
    final response = await _makeRequest(
      '/weekly-goal-intensities/',
      method: 'POST',
      body: {
        'goal_id': goalId,
        'week_start': '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}',
        'intensity': intensity,
      },
    );
    if (response['success']) {
      return WeeklyGoalIntensity.fromJson(response['data']);
    }
    throw Exception('Failed to create weekly goal intensity');
  }
  
  Future<WeeklyGoalIntensity> updateWeeklyGoalIntensity(int id, int intensity) async {
    final response = await _makeRequest(
      '/weekly-goal-intensities/$id',
      method: 'PUT',
      body: {'intensity': intensity},
    );
    if (response['success']) {
      return WeeklyGoalIntensity.fromJson(response['data']);
    }
    throw Exception('Failed to update weekly goal intensity');
  }
  
  // Goal Notes
  Future<List<GoalNote>> getGoalNotes(int goalId) async {
    final response = await _makeRequest('/goal-notes/?goal_id=$goalId');
    if (response['success']) {
      return (response['data'] as List).map((json) => GoalNote.fromJson(json)).toList();
    }
    throw Exception('Failed to load goal notes');
  }
  
  Future<GoalNote> createGoalNote(int goalId, String title, String content) async {
    final response = await _makeRequest(
      '/goal-notes/',
      method: 'POST',
      body: {
        'goal_id': goalId,
        'title': title,
        'content': content,
      },
    );
    if (response['success']) {
      return GoalNote.fromJson(response['data']);
    }
    throw Exception('Failed to create goal note');
  }
  
  Future<GoalNote> updateGoalNote(int noteId, {String? title, String? content}) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (content != null) body['content'] = content;
    
    final response = await _makeRequest(
      '/goal-notes/$noteId',
      method: 'PUT',
      body: body,
    );
    if (response['success']) {
      return GoalNote.fromJson(response['data']);
    }
    throw Exception('Failed to update goal note');
  }
  
  Future<void> deleteGoalNote(int noteId) async {
    final response = await _makeRequest('/goal-notes/$noteId', method: 'DELETE');
    if (!response['success']) {
      throw Exception('Failed to delete goal note');
    }
  }

  // Quick Notes
  Future<List<QuickNote>> getQuickNotes() async {
    final response = await _makeRequest('/quick-notes/');
    if (response['success']) {
      return (response['data'] as List).map((json) => QuickNote.fromJson(json)).toList();
    }
    throw Exception('Failed to load quick notes');
  }
  
  Future<QuickNote> createQuickNote(String content) async {
    final response = await _makeRequest(
      '/quick-notes/',
      method: 'POST',
      body: {'content': content},
    );
    if (response['success']) {
      return QuickNote.fromJson(response['data']);
    }
    throw Exception('Failed to create quick note');
  }
  
  Future<QuickNote> updateQuickNote(int noteId, String content) async {
    final response = await _makeRequest(
      '/quick-notes/$noteId',
      method: 'PUT',
      body: {'content': content},
    );
    if (response['success']) {
      return QuickNote.fromJson(response['data']);
    }
    throw Exception('Failed to update quick note');
  }

  // Todo Items
  Future<List<TodoItem>> getTodoItems(String userEmail) async {
    final response = await _makeRequest('/todo-items/', queryParams: {'user_email': userEmail});
    if (response['success']) {
      return (response['data'] as List).map((json) => TodoItem.fromJson(json)).toList();
    }
    throw Exception('Failed to load todo items');
  }
  
  Future<TodoItem> createTodoItem(String content, String userEmail) async {
    final response = await _makeRequest(
      '/todo-items/',
      method: 'POST',
      body: {'content': content, 'user_email': userEmail},
    );
    if (response['success']) {
      return TodoItem.fromJson(response['data']);
    }
    throw Exception('Failed to create todo item');
  }
  
  Future<TodoItem> updateTodoItem(int todoId, {String? content, bool? completed, required String userEmail}) async {
    final body = <String, dynamic>{'user_email': userEmail};
    if (content != null) body['content'] = content;
    if (completed != null) body['completed'] = completed;
    
    final response = await _makeRequest(
      '/todo-items/$todoId',
      method: 'PUT',
      body: body,
    );
    if (response['success']) {
      return TodoItem.fromJson(response['data']);
    }
    throw Exception('Failed to update todo item');
  }
  
  Future<void> deleteTodoItem(int todoId, String userEmail) async {
    final response = await _makeRequest('/todo-items/$todoId', method: 'DELETE', queryParams: {'user_email': userEmail});
    if (!response['success']) {
      throw Exception('Failed to delete todo item');
    }
  }

  // User Data
  Future<void> saveUserData({
    required String userId,
    required String email,
    required String name,
    String? profilePicture,
  }) async {
    final response = await _makeRequest(
      '/users/',
      method: 'POST',
      body: {
        'user_id': userId,
        'email': email,
        'name': name,
        if (profilePicture != null) 'profile_picture': profilePicture,
      },
    );
    if (!response['success']) {
      throw Exception('Failed to save user data');
    }
  }

  // Feedback
  Future<void> submitFeedback({
    required String userEmail,
    required String subject,
    required String body,
    String type = 'general',
  }) async {
    final response = await _makeRequest(
      '/feedback/submit-feedback',
      method: 'POST',
      body: {
        'user_email': userEmail,
        'subject': subject,
        'body': body,
        'type': type,
      },
    );
    
    if (response['status'] != 'success') {
      throw Exception(response['error'] ?? 'Failed to submit feedback');
    }
  }

  // Emails
  Future<List<Email>> getEmails({String? userEmail}) async {
    final queryParams = <String, String>{};
    if (userEmail != null) queryParams['user_email'] = userEmail;
    
    final response = await _makeRequest('/emails/', queryParams: queryParams);
    if (response['success']) {
      return (response['data'] as List).map((json) => Email.fromJson(json)).toList();
    }
    throw Exception('Failed to load emails');
  }
  
  Future<void> deleteEmail(String emailId) async {
    final response = await _makeRequest('/emails/delete/$emailId', method: 'DELETE');
    if (!response['success']) {
      throw Exception('Failed to delete email');
    }
  }
  
  Future<void> addAdminReply({
    required String subject,
    required String userEmail,
    required String content,
  }) async {
    final response = await _makeRequest(
      '/emails/add-admin-reply',
      method: 'POST',
      body: {
        'subject': subject,
        'user_email': userEmail,
        'content': content,
      },
    );
    if (!response['success']) {
      throw Exception('Failed to add admin reply');
    }
  }


   Future<Map<String, dynamic>> signup(String email, String password, String name) async {
  final response = await _makeRequest(
    '/auth/signup',
    method: 'POST',
    body: {
      'email': email,
      'password': password,
      'name': name,
    },
  );
  return response;
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _makeRequest(
      '/auth/login',
      method: 'POST',
      body: {
        'email': email,
        'password': password,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final response = await _makeRequest(
      '/auth/google-login',
      method: 'POST',
      body: {
        'idToken': idToken,
      },
    );
    return response;
  }

  // Password Reset
  Future<bool> sendPasswordResetEmail(String email) async {
    final response = await _makeRequest(
      '/auth/send-password-reset',
      method: 'POST',
      body: {
        'email': email,
      },
    );
    return response['success'] ?? false;
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    final response = await _makeRequest(
      '/auth/reset-password',
      method: 'POST',
      body: {
        'token': token,
        'new_password': newPassword,
      },
    );
    return response['success'] ?? false;
  }

  // Change Password
  Future<bool> changePassword(String userEmail, String currentPassword, String newPassword) async {
    final response = await _makeRequest(
      '/auth/change-password',
      method: 'POST',
      body: {
        'user_email': userEmail,
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
    return response['success'] ?? false;
  }

}
