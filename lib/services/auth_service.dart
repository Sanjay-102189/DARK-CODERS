import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service managing artisan authentication using Firebase Authentication (Email/Password).
class AuthService {
  final FirebaseAuth? authInstance;

  AuthService({this.authInstance});

  FirebaseAuth get auth => authInstance ?? FirebaseAuth.instance;

  User? get currentUser => auth.currentUser;

  String? get currentUserId => auth.currentUser?.uid;

  String? get currentUserEmail => auth.currentUser?.email;

  bool get isAuthenticated => auth.currentUser != null;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Signs in an artisan using email and password.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('[AuthService] Signing in artisan: $email');
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('[AuthService] Signed in successfully: ${credential.user?.uid}');
      return credential;
    } catch (e) {
      debugPrint('[AuthService] Sign in failed: $e');
      rethrow;
    }
  }

  /// Registers a new artisan with email and password.
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('[AuthService] Creating new artisan account: $email');
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('[AuthService] Account created successfully: ${credential.user?.uid}');
      return credential;
    } catch (e) {
      debugPrint('[AuthService] Sign up failed: $e');
      rethrow;
    }
  }

  /// Signs out the currently authenticated artisan.
  Future<void> signOut() async {
    try {
      debugPrint('[AuthService] Signing out current artisan');
      await auth.signOut();
    } catch (e) {
      debugPrint('[AuthService] Sign out failed: $e');
      rethrow;
    }
  }

  /// Formats user-friendly error messages from Firebase exceptions.
  static String getReadableErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email address. Please sign up first.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect password or email. Please verify and try again.';
        case 'email-already-in-use':
          return 'An account already exists with this email address. Please log in.';
        case 'weak-password':
          return 'Password must be at least 6 characters long.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This artisan account has been disabled. Please contact support.';
        case 'operation-not-allowed':
        case 'configuration-not-found':
          return 'Email/Password authentication is not yet enabled in the Firebase project console.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection and try again.';
        default:
          return error.message ?? 'Authentication error (${error.code}). Please try again.';
      }
    }
    return error.toString();
  }
}
