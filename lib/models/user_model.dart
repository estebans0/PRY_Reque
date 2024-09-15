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

  // Retorna la cantidad de usuarios.
  Future<int> getNumbertUsers() async{
    List users = [];
    CollectionReference usersReference = _firestore.collection('Users');
    // trae todos los documento de la coleccion aka todos los usuarios
    QuerySnapshot queryUsers = await usersReference.get();
    queryUsers.docs.forEach((document){
      users.add(document.data());
    });
    return users.length;
  }
 
  // Retorna la cantidad de donaciones.
  Future<int> getNumbertDonations() async{
    List donations = [];
    CollectionReference donationsReference = _firestore.collection('Donations'); 

    QuerySnapshot queryDonations = await donationsReference.get();
    queryDonations.docs.forEach((donation){
      donations.add(donation.data());
    });
    return donations.length;
  }

  // Función auxiliar para asegurarse de que los valores tengan dos dígitos
  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  // Función para convertir Timestamp a String
  String formatTimestamp(Timestamp timestamp) {
    // Convertir Timestamp a DateTime
    DateTime dateTime = timestamp.toDate();

    // Formatear DateTime a una cadena similar al formato de Firestore 
    String formattedDate = "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} "
        "${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:${_twoDigits(dateTime.second)}";

    return formattedDate;
  }

  
  // Retorna todas las donaciones.
  Future<List> getDonations() async {

    List donations = [];
    // Obtener todas las donaciones
    QuerySnapshot donaciones = await _firestore.collection('Donations').get();

    // Recorrer las donaciones obtenidas
    for (QueryDocumentSnapshot donacionDoc in donaciones.docs) { 
 
      DocumentReference useRef = donacionDoc.get('user_id');
      DocumentSnapshot userSnap = await useRef.get();
      DocumentReference projectRef = donacionDoc.get('project_id');
      DocumentSnapshot projectSnap = await projectRef.get();

      if (userSnap.exists && projectSnap.exists) {  

        donations.add(
          {
            'nameUser': userSnap['name'],
            'nameProject': projectSnap['name'],
            'amount': donacionDoc['amount'],
            'date': formatTimestamp(donacionDoc['donation_date'])
          } 
        );
        
      } else {
        print('El documento de usuario no existe para la orden.');
      }  
    }
    return donations;
}

}
