// lib/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Pass the error message to be displayed
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Pass the error message to be displayed
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    return e.message ?? 'An unknown error occurred.';
  }
}
