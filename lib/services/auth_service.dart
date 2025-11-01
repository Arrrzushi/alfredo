import 'package:firebase_auth/firebase_auth.dart';

/// Authentication service for Firebase Auth
/// Currently uses anonymous authentication for development
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  /// Sign in anonymously (for development/testing)
  /// In production, you would use email/password or other auth methods
  static Future<User?> signInAnonymously() async {
    try {
      print('🔐 [AUTH] Signing in anonymously...');
      final userCredential = await _auth.signInAnonymously();
      print('✅ [AUTH] Signed in anonymously: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e, stackTrace) {
      print('❌ [AUTH] Failed to sign in anonymously: $e');
      print('❌ [AUTH] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Sign in with email and password
  static Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 [AUTH] Signing in with email: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ [AUTH] Signed in: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e, stackTrace) {
      print('❌ [AUTH] Failed to sign in: $e');
      print('❌ [AUTH] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Create user with email and password
  static Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 [AUTH] Creating user with email: $email');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ [AUTH] User created: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e, stackTrace) {
      print('❌ [AUTH] Failed to create user: $e');
      print('❌ [AUTH] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      print('🔐 [AUTH] Signing out...');
      await _auth.signOut();
      print('✅ [AUTH] Signed out successfully');
    } catch (e, stackTrace) {
      print('❌ [AUTH] Failed to sign out: $e');
      print('❌ [AUTH] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Ensure user is authenticated (sign in anonymously if not)
  /// This is called on app startup to ensure Firebase operations work
  static Future<User?> ensureAuthenticated() async {
    try {
      // Check if user is already authenticated
      if (_auth.currentUser != null) {
        print('✅ [AUTH] User already authenticated: ${_auth.currentUser?.uid}');
        return _auth.currentUser;
      }

      // Sign in anonymously if not authenticated
      print('⚠️ [AUTH] No user authenticated, signing in anonymously...');
      return await signInAnonymously();
    } catch (e, stackTrace) {
      print('❌ [AUTH] Failed to ensure authentication: $e');
      print('❌ [AUTH] Stack trace: $stackTrace');
      // Return null if authentication fails
      return null;
    }
  }

  /// Listen to auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}

