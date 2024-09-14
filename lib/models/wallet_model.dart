import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Función para obtener el balance actual de digital_currency del usuario
  Future<double> getDigitalCurrency() async {
    String userId =
        _auth.currentUser!.uid; // Obtener el UID del usuario autenticado

    // Obtener el documento del usuario desde Firestore
    DocumentSnapshot userDoc =
        await _firestore.collection('Users').doc(userId).get();

    // Extraer el campo 'digital_currency' del documento del usuario
    double balance =
        (userDoc.data() as Map<String, dynamic>)['digital_currency'] ?? 0.0;

    return balance; // Retornar el balance de moneda digital
  }

  // Función para actualizar el balance de digital_currency del usuario
  Future<void> updateDigitalCurrency(double amount) async {
    String userId =
        _auth.currentUser!.uid; // Obtener el UID del usuario autenticado

    // Obtener el balance actual
    double currentBalance = await getDigitalCurrency();

    // Actualizar el balance en Firestore sumando la nueva cantidad
    await _firestore.collection('Users').doc(userId).update({
      'digital_currency': currentBalance + amount,
    });
  }
}
