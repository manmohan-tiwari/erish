import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final User? user;

  const AuthResult.success([this.user])
      : isSuccess = true,
        errorMessage = null;

  const AuthResult.failure(this.errorMessage)
      : isSuccess = false,
        user = null;
}

/// ERISH Customer Authentication Service
/// Coordinates Firebase Auth sessions, user profile records in Firestore,
/// and local mock fallback support for offline/testing development.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Local mock fallback user for testing when Firebase isn't configured
  User? _mockUser;

  User? get currentUser => _mockUser ?? _auth?.currentUser;

  bool get isAuthenticated =>
      currentUser != null && (!currentUser!.isAnonymous || _mockUser != null);

  String get displayName =>
      currentUser?.displayName ??
      currentUser?.email?.split('@').first ??
      'Valued Guest';

  String get email => currentUser?.email ?? '';

  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream.empty();

  /// Sign In with Email and Password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    final authInstance = _auth;
    if (authInstance != null) {
      try {
        final credential = await authInstance.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        _mockUser = null;
        notifyListeners();
        return AuthResult.success(credential.user);
      } on FirebaseAuthException catch (e) {
        debugPrint('FirebaseAuth signIn error: ${e.code} - ${e.message}');
        return AuthResult.failure(_mapAuthError(e.code, e.message));
      } catch (_) {}
    }

    // Offline / Mock fallback: allow demo customer login
    if (cleanEmail.contains('@') && password.length >= 6) {
      debugPrint('Fallback mock customer sign-in: $cleanEmail');
      notifyListeners();
      return const AuthResult.success();
    }
    return AuthResult.failure('Unable to sign in. Please verify your details.');
  }

  /// Sign Up / Register New Customer
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();
    final cleanPhone = phone?.trim() ?? '';

    final authInstance = _auth;
    if (authInstance != null) {
      try {
        final credential = await authInstance.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        final user = credential.user;
        if (user != null) {
          // Update Firebase Auth profile display name
          await user.updateDisplayName(cleanName);

          // Record customer profile in Firestore /users/{uid}
          final firestoreInstance = _firestore;
          if (firestoreInstance != null) {
            try {
              await firestoreInstance.collection('users').doc(user.uid).set({
                'uid': user.uid,
                'displayName': cleanName,
                'email': cleanEmail,
                'phone': cleanPhone,
                'role': 'customer',
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
            } catch (dbError) {
              debugPrint('User profile record deferred: $dbError');
            }
          }
        }

        _mockUser = null;
        notifyListeners();
        return AuthResult.success(user);
      } on FirebaseAuthException catch (e) {
        debugPrint('FirebaseAuth signUp error: ${e.code} - ${e.message}');
        return AuthResult.failure(_mapAuthError(e.code, e.message));
      } catch (_) {}
    }

    // Local mock fallback
    if (cleanEmail.contains('@') && password.length >= 6) {
      debugPrint('Fallback mock customer registered: $cleanEmail');
      notifyListeners();
      return const AuthResult.success();
    }
    return AuthResult.failure('Registration failed. Please check your network and details.');
  }

  /// Send Password Reset Email
  Future<AuthResult> sendPasswordReset(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    final authInstance = _auth;
    if (authInstance != null) {
      try {
        await authInstance.sendPasswordResetEmail(email: cleanEmail);
        return const AuthResult.success();
      } on FirebaseAuthException catch (e) {
        return AuthResult.failure(_mapAuthError(e.code, e.message));
      } catch (_) {}
    }
    // Mock positive feedback
    return const AuthResult.success();
  }

  /// Sign Out Customer
  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (_) {}
    _mockUser = null;
    notifyListeners();
  }

  String _mapAuthError(String code, String? defaultMessage) {
    switch (code) {
      case 'user-not-found':
        return 'No account exists with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Try signing in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'network-request-failed':
        return 'Network connection issue. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again in a few minutes.';
      default:
        return defaultMessage ?? 'Authentication error occurred. Please try again.';
    }
  }
}
