// lib/models/auth_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registro de usuario con Firebase Authentication y Firestore
  Future<void> signUp(String email, String password) async {
    try {
      // Crear el usuario en Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtener el UID del usuario creado
      String uid = userCredential.user!.uid;

      // Crear el perfil de usuario en Firestore usando el UID
      await _firestore.collection('Users').doc(uid).set({
        'email': email,
        'username': null,
        'name': null,
        'phone_num': null,
        'profile_pic': null,
        'total_donated': 0,
        'supported_projects': 0,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // Login de usuario
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e.toString();
    }
  }

  // Logout de usuario
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw e.toString();
    }
  }
}
