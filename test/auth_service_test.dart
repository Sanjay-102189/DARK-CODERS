import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:craftmitra/services/auth_service.dart';
import 'package:craftmitra/providers/auth_provider.dart';

// Mock User for unit testing
class FakeUser extends Fake implements User {
  @override
  final String uid;

  @override
  final String? email;

  FakeUser({required this.uid, this.email});
}

// Mock UserCredential for unit testing
class FakeUserCredential extends Fake implements UserCredential {
  final User _user;

  FakeUserCredential(this._user);

  @override
  User get user => _user;
}

// Fake AuthService for unit testing without invoking native Firebase platform channels
class FakeAuthService extends AuthService {
  User? _mockUser;
  bool shouldThrow = false;
  String throwCode = 'user-not-found';
  String throwMessage = 'No user found for that email.';

  FakeAuthService({User? initialUser}) : _mockUser = initialUser;

  @override
  User? get currentUser => _mockUser;

  @override
  String? get currentUserId => _mockUser?.uid;

  @override
  String? get currentUserEmail => _mockUser?.email;

  @override
  bool get isAuthenticated => _mockUser != null;

  @override
  Stream<User?> get authStateChanges => Stream.value(_mockUser);

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) {
      throw FirebaseAuthException(code: throwCode, message: throwMessage);
    }
    _mockUser = FakeUser(uid: 'artisan-uid-12345', email: email);
    return FakeUserCredential(_mockUser!);
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) {
      throw FirebaseAuthException(code: throwCode, message: throwMessage);
    }
    _mockUser = FakeUser(uid: 'artisan-new-uid-67890', email: email);
    return FakeUserCredential(_mockUser!);
  }

  @override
  Future<void> signOut() async {
    if (shouldThrow) {
      throw FirebaseAuthException(code: throwCode, message: throwMessage);
    }
    _mockUser = null;
  }
}

void main() {
  group('AuthService & AuthProvider Unit Tests', () {
    late FakeAuthService fakeAuthService;
    late AuthProvider authProvider;

    setUp(() {
      fakeAuthService = FakeAuthService();
      authProvider = AuthProvider(authService: fakeAuthService);
    });

    test('1. Initial unauthenticated state', () {
      expect(fakeAuthService.isAuthenticated, isFalse);
      expect(fakeAuthService.currentUser, isNull);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUid, isNull);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, isNull);
    });

    test('2. Successful email/password sign-in updates state and exposes UID', () async {
      final success = await authProvider.signIn('ramesh@artisan.in', 'password123');

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUid, equals('artisan-uid-12345'));
      expect(authProvider.email, equals('ramesh@artisan.in'));
      expect(authProvider.errorMessage, isNull);
      expect(authProvider.isLoading, isFalse);
    });

    test('3. Successful sign-up creates user and exposes new UID', () async {
      final success = await authProvider.signUp('newartisan@craftmitra.in', 'securepass');

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUid, equals('artisan-new-uid-67890'));
      expect(authProvider.email, equals('newartisan@craftmitra.in'));
    });

    test('4. Sign-out clears current user state', () async {
      await authProvider.signIn('ramesh@artisan.in', 'password123');
      expect(authProvider.isAuthenticated, isTrue);

      await authProvider.signOut();
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUid, isNull);
    });

    test('5. Error handling translates FirebaseAuthException into user-friendly message', () async {
      fakeAuthService.shouldThrow = true;
      fakeAuthService.throwCode = 'invalid-credential';
      fakeAuthService.throwMessage = 'The email or password is wrong';

      final success = await authProvider.signIn('bad@email.com', 'wrongpassword');

      expect(success, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, contains('Incorrect password or email'));
    });

    test('6. Unconfigured provider error code translates to console warning', () {
      final message = AuthService.getReadableErrorMessage(
        FirebaseAuthException(code: 'configuration-not-found'),
      );
      expect(message, contains('Email/Password authentication is not yet enabled'));
    });
  });
}
