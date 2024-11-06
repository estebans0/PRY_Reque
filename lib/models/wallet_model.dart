// import 'dart:html' as html; //Para Flutter Web, no deberia de servir en android
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Función para obtener el balance actual  del usuario
  Future<int> getDigitalCurrency() async {
    String userId = _auth.currentUser!.uid; //Obtener el UID del usuario

    //Obtiene el documento
    DocumentSnapshot userDoc =
        await _firestore.collection('Users').doc(userId).get();

    //Extrae el campo 'digital_currency' del documento del usuario
    int balance =
        (userDoc.data() as Map<String, dynamic>)['digital_currency']?.toInt() ??
            0;

    return balance; //Retorna el balance de moneda digital
  }

  //Función para obtener las transacciones recientes del usuario (últimas 3 donaciones)
  Future<List<Map<String, dynamic>>> getRecentTransactions() async {
    String userId = _auth.currentUser!.uid;

    //Crea una referencia al documento del usuario
    DocumentReference userRef = _firestore.collection('Users').doc(userId);

    //Consulta las transacciones donde user_id coincida con el usuario actual
    QuerySnapshot transactionsSnapshot = await _firestore
        .collection('Donations')
        .where('user_id', isEqualTo: userRef)
        .where('is_deleted', isEqualTo: false)
        .orderBy('donation_date', descending: true)
        .limit(3)
        .get();

    List<Map<String, dynamic>> transactions = [];

    //For para obtener el nombre del proyecto
    for (var doc in transactionsSnapshot.docs) {
      var transactionData = doc.data() as Map<String, dynamic>;

      //Obtener la referencia del proyecto
      DocumentReference projectRef =
          transactionData['project_id'] as DocumentReference;

      //Se Obtiene el nombre del proyecto
      DocumentSnapshot projectDoc = await projectRef.get();
      String projectName =
          (projectDoc.data() as Map<String, dynamic>)['name'] ??
              'Proyecto desconocido';

      //Se añade el nombre del proyecto a los datos de la transacción
      transactionData['project_name'] = projectName;

      //Se añade la transacción a la lista
      transactions.add(transactionData);
    }

    return transactions;
  }

  //Función para obtener todas las donaciones del usuario
  Future<List<Map<String, dynamic>>> getAllUserDonations() async {
    String userId = _auth.currentUser!.uid;
    DocumentReference userRef = _firestore.collection('Users').doc(userId);

    //Consultar todas las donaciones donde el user_id coincida con el usuario actual
    QuerySnapshot donationsSnapshot = await _firestore
        .collection('Donations')
        .where('user_id', isEqualTo: userRef)
        .orderBy('donation_date', descending: true)
        .get();

    List<Map<String, dynamic>> donations = [];

    for (var doc in donationsSnapshot.docs) {
      var donationData = doc.data() as Map<String, dynamic>;

      //Se obtiene el nombre del proyecto
      DocumentReference projectRef =
          donationData['project_id'] as DocumentReference;
      DocumentSnapshot projectDoc = await projectRef.get();
      String projectName =
          (projectDoc.data() as Map<String, dynamic>)['name'] ??
              'Proyecto desconocido';

      //Añadir el nombre del proyecto
      donationData['project_name'] = projectName;

      //Añadir la donación a la lista
      donations.add(donationData);
    }

    return donations;
  }

  //Función para actualizar el balance de digital_currency del usuario
  Future<void> updateDigitalCurrency(double amount) async {
    String userId = _auth.currentUser!.uid;

    //Obtener el balance actual
    int currentBalance = await getDigitalCurrency();

    //Actualizar el balance
    await _firestore.collection('Users').doc(userId).update({
      'digital_currency': currentBalance + amount,
    });
  }
}
