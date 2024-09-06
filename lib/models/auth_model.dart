// lib/models/auth_model.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthModel {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Sign up with email and password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw e.toString(); // Handle error and pass it back to the controller
    }
  }

  // Log in with email and password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw e.toString(); // Handle error and pass it back to the controller
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw e.toString(); // Handle error and pass it back to the controller
    }
  }

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;
}
