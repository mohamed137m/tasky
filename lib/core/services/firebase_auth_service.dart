import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasky/core/constants/key_storage.dart';
import 'package:tasky/core/services/preferences_manager.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  /// Sign In with Email and Password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        final name = user.displayName;
        if (name != null && name.isNotEmpty) {
          await PreferencesManager().setString(KeyStorage.username, name);
        }
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getReadableAuthError(e);
    }
  }

  /// Register / Create Account with Email, Password and Display Name
  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        await user.reload();
        await PreferencesManager().setString(KeyStorage.username, name.trim());
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getReadableAuthError(e);
    }
  }

  /// Send password reset link
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _getReadableAuthError(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Convert Firebase error codes into clear, friendly English messages
  String _getReadableAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'email-already-in-use':
        return 'This email is already in use';
      case 'invalid-email':
        return 'The email address is invalid';
      case 'weak-password':
        return 'The password is too weak (min 6 chars)';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'network-request-failed':
        return 'Network error, check your connection';
      default:
        return e.message ?? 'Authentication error occurred';
    }
  }
}
