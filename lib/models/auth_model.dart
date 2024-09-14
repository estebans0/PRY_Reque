// lib/models/auth_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  //Solucion temporal creacion de administradores
  // Future<void> createAdmin(String email, String password) async{
  //   try{
  //     // Crear un admin en Firebase Authentication
  //     UserCredential adminCredential = await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //   }catch(e){
  //     print(e.toString());
  //   }
  // }

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
      
      //Esto se agrega para evitar error al consultar usuarios
      String nameTemp = email.replaceAll('@estudiantec.cr', '').replaceAll('@itcr.ac.cr', '');

      // Crear el perfil de usuario en Firestore usando el UID
      await _firestore.collection('Users').doc(uid).set({
        'email': email,
        'username': null,
        'name': nameTemp,
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

  // Retorna una lista con todos los usuarios
  Future<List> getUsers() async {
    List users = [];
    CollectionReference collectionReferenceUsers = _firestore.collection('Users');
    
    QuerySnapshot queryAdmin = await collectionReferenceUsers.get();
    queryAdmin.docs.forEach ((User){
      users.add(User.data());
      
    });

    return users;
  }

  // Retorna una lista con todos los administradores 
  Future<List> getAdmins () async {
    List admins = [];
    CollectionReference collectionReferenceAdmins = _firestore.collection('admin');
    
    QuerySnapshot queryAdmin = await collectionReferenceAdmins.get();
    queryAdmin.docs.forEach ((admin){
      admins.add(admin.data());
      
    });

    return admins;
  }

  


}