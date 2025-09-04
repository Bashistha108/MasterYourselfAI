import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:master_yourself_ai/services/oauth_debug_config.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn? _googleSignIn = kIsWeb 
    ? null 
    : GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        serverClientId: OAuthDebugConfig.webClientId, // Use web client ID as server client ID
      );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print("🔍 Starting Google Sign-In process...");
      print("🔍 Platform: ${kIsWeb ? 'Web' : 'Mobile'}");
      
      if (kIsWeb) {
        // For web, use Firebase Auth's built-in Google provider
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.addScope('openid');
        googleProvider.setCustomParameters({
          'prompt': 'select_account',
          'client_id': OAuthDebugConfig.webClientId,
        });
        
        final userCredential = await _auth.signInWithPopup(googleProvider);
        return {
          'userCredential': userCredential,
          'googleIdToken': null, // Web doesn't provide Google ID token directly
        };
      } else {
        // For mobile, use Google Sign-In plugin
        if (_googleSignIn == null) {
          throw Exception('Google Sign-In is not available on this platform.');
        }
        
        print("🔍 GoogleSignIn instance created successfully");
        print("🔍 Available scopes: ${OAuthDebugConfig.googleScopes}");
        print("🔍 Server client ID: ${OAuthDebugConfig.webClientId}");
        
        // Trigger the authentication flow
        print("🔍 Starting Google Sign-In flow...");
        final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
        
        if (googleUser == null) {
          throw Exception('Google sign-in was cancelled');
        }

        // Obtain the auth details from the request
        print("🔍 Getting authentication details...");
        print("🔍 Google user email: ${googleUser.email}");
        print("🔍 Google user ID: ${googleUser.id}");
        
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        print("🔍 Access token: ${googleAuth.accessToken != null ? 'Present' : 'Missing'}");
        print("🔍 ID token: ${googleAuth.idToken != null ? 'Present' : 'Missing'}");
        
        if (googleAuth.idToken == null) {
          print("❌ No ID token received. This usually means:");
          print("   1. Server client ID is incorrect");
          print("   2. SHA-1 fingerprint is not added to Firebase");
          print("   3. Google Sign-In configuration is wrong");
          throw Exception('Google Sign-In failed: No ID token received');
        }

        // Create a new credential
        print("🔍 Creating Firebase credential...");
        print("🔍 Access token length: ${googleAuth.accessToken?.length ?? 0}");
        print("🔍 ID token length: ${googleAuth.idToken?.length ?? 0}");
        
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Try to sign in with Firebase credential
        print("🔍 Signing in with Firebase credential...");
        try {
          final userCredential = await _auth.signInWithCredential(credential);
          print("✅ Firebase authentication successful");
          
          return {
            'userCredential': userCredential,
            'googleIdToken': googleAuth.idToken,
          };
        } catch (firebaseError) {
          print("❌ Firebase authentication failed: $firebaseError");
          print("🔍 Attempting to proceed with Google ID token only...");
          
          // If Firebase fails, we can still return the Google ID token
          // The app can handle authentication through the backend
          return {
            'userCredential': null,
            'googleIdToken': googleAuth.idToken,
            'googleUser': googleUser,
          };
        }
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
        if (_googleSignIn != null) _googleSignIn!.signOut(),
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
