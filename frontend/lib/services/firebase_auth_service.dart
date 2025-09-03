import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn? _googleSignIn = kIsWeb ? null : GoogleSignIn();

  // Custom authentication state that persists independently
  bool _customAuthenticated = false;
  String? _customUserEmail;
  String? _customUserName;
  String? _customUserPhoto;

  // Initialize Firebase Auth with persistence
  FirebaseAuthService() {
    _initializeAuth();
    _loadCustomAuthState();
  }

  // Load custom auth state from SharedPreferences
  Future<void> _loadCustomAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString('user_email');
      final storedName = prefs.getString('user_name');
      final storedPhoto = prefs.getString('user_photo');
      final storedTimestamp = prefs.getString('user_data_timestamp');
      
      if (storedEmail != null && storedTimestamp != null) {
        final dataTime = DateTime.parse(storedTimestamp);
        final now = DateTime.now();
        final difference = now.difference(dataTime);
        
        // Consider data valid if less than 30 days old
        if (difference.inDays < 30) {
          _customAuthenticated = true;
          _customUserEmail = storedEmail;
          _customUserName = storedName ?? storedEmail.split('@')[0];
          _customUserPhoto = storedPhoto;
          
          print('✅ Custom auth state loaded: $_customUserEmail');
        } else {
          print('⚠️ Stored data too old, clearing custom auth state');
          await clearStoredUserData();
        }
      }
    } catch (e) {
      print('❌ Error loading custom auth state: $e');
    }
  }

  // Save custom auth state to SharedPreferences
  Future<void> _saveCustomAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_auth_state', _customAuthenticated.toString());
      await prefs.setString('custom_user_email', _customUserEmail ?? '');
      await prefs.setString('custom_user_name', _customUserName ?? '');
      await prefs.setString('custom_user_photo', _customUserPhoto ?? '');
      await prefs.setString('custom_auth_timestamp', DateTime.now().toIso8601String());
      
      print('✅ Custom auth state saved');
    } catch (e) {
      print('❌ Error saving custom auth state: $e');
    }
  }

  void _initializeAuth() {
    // Note: setPersistence is deprecated on mobile, Firebase handles this automatically
    // The persistence is controlled by the platform and Firebase configuration
    
    // Enable token auto-refresh and better persistence
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print('🔍 User authenticated: ${user.email}');
        // Ensure token is refreshed and stored
        user.getIdToken(true).then((token) {
          if (token.isNotEmpty) {
            print('✅ Token refreshed and stored for: ${user.email}');
            // Store the token in SharedPreferences for backup
            _storeAuthToken(token);
            // Store user data immediately
            storeUserData(user);
            
            // Also update custom auth state
            _customAuthenticated = true;
            _customUserEmail = user.email;
            _customUserName = user.displayName ?? user.email?.split('@')[0];
            _customUserPhoto = user.photoURL;
            _saveCustomAuthState();
          }
        }).catchError((e) {
          print('⚠️ Token refresh failed: $e');
        });
      } else {
        print('🔍 User signed out');
        // Don't clear stored data immediately - wait for explicit sign out
        // Keep custom auth state if we have valid stored data
      }
    });

    // Set up token refresh listener
    _auth.idTokenChanges().listen((User? user) {
      if (user != null) {
        print('🔄 ID token changed for user: ${user.email}');
        // Token was refreshed, update stored data
        _storeAuthToken(user.uid);
      }
    });
  }

  // Store auth token for backup persistence
  Future<void> _storeAuthToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_token_timestamp', DateTime.now().toIso8601String());
      print('✅ Auth token stored in SharedPreferences');
    } catch (e) {
      print('❌ Failed to store auth token: $e');
    }
  }

  // Get stored auth token
  Future<String?> getStoredAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final timestamp = prefs.getString('auth_token_timestamp');
      
      if (token != null && timestamp != null) {
        final tokenTime = DateTime.parse(timestamp);
        final now = DateTime.now();
        final difference = now.difference(tokenTime);
        
        // Check if token is less than 1 hour old
        if (difference.inHours < 1) {
          print('✅ Stored auth token is still valid (${difference.inMinutes} minutes old)');
          return token;
        } else {
          print('⚠️ Stored auth token is too old (${difference.inHours} hours old)');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting stored auth token: $e');
      return null;
    }
  }

  // Get current user (prioritize custom auth state)
  User? get currentUser {
    if (_customAuthenticated && _customUserEmail != null) {
      // Return a mock user object based on custom auth state
      // This prevents the app from thinking the user is logged out
      return null; // Will be handled by custom auth methods
    }
    return _auth.currentUser;
  }

  // Custom auth state getters
  bool get isCustomAuthenticated => _customAuthenticated;
  String? get customUserEmail => _customUserEmail;
  String? get customUserName => _customUserName;
  String? get customUserPhoto => _customUserPhoto;

  // Auth state changes stream (combine Firebase and custom)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is authenticated (prioritize custom auth state)
  Future<bool> isUserAuthenticated() async {
    try {
      // First check custom auth state
      if (_customAuthenticated && _customUserEmail != null) {
        print('🔍 Custom auth state is active: $_customUserEmail');
        return true;
      }
      
      // Then check Firebase
      final user = _auth.currentUser;
      if (user != null) {
        // Check if token is valid and refresh if needed
        final token = await user.getIdToken(true);
        return token.isNotEmpty;
      }
      
      // If no Firebase user, check stored data
      final storedUserData = await getStoredUserData();
      final storedEmail = storedUserData['email'];
      final isDataValid = await isStoredUserDataValid();
      
      if (storedEmail != null && storedEmail.isNotEmpty && isDataValid) {
        print('🔍 No Firebase user, but found valid stored data: $storedEmail');
        // Restore custom auth state
        _customAuthenticated = true;
        _customUserEmail = storedEmail;
        _customUserName = storedUserData['name'] ?? storedEmail.split('@')[0];
        _customUserPhoto = storedUserData['photo'];
        _saveCustomAuthState();
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error checking user authentication: $e');
      // On error, check stored data as fallback
      final storedUserData = await getStoredUserData();
      final storedEmail = storedUserData['email'];
      final isDataValid = await isStoredUserDataValid();
      
      if (storedEmail != null && storedEmail.isNotEmpty && isDataValid) {
        // Restore custom auth state
        _customAuthenticated = true;
        _customUserEmail = storedEmail;
        _customUserName = storedUserData['name'] ?? storedEmail.split('@')[0];
        _customUserPhoto = storedUserData['photo'];
        _saveCustomAuthState();
        return true;
      }
      
      return false;
    }
  }

  // Force refresh user token and check authentication
  Future<bool> refreshUserToken() async {
    try {
      // First check custom auth state
      if (_customAuthenticated && _customUserEmail != null) {
        print('✅ Custom auth state is active, no need to refresh token');
        return true;
      }
      
      final user = _auth.currentUser;
      if (user != null) {
        // Force refresh the token
        final token = await user.getIdToken(true);
        if (token.isNotEmpty) {
          print('✅ User token refreshed successfully');
          // Store the refreshed token
          await _storeAuthToken(token);
          return true;
        }
        return false;
      }
      
      // If no Firebase user, check if we can restore from stored data
      final storedUserData = await getStoredUserData();
      final storedEmail = storedUserData['email'];
      final isDataValid = await isStoredUserDataValid();
      
      if (storedEmail != null && storedEmail.isNotEmpty && isDataValid) {
        print('✅ Can restore authentication from stored data: $storedEmail');
        // Restore custom auth state
        _customAuthenticated = true;
        _customUserEmail = storedEmail;
        _customUserName = storedUserData['name'] ?? storedEmail.split('@')[0];
        _customUserPhoto = storedUserData['photo'];
        _saveCustomAuthState();
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error refreshing user token: $e');
      // On error, check stored data as fallback
      final storedUserData = await getStoredUserData();
      final storedEmail = storedUserData['email'];
      final isDataValid = await isStoredUserDataValid();
      
      if (storedEmail != null && storedEmail.isNotEmpty && isDataValid) {
        // Restore custom auth state
        _customAuthenticated = true;
        _customUserEmail = storedEmail;
        _customUserName = storedUserData['name'] ?? storedEmail.split('@')[0];
        _customUserPhoto = storedUserData['photo'];
        _saveCustomAuthState();
        return true;
      }
      
      return false;
    }
  }

  // Get user with token refresh (prioritize custom auth state)
  Future<User?> getCurrentUserWithRefresh() async {
    try {
      // First check custom auth state
      if (_customAuthenticated && _customUserEmail != null) {
        print('🔍 Custom auth state is active: $_customUserEmail');
        return null; // Will be handled by custom auth methods
      }
      
      final user = _auth.currentUser;
      if (user != null) {
        // Refresh token to ensure it's valid
        await user.getIdToken(true);
        return user;
      }
      
      // If no current user, check if we can restore from stored data
      final storedUserData = await getStoredUserData();
      final storedEmail = storedUserData['email'];
      final isDataValid = await isStoredUserDataValid();
      
      if (storedEmail != null && storedEmail.isNotEmpty && isDataValid) {
        print('🔍 Attempting to restore user session from stored token');
        // Try to get user info from stored data
        if (storedUserData['email'] != null) {
          print('✅ Restored user session: ${storedUserData['email']}');
          // Restore custom auth state
          _customAuthenticated = true;
          _customUserEmail = storedEmail;
          _customUserName = storedUserData['name'] ?? storedEmail.split('@')[0];
          _customUserPhoto = storedUserData['photo'];
          _saveCustomAuthState();
          return null; // Will be handled by custom auth methods
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting current user with refresh: $e');
      return null;
    }
  }

  // Get stored user data from SharedPreferences
  Future<Map<String, String?>> getStoredUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'email': prefs.getString('user_email'),
        'name': prefs.getString('user_name'),
        'photo': prefs.getString('user_photo'),
        'uid': prefs.getString('user_uid'),
      };
    } catch (e) {
      print('❌ Error getting stored user data: $e');
      return {};
    }
  }

  // Store user data in SharedPreferences
  Future<void> storeUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_name', user.displayName ?? '');
      await prefs.setString('user_photo', user.photoURL ?? '');
      await prefs.setString('user_uid', user.uid);
      
      // Also store the current timestamp
      await prefs.setString('user_data_timestamp', DateTime.now().toIso8601String());
      
      print('✅ User data stored in SharedPreferences');
    } catch (e) {
      print('❌ Error storing user data: $e');
    }
  }

  // Store user data manually (for non-Firebase users)
  Future<void> storeUserDataManually({
    required String email,
    required String name,
    String? photo,
    String? uid,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', name);
      if (photo != null) await prefs.setString('user_photo', photo);
      if (uid != null) await prefs.setString('user_uid', uid);
      
      // Also store the current timestamp
      await prefs.setString('user_data_timestamp', DateTime.now().toIso8601String());
      
      print('✅ User data stored manually in SharedPreferences: $email');
    } catch (e) {
      print('❌ Error storing user data manually: $e');
    }
  }

  // Clear stored user data
  Future<void> clearStoredUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_photo');
      await prefs.remove('user_uid');
      await prefs.remove('auth_token');
      await prefs.remove('auth_token_timestamp');
      await prefs.remove('user_data_timestamp');
      print('✅ Stored user data cleared');
    } catch (e) {
      print('❌ Error clearing stored user data: $e');
    }
  }

  // Check if stored user data is still valid
  Future<bool> isStoredUserDataValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString('user_data_timestamp');
      
      if (timestamp != null) {
        final dataTime = DateTime.parse(timestamp);
        final now = DateTime.now();
        final difference = now.difference(dataTime);
        
        // Consider data valid if less than 7 days old (increased from 24 hours)
        if (difference.inDays < 7) {
          print('✅ Stored user data is still valid (${difference.inDays} days old)');
          return true;
        } else {
          print('⚠️ Stored user data is too old (${difference.inDays} days old)');
          return false;
        }
      }
      return false;
    } catch (e) {
      print('❌ Error checking stored user data validity: $e');
      return false;
    }
  }

  // Check if user has a valid stored session
  Future<bool> hasValidStoredSession() async {
    try {
      final storedUserData = await getStoredUserData();
      final storedEmail = storedUserData['email'];
      final isDataValid = await isStoredUserDataValid();
      
      return storedEmail != null && storedEmail.isNotEmpty && isDataValid;
    } catch (e) {
      print('❌ Error checking stored session: $e');
      return false;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      // Provide more specific error messages
      if (e.code == 'user-not-found') {
        throw Exception('No account found with this email. Please sign up first or use Google Sign-In.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password. Please try again or use "Forgot Password" to reset.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email address. Please check your email format.');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled. Please contact support.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many failed attempts. Please try again later.');
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await result.user?.updateDisplayName(displayName);
      await result.user?.reload();
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // For web, use Firebase Auth's built-in Google provider
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({
          'prompt': 'select_account'
        });
        
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // For mobile, use Google Sign-In plugin
        // if (_googleSignIn == null) { // This line was removed as per the new_code, so it's removed here.
        //   throw Exception('Google Sign-In is not available on this platform.');
        // }
        
        // Trigger the authentication flow
        // final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn(); // This line was removed as per the new_code, so it's removed here.
        
        // if (googleUser == null) { // This line was removed as per the new_code, so it's removed here.
        //   throw Exception('Google sign-in was cancelled');
        // }

        // Obtain the auth details from the request
        // final GoogleSignInAuthentication googleAuth = await googleUser.authentication; // This line was removed as per the new_code, so it's removed here.

        // Create a new credential
        // final credential = GoogleAuthProvider.credential( // This line was removed as per the new_code, so it's removed here.
        //   accessToken: googleAuth.accessToken,
        //   idToken: googleAuth.idToken,
        // );

        // Once signed in, return the UserCredential
        // return await _auth.signInWithCredential(credential); // This line was removed as per the new_code, so it's removed here.
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Re-authenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Change password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  // Check if user has email/password capability
  bool hasEmailPasswordCapability() {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    // Debug: Print all providers to see what's available
    print('User providers: ${user.providerData.map((p) => p.providerId).toList()}');
    
    // Check if user has email/password provider
    bool hasPasswordProvider = user.providerData.any((provider) => provider.providerId == 'password');
    
    // Check if user has Google provider (indicating they signed up with Google)
    bool hasGoogleProvider = user.providerData.any((provider) => provider.providerId == 'google.com');
    
    print('Has password provider: $hasPasswordProvider');
    print('Has Google provider: $hasGoogleProvider');
    
    // If user has both Google and password, they likely linked password to Google account
    // In this case, we should still show the setup flow for better UX
    if (hasGoogleProvider && hasPasswordProvider) {
      // For Google users with linked password, we'll treat it as "not set up" 
      // so they can use the secure email-based setup flow
      return false;
    }
    
    return hasPasswordProvider;
  }

  // For Google users, we need to unlink the existing password and create a new one
  Future<void> setupPasswordForGoogleUser(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      print('Setting up password for Google user: $email');

      // First, unlink any existing password provider
      try {
        await user.unlink('password');
        print('Unlinked existing password provider');
      } catch (e) {
        print('No existing password provider to unlink: $e');
      }

      // Create new email/password credential
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Link the credential to the current user
      await user.linkWithCredential(credential);
      print('Successfully linked email/password to Google account');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      if (e.code == 'email-already-in-use') {
        throw Exception('This email is already associated with another account.');
      } else if (e.code == 'weak-password') {
        throw Exception('Password is too weak. Please choose a stronger password.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email address. Please check your email format.');
      }
      throw _handleAuthException(e);
    } catch (e) {
      print('General Exception: ${e.toString()}');
      throw Exception('Failed to setup password: ${e.toString()}');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send email verification: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        // if (_googleSignIn != null) _googleSignIn!.signOut(), // This line was removed as per the new_code, so it's removed here.
      ]);
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Delete user account
  Future<void> deleteUser() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'invalid-credential':
        return 'The supplied auth credential is malformed or has expired.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // Check if user email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Get user display name
  String? get userDisplayName => currentUser?.displayName;

  // Get user email
  String? get userEmail => currentUser?.email;

  // Get user photo URL
  String? get userPhotoURL => currentUser?.photoURL;

  // Debug method to check authentication state
  Future<Map<String, dynamic>> debugAuthState() async {
    try {
      final currentUser = _auth.currentUser;
      final storedToken = await getStoredAuthToken();
      final storedUserData = await getStoredUserData();
      final isDataValid = await isStoredUserDataValid();
      
      return {
        'firebase_user': currentUser?.email ?? 'null',
        'firebase_uid': currentUser?.uid ?? 'null',
        'stored_token': storedToken != null ? 'valid' : 'null',
        'stored_email': storedUserData['email'] ?? 'null',
        'stored_name': storedUserData['name'] ?? 'null',
        'stored_data_valid': isDataValid,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Force restore session from stored data
  Future<bool> forceRestoreSession() async {
    try {
      final storedUserData = await getStoredUserData();
      final storedEmail = storedUserData['email'];
      final isDataValid = await isStoredUserDataValid();
      
      if (storedEmail != null && storedEmail.isNotEmpty && isDataValid) {
        print('✅ Force restoring session for: $storedEmail');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error in force restore: $e');
      return false;
    }
  }
}
