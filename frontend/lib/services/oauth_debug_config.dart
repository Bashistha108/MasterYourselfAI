# class OAuthDebugConfig {
#   // Google OAuth Client IDs
#   static const String androidClientId = '259990462224-iantg8g8nna30rco5fjq9pvsntcikq7q.apps.googleusercontent.com';
#   static const String webClientId = '259990462224-iantg8g8nna30rco5fjq9pvsntcikq7q.apps.googleusercontent.com';
#   
#   // OAuth Scopes
#   static const List<String> googleScopes = [
#     'email',
#     'profile',
#     'openid',
#   ];
#   
#   // Debug flags
#   static const bool enableOAuthDebug = true;
#   static const bool logTokenDetails = true;
#   static const bool validateTokens = true;
#   
#   // OAuth Configuration
#   static const Map<String, dynamic> googleSignInConfig = {
#     'scopes': googleScopes,
#     'forceCodeForRefreshToken': true,
#     'hostedDomain': '', // Leave empty for any domain
#     'signInOption': 'standard', // 'standard' or 'games'
#   };
#   
#   // Error messages
#   static const Map<String, String> oauthErrorMessages = {
#     'network_error': 'Network error occurred. Please check your internet connection.',
#     'invalid_credential': 'The supplied auth credential is malformed or has expired.',
#     'account_exists_with_different_credential': 'An account already exists with the same email but different sign-in credentials.',
#     'invalid_email': 'Invalid email address format.',
#     'operation_not_allowed': 'Google Sign-In is not enabled for this app.',
#     'user_disabled': 'This user account has been disabled.',
#     'user_not_found': 'No user found with this email address.',
#     'weak_password': 'The password provided is too weak.',
#     'email_already_in_use': 'An account already exists with this email address.',
#     'credential_already_in_use': 'This credential is already associated with a different user account.',
#     'timeout': 'The operation timed out. Please try again.',
#     'cancelled': 'The sign-in operation was cancelled.',
#   };
#   
#   // Get error message by code
#   static String getErrorMessage(String code) {
#     return oauthErrorMessages[code] ?? 'An unknown error occurred: $code';
#   }
#   
#   // Debug logging
#   static void log(String message) {
#     if (enableOAuthDebug) {
#       print('🔍 [OAuth Debug] $message');
#     }
#   }
#   
#   // Token validation
#   static bool isValidToken(String? token) {
#     if (token == null || token.isEmpty) return false;
#     
#     // Basic JWT format validation (3 parts separated by dots)
#     final parts = token.split('.');
#     if (parts.length != 3) return false;
#     
#     // Check if parts are not empty
#     if (parts.any((part) => part.isEmpty)) return false;
#     
#     return true;
#   }
# }



