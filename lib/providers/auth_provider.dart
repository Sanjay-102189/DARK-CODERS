import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Provider for managing artisan authentication state and operations.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _initAuthListener();
  }

  void _initAuthListener() {
    try {
      _user = _authService.currentUser;
      _authSubscription = _authService.authStateChanges.listen((User? user) {
        _user = user;
        notifyListeners();
      }, onError: (error) {
        debugPrint('[AuthProvider] Auth state stream error: $error');
      });
    } catch (e) {
      debugPrint('[AuthProvider] Notice: auth state listener initialization: $e');
    }
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  String? get currentUid => _user?.uid;
  String? get email => _user?.email;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthService get authService => _authService;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Logs in existing artisan with email and password.
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = AuthService.getReadableErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Registers a new artisan account with email and password.
  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = AuthService.getReadableErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Logs out the currently signed-in artisan.
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = AuthService.getReadableErrorMessage(e);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
