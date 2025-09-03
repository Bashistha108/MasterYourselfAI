import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn? _googleSignIn = kIsWeb ? null : GoogleSignIn();

  // Initialize Firebase Auth with persistence
  FirebaseAuthService() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Set persistence to LOCAL (persists across app restarts)
    _auth.setPersistence(Persistence.LOCAL);
    
    // Enable token auto-refresh
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print('🔍 User authenticated: ${user.email}');
        // Ensure token is refreshed
        user.getIdToken(true);
      } else {
        print('🔍 User signed out');
      }
    });
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is authenticated and token is valid
  Future<bool> isUserAuthenticated() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      // Check if token is valid and refresh if needed
      final token = await user.getIdToken(true);
      return token.isNotEmpty;
    } catch (e) {
      print('❌ Error checking user authentication: $e');
      return false;
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
      print('✅ User data stored in SharedPreferences');
    } catch (e) {
      print('❌ Error storing user data: $e');
    }
  }

  // Clear stored user data
  Future<void> clearStoredUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_photo');
      print('✅ Stored user data cleared');
    } catch (e) {
      print('❌ Error clearing stored user data: $e');
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
}
