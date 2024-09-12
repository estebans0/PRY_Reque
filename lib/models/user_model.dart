// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Actualiza el perfil del usuario en Firestore
  Future<void> updateUserProfile(String uid, String email, String username, String name,
                                  String profile_pic, num phone_num) async {
    await _firestore.collection('Users').doc(uid).update({
      'email': email,
      'username': username,
      'name': name,
      'profile_pic': profile_pic,
      'phone_num': phone_num,
    });
  }

  // Obtener id del usuario actual
  String getCurrentUserId() {
    return _auth.currentUser!.uid;
  }

  Future<num> getTotalDonated() async {
    var userData = getUserData();
    return userData.then((value) => value['total_donated']);
  }

  Future<num> getSupportedProjects() async {
    var userData = getUserData();
    return userData.then((value) => value['supported_projects']);
  }

  // Obtiene los datos actuales del usuario
  Future<DocumentSnapshot> getUserData() async {
    return _firestore.collection('Users').doc(getCurrentUserId()).get();
  }

  // obtener todos los usuarios registrados.
  Future<List> getUsers() async{
    List users = [];
    CollectionReference usersReference = _firestore.collection('Users');
    // trae todos los documento de la coleccion aka todos los usuarios
    QuerySnapshot queryUsers = await usersReference.get();
    queryUsers.docs.forEach((document){
      users.add(document.data());
    });
    return users;
  }
}
