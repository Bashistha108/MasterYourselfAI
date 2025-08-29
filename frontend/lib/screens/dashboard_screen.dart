import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_yourself_ai/providers/app_state.dart';
import 'package:master_yourself_ai/widgets/content_box.dart';
import 'package:master_yourself_ai/screens/quick_note_screen.dart';
import 'package:master_yourself_ai/screens/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();
    // Initialize app data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initializeApp();
    });
  }

  void _showLogoutDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                appState.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, AppState appState) {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;
    bool _isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Change Password'),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                                                      'If you signed up with Google, use "Setup Password Login" first',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword = !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (newPasswordController.text != confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('New passwords do not match'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    if (newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('New password must be at least 6 characters'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      final success = await appState.changePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                      );
                      
                      if (success) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Password changed successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to change password. Please check your current password.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Change Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

     void _showPasswordSetupDialog(BuildContext context, AppState appState) {
     bool hasEmailPassword = appState.hasEmailPasswordCapability();
     
     // Debug: Print the state
     print('Password Setup Dialog - hasEmailPassword: $hasEmailPassword');
     
     if (hasEmailPassword) {
       // User already has password - show change password dialog
       print('Showing Change Password Dialog');
       _showChangePasswordDialog(context, appState);
     } else {
       // User doesn't have password - show setup dialog
       print('Showing Password Setup Email Dialog');
       _showPasswordSetupEmailDialog(context, appState);
     }
   }

   void _showPasswordSetupEmailDialog(BuildContext context, AppState appState) {
     final TextEditingController emailController = TextEditingController();
     final TextEditingController passwordController = TextEditingController();
     final TextEditingController confirmPasswordController = TextEditingController();
     bool _obscurePassword = true;
     bool _obscureConfirmPassword = true;
     bool _isLoading = false;

     // Pre-fill with user's email if available
     emailController.text = appState.userEmail ?? '';

     showDialog(
       context: context,
       builder: (BuildContext context) {
         return StatefulBuilder(
           builder: (context, setState) {
             return AlertDialog(
               title: Text('Setup Password Login'),
               content: Container(
                 width: double.maxFinite,
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Container(
                       padding: EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: Colors.blue.shade50,
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(color: Colors.blue.shade200),
                       ),
                       child: Row(
                         children: [
                           Icon(Icons.info, color: Colors.blue, size: 20),
                           SizedBox(width: 8),
                           Expanded(
                             child: Text(
                               'Create a password for your Google account to enable email/password login',
                               style: TextStyle(
                                 color: Colors.blue.shade700,
                                 fontSize: 12,
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                     SizedBox(height: 16),
                     TextField(
                       controller: passwordController,
                       obscureText: _obscurePassword,
                       decoration: InputDecoration(
                         labelText: 'Password',
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(10),
                         ),
                         suffixIcon: IconButton(
                           icon: Icon(
                             _obscurePassword ? Icons.visibility : Icons.visibility_off,
                           ),
                           onPressed: () {
                             setState(() {
                               _obscurePassword = !_obscurePassword;
                             });
                           },
                         ),
                       ),
                     ),
                     SizedBox(height: 16),
                     TextField(
                       controller: confirmPasswordController,
                       obscureText: _obscureConfirmPassword,
                       decoration: InputDecoration(
                         labelText: 'Confirm Password',
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(10),
                         ),
                         suffixIcon: IconButton(
                           icon: Icon(
                             _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                           ),
                           onPressed: () {
                             setState(() {
                               _obscureConfirmPassword = !_obscureConfirmPassword;
                             });
                           },
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(15),
               ),
               actions: [
                 TextButton(
                   onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                   child: Text('Cancel'),
                 ),
                 ElevatedButton(
                   onPressed: _isLoading ? null : () async {
                     if (passwordController.text != confirmPasswordController.text) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text('Passwords do not match'),
                           backgroundColor: Colors.red,
                         ),
                       );
                       return;
                     }
                     
                     if (passwordController.text.length < 6) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text('Password must be at least 6 characters'),
                           backgroundColor: Colors.red,
                         ),
                       );
                       return;
                     }

                     setState(() {
                       _isLoading = true;
                     });

                     try {
                       final success = await appState.setupPasswordForGoogleUser(
                         emailController.text,
                         passwordController.text,
                       );
                       
                       if (success) {
                         Navigator.of(context).pop();
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text('Password setup successful! You can now login with email/password.'),
                             backgroundColor: Colors.green,
                           ),
                         );
                       } else {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text('Failed to setup password. Please try again.'),
                             backgroundColor: Colors.red,
                           ),
                         );
                       }
                     } catch (e) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text('Error: ${e.toString()}'),
                           backgroundColor: Colors.red,
                         ),
                       );
                     } finally {
                       setState(() {
                         _isLoading = false;
                       });
                     }
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.blue,
                     foregroundColor: Colors.white,
                   ),
                   child: _isLoading 
                     ? SizedBox(
                         width: 20,
                         height: 20,
                         child: CircularProgressIndicator(
                           strokeWidth: 2,
                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                         ),
                       )
                     : Text('Setup Password'),
                 ),
               ],
             );
           },
         );
       },
     );
   }

   

  List<Widget> _buildPasswordOptions(BuildContext context, AppState appState) {
    bool hasEmailPassword = appState.hasEmailPasswordCapability();
    
    // Debug: Print the state
    print('Dashboard - hasEmailPassword: $hasEmailPassword');
    
    return [
      ListTile(
        leading: Icon(Icons.lock, color: Colors.orange),
        title: Text('Setup Password Login'),
        subtitle: hasEmailPassword 
          ? Text('Change your password')
          : Text('Setup password login for your account'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => _showPasswordSetupDialog(context, appState),
      ),
    ];
  }

  Widget _buildDashboardContent() {
    return Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your progress...'),
                ],
              ),
            );
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
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      appState.clearError();
                      appState.initializeApp();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Account Header
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade600,
                          Colors.purple.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Profile Avatar
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back!',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                appState.userName ?? 'User',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                appState.userEmail ?? 'user@email.com',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Logout Button
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.white),
                          color: Colors.white,
                          onSelected: (value) {
                            if (value == 'logout') {
                              _showLogoutDialog(context, appState);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Logout'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Week indicator
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Week: ${(DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays / 7).ceil()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Main content boxes
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.1,
                    children: [
                      ContentBox(
                        title: 'Weekly Goals',
                        subtitle: '${appState.activeWeeklyGoals.length}/3',
                        icon: Icons.flag_rounded,
                        color: Colors.blue,
                        onTap: () => Navigator.pushNamed(context, '/weekly-goals'),
                      ),
                      ContentBox(
                        title: 'Build your Best Self',
                        subtitle: '${appState.longTermGoals.length}/3',
                        icon: Icons.trending_up_rounded,
                        color: Colors.green,
                        onTap: () => Navigator.pushNamed(context, '/long-term-goals'),
                      ),
                      ContentBox(
                        title: 'My Problems',
                        subtitle: '${appState.activeProblems.length} tracked',
                        icon: Icons.track_changes_rounded,
                        color: Colors.red,
                        onTap: () => Navigator.pushNamed(context, '/problems'),
                      ),
                      ContentBox(
                        title: 'AI Challenges',
                        subtitle: '${appState.aiChallenges.where((c) => c.completed).length}/${appState.aiChallenges.length}',
                        icon: Icons.psychology_rounded,
                        color: Colors.purple,
                        onTap: () => Navigator.pushNamed(context, '/ai-challenges'),
                      ),
                      ContentBox(
                        title: 'Analytics',
                        subtitle: 'View Progress',
                        icon: Icons.analytics_rounded,
                        color: Colors.teal,
                        onTap: () => Navigator.pushNamed(context, '/graphs'),
                      ),
                      ContentBox(
                        title: 'Notes + Todo',
                        subtitle: 'Quick Entry',
                        icon: Icons.note_add_rounded,
                        color: Colors.orange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QuickNoteScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildDashboardContent(),
    );
  }
}
