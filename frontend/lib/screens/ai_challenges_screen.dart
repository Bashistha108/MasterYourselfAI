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
  bool limitReached = false;
  int remainingChallenges = 3;

  @override
  void initState() {
    super.initState();
    _loadTodayChallenges();
  }

  Future<void> _loadTodayChallenges() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final challenges = await appState.getTodayAIChallenges();
    setState(() {
      todayChallenges = challenges;
      selectedChallenge = todayChallenges.isNotEmpty ? todayChallenges.first : null;
      limitReached = todayChallenges.length >= 3;
      remainingChallenges = 3 - todayChallenges.length;
    });
  }

  void _generateNewChallenge() async {
    if (isGenerating) return; // Prevent multiple simultaneous calls
    
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
          limitReached = true;
          remainingChallenges = 0;
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
          limitReached = result['remaining'] == 0;
          remainingChallenges = result['remaining'];
          isGenerating = false;
        });
      }
    } catch (error) {
      print('❌ Error generating challenge: $error');
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
      builder: (BuildContext context) {
        AIChallenge challengeCopy = challenge.copyWith(intensity: 0);
        
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text('Complete Challenge'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.challengeText,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'How well did you complete this challenge?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'More points means challenge better completed.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text('Completion Quality: '),
                      Text(
                        '${challengeCopy.intensity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getIntensityColor(challengeCopy.intensity),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: challengeCopy.intensity.toDouble(),
                    min: -3,
                    max: 3,
                    divisions: 6,
                    activeColor: _getIntensityColor(challengeCopy.intensity),
                    onChanged: (value) {
                      setDialogState(() {
                        challengeCopy = challengeCopy.copyWith(intensity: value.toInt());
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('-3', style: TextStyle(color: Colors.red.shade600)),
                      Text('-2', style: TextStyle(color: Colors.orange.shade600)),
                      Text('-1', style: TextStyle(color: Colors.amber.shade600)),
                      Text('0', style: TextStyle(color: Colors.grey.shade600)),
                      Text('+1', style: TextStyle(color: Colors.lightGreen.shade600)),
                      Text('+2', style: TextStyle(color: Colors.green.shade600)),
                      Text('+3', style: TextStyle(color: Colors.green.shade800)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getIntensityDescription(challengeCopy.intensity),
                    style: TextStyle(
                      fontSize: 14,
                      color: _getIntensityColor(challengeCopy.intensity),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _submitCompletion(context, challengeCopy),
                  child: Text('Complete'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildIntensityLabel(int value, String label) {
    final isSelected = value == 0; // Default to neutral
    return Column(
      children: [
        Text(
          '${value > 0 ? '+' : ''}$value',
          style: TextStyle(
            color: _getIntensityColor(value),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: _getIntensityColor(value),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  String _getIntensityDescription(int intensity) {
    switch (intensity) {
      case -3:
        return 'Poor - Did not complete the challenge well';
      case -2:
        return 'Fair - Completed but with significant issues';
      case -1:
        return 'Okay - Completed but could have done better';
      case 0:
        return 'Good - Completed the challenge satisfactorily';
      case 1:
        return 'Very Good - Completed with good effort and results';
      case 2:
        return 'Excellent - Completed exceptionally well';
      case 3:
        return 'Outstanding - Exceeded expectations completely';
      default:
        return 'Select completion quality';
    }
  }

  Color _getIntensityColor(int intensity) {
    switch (intensity) {
      case -3:
        return Colors.red.shade600;
      case -2:
        return Colors.red.shade400;
      case -1:
        return Colors.orange.shade400;
      case 0:
        return Colors.blueGrey.shade500;
      case 1:
        return Colors.lightGreen.shade600;
      case 2:
        return Colors.green.shade600;
      case 3:
        return Colors.teal.shade700;
      default:
        return Colors.grey;
    }
  }

  void _submitCompletion(BuildContext context, AIChallenge challenge) async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      if (challenge.id != null) {
        // First mark the challenge as completed
        await appState.completeAIChallenge(challenge.id!, completed: true);
        
        // Then update the intensity
        await appState.updateChallengeIntensity(challenge.id!, challenge.intensity);
        
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Challenge completed with ${challenge.intensity >= 0 ? '+' : ''}${challenge.intensity} points!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh the challenges list
        _loadTodayChallenges();
      } else {
        throw Exception('Challenge ID is null');
      }
    } catch (error) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing challenge: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with remaining challenges info
              if (todayChallenges.isNotEmpty) ...[
                Text(
                  'Today\'s AI Challenges',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
                SizedBox(height: 8),
                if (!limitReached)
                  Text(
                    'Remaining challenges: $remainingChallenges',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  )
                else
                  Text(
                    'Maximum 3 challenges per day reached',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                SizedBox(height: 16),
              ] else ...[
                Text(
                  'AI Challenges',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No challenges generated yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Click the button below to generate your first AI challenge',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: isGenerating ? null : _generateNewChallenge,
                        icon: isGenerating 
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(Icons.add),
                        label: Text(isGenerating ? 'Generating...' : 'Generate Challenge'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Challenges list
              if (todayChallenges.isNotEmpty) ...[
                Expanded(
                  child: ListView.builder(
                    itemCount: todayChallenges.length,
                    itemBuilder: (context, index) {
                      final challenge = todayChallenges[index];
                      final isSelected = selectedChallenge?.id == challenge.id;
                      final isDisabled = limitReached && !isSelected;
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        color: isSelected 
                          ? Colors.purple.shade50 
                          : isDisabled 
                            ? Colors.grey.shade100 
                            : Colors.white,
                        child: InkWell(
                          onTap: limitReached ? () {
                            setState(() {
                              selectedChallenge = challenge;
                            });
                          } : null,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        challenge.challengeText,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: isDisabled 
                                            ? Colors.grey.shade600 
                                            : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.purple.shade600,
                                        size: 24,
                                      ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Created: ${_formatDate(challenge.createdAt)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    Spacer(),
                                    if (challenge.completed) ...[
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.green.shade300),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green.shade600,
                                              size: 14,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Completed',
                                              style: TextStyle(
                                                color: Colors.green.shade600,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getIntensityColor(challenge.intensity).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: _getIntensityColor(challenge.intensity)),
                                        ),
                                        child: Text(
                                          '${challenge.intensity >= 0 ? '+' : ''}${challenge.intensity}',
                                          style: TextStyle(
                                            color: _getIntensityColor(challenge.intensity),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      TextButton(
                                        onPressed: () => _completeChallenge(context, challenge),
                                        child: Text(
                                          'Complete',
                                          style: TextStyle(
                                            color: Colors.purple.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Generate more button
                if (!limitReached && todayChallenges.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isGenerating ? null : _generateNewChallenge,
                        icon: isGenerating 
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(Icons.add),
                        label: Text(isGenerating ? 'Generating...' : 'Generate Another Challenge'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
