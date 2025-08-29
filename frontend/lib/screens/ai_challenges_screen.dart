import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/ai_challenge.dart';

class AIChallengesScreen extends StatefulWidget {
  @override
  _AIChallengesScreenState createState() => _AIChallengesScreenState();
}

class _AIChallengesScreenState extends State<AIChallengesScreen> {
  List<AIChallenge> todayChallenges = [];
  AIChallenge? selectedChallenge;
  bool isLoading = false;
  bool isGenerating = false;

  @override
  void initState() {
    super.initState();
    _generateFirstChallenge();
  }

  void _generateFirstChallenge() async {
    setState(() {
      isLoading = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final result = await appState.generateAIChallenge();
      
      if (result['limit_reached'] == true) {
        // This shouldn't happen on first load, but handle it
        setState(() {
          todayChallenges = result['challenges'];
          selectedChallenge = todayChallenges.isNotEmpty ? todayChallenges.first : null;
          isLoading = false;
        });
      } else {
        // First challenge generated
        setState(() {
          todayChallenges = [result['challenge']];
          selectedChallenge = result['challenge'];
          isLoading = false;
        });
      }
    } catch (error) {
      print('❌ Error generating first challenge: $error');
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating challenge: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _regenerateChallenge() async {
    setState(() {
      isGenerating = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final result = await appState.generateAIChallenge();
      
      if (result['limit_reached'] == true) {
        // Limit reached, show all challenges
        setState(() {
          todayChallenges = result['challenges'];
          selectedChallenge = todayChallenges.isNotEmpty ? todayChallenges.first : null;
          isGenerating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // New challenge generated
        setState(() {
          todayChallenges.add(result['challenge']);
          selectedChallenge = result['challenge'];
          isGenerating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New challenge generated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      print('❌ Error regenerating challenge: $error');
      setState(() {
        isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating challenge: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectChallenge(AIChallenge challenge) {
    setState(() {
      selectedChallenge = challenge;
    });
  }

  void _completeChallenge(BuildContext context, AIChallenge challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Challenge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to mark this challenge as completed?'),
            SizedBox(height: 20),
            Text(
              'Rate the intensity of this challenge:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Slider(
                      value: challenge.intensity.toDouble(),
                      min: -3,
                      max: 3,
                      divisions: 6,
                      activeColor: Colors.deepPurple,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (value) {
                        setState(() {
                          // Update the challenge with new intensity
                          final index = todayChallenges.indexWhere((c) => c.id == challenge.id);
                          if (index != -1) {
                            todayChallenges[index] = todayChallenges[index].copyWith(
                              intensity: value.toInt(),
                            );
                          }
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('-3', style: TextStyle(color: Colors.red)),
                        Text('-2', style: TextStyle(color: Colors.orange)),
                        Text('-1', style: TextStyle(color: Colors.yellow.shade700)),
                        Text('0', style: TextStyle(color: Colors.grey)),
                        Text('+1', style: TextStyle(color: Colors.lightGreen)),
                        Text('+2', style: TextStyle(color: Colors.green)),
                        Text('+3', style: TextStyle(color: Colors.deepGreen)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getIntensityColor(challenge.intensity),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Intensity: ${challenge.intensity > 0 ? '+' : ''}${challenge.intensity}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitCompletion(context, challenge);
            },
            child: Text('Complete'),
          ),
        ],
      ),
    );
  }

  Color _getIntensityColor(int intensity) {
    switch (intensity) {
      case -3:
        return Colors.red;
      case -2:
        return Colors.orange;
      case -1:
        return Colors.yellow.shade700;
      case 0:
        return Colors.grey;
      case 1:
        return Colors.lightGreen;
      case 2:
        return Colors.green;
      case 3:
        return Colors.deepGreen;
      default:
        return Colors.grey;
    }
  }

  void _submitCompletion(BuildContext context, AIChallenge challenge) {
    final appState = Provider.of<AppState>(context, listen: false);
    
    appState.completeAIChallenge(
      challenge.id!,
      completed: true,
    ).then((_) async {
      // Update the challenge in the local list
      final index = todayChallenges.indexWhere((c) => c.id == challenge.id);
      if (index != -1) {
        setState(() {
          todayChallenges[index] = todayChallenges[index].copyWith(completed: true);
          if (selectedChallenge?.id == challenge.id) {
            selectedChallenge = todayChallenges[index];
          }
        });
      }
      
      // Update intensity if it's not 0
      if (challenge.intensity != 0) {
        try {
          await appState.updateChallengeIntensity(challenge.id!, challenge.intensity);
        } catch (error) {
          print('Error updating intensity: $error');
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Challenge completed!'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing challenge: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Challenges',
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
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Generating your first AI challenge...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.psychology,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your Daily AI Challenge',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Complete today\'s personalized challenge to grow and improve',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'You can generate up to 3 challenges per day',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Challenge Counter
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.refresh,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${todayChallenges.length}/3 challenges generated today',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Challenge Display
                    if (todayChallenges.isNotEmpty) ...[
                      Text(
                        todayChallenges.length >= 3 ? 'Select Your Challenge' : 'Today\'s Challenge',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      // Challenge Cards
                      Expanded(
                        child: ListView.builder(
                          itemCount: todayChallenges.length,
                          itemBuilder: (context, index) {
                            final challenge = todayChallenges[index];
                            final isSelected = selectedChallenge?.id == challenge.id;
                            final isDisabled = todayChallenges.length >= 3 && !isSelected;
                            
                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: Card(
                                elevation: isSelected ? 4 : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected 
                                        ? Colors.deepPurple 
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: todayChallenges.length >= 3 ? () => _selectChallenge(challenge) : null,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDisabled 
                                          ? Colors.grey.shade100 
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: isSelected 
                                                    ? Colors.deepPurple.withOpacity(0.1)
                                                    : Colors.grey.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.lightbulb_outline,
                                                color: isSelected 
                                                    ? Colors.deepPurple 
                                                    : Colors.grey,
                                                size: 20,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Challenge ${index + 1}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected 
                                                      ? Colors.deepPurple 
                                                      : Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.deepPurple,
                                                size: 24,
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          challenge.challengeText,
                                          style: TextStyle(
                                            fontSize: 15,
                                            height: 1.4,
                                            color: isDisabled 
                                                ? Colors.grey.shade500 
                                                : Colors.grey.shade800,
                                          ),
                                        ),
                                        if (challenge.completed) ...[
                                          SizedBox(height: 12),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Completed',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Action Buttons
                      if (selectedChallenge != null && !selectedChallenge!.completed) ...[
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _completeChallenge(context, selectedChallenge!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Complete Challenge',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      // Regenerate Button
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: todayChallenges.length >= 3 || isGenerating 
                              ? null 
                              : _regenerateChallenge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: todayChallenges.length >= 3 
                                ? Colors.grey 
                                : Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isGenerating)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              else
                                Icon(Icons.refresh, size: 20),
                              SizedBox(width: 8),
                              Text(
                                todayChallenges.length >= 3 
                                    ? 'Maximum 3 challenges reached'
                                    : 'Generate Another Challenge',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // No Challenges Today
                      Expanded(
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_task,
                                  size: 64,
                                  color: Colors.deepPurple.withOpacity(0.5),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No Challenge Today',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Generate your first AI challenge to get started',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    
                    // Tips Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates,
                            color: Colors.amber.shade700,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'AI challenges are personalized based on your goals and problems',
                              style: TextStyle(
                                color: Colors.amber.shade800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
