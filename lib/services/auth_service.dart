import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Handles Firebase authentication (anonymous sign-in)
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current user (null if not signed in)
  User? get currentUser => _auth.currentUser;

  /// Current user UID
  String? get uid => _auth.currentUser?.uid;

  /// Whether user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign in anonymously (no email/password needed)
  /// Returns the user UID on success, null on failure
  Future<String?> signInAnonymously() async {
    try {
      // Check if already signed in
      if (_auth.currentUser != null) {
        debugPrint('AuthService: Already signed in as ${_auth.currentUser!.uid}');
        return _auth.currentUser!.uid;
      }

      final userCredential = await _auth.signInAnonymously();
      final uid = userCredential.user?.uid;
      debugPrint('AuthService: Signed in anonymously as $uid');
      return uid;
    } catch (e) {
      debugPrint('AuthService: Anonymous sign-in failed: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    debugPrint('AuthService: Signed out');
  }

  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
