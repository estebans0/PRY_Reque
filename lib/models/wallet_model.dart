import 'dart:html' as html; //Para Flutter Web, no deberia de servir en android
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Función para obtener el balance actual  del usuario
  Future<double> getDigitalCurrency() async {
    String userId = _auth.currentUser!.uid; //Obtener el UID del usuario

    //Obtiene el documento
    DocumentSnapshot userDoc =
        await _firestore.collection('Users').doc(userId).get();

    //Extrae el campo 'digital_currency' del documento del usuario
    double balance =
        (userDoc.data() as Map<String, dynamic>)['digital_currency'] ?? 0.0;

    return balance; //Retorna el balance de moneda digital
  }

  //Función para obtener las transacciones recientes del usuario (últimas 3 donaciones)
  Future<List<Map<String, dynamic>>> getRecentTransactions() async {
    String userId = _auth.currentUser!.uid;

    // Crear una referencia al documento del usuario
    DocumentReference userRef = _firestore.collection('Users').doc(userId);

    // Consultar las transacciones donde user_id coincida con el usuario actual
    QuerySnapshot transactionsSnapshot = await _firestore
        .collection('Donations')
        .where('user_id', isEqualTo: userRef)
        .where('is_deleted', isEqualTo: false) // Excluir donaciones canceladas
        .orderBy('donation_date',
            descending: true) // para ordenar por fecha de donación
        .limit(3) // Se limita a las últimas 3 donaciones
        .get();

    List<Map<String, dynamic>> transactions = [];

    // For para obtener el nombre del proyecto
    for (var doc in transactionsSnapshot.docs) {
      var transactionData = doc.data() as Map<String, dynamic>;

      // Obtener la referencia del proyecto
      DocumentReference projectRef =
          transactionData['project_id'] as DocumentReference;

      // Se Obtiene el nombre del proyecto
      DocumentSnapshot projectDoc = await projectRef.get();
      String projectName =
          (projectDoc.data() as Map<String, dynamic>)['name'] ??
              'Proyecto desconocido';

      // Se añade el nombre del proyecto a los datos de la transacción
      transactionData['project_name'] = projectName;

      // Se añade la transacción a la lista
      transactions.add(transactionData);
    }

    return transactions;
  }

  //Función para obtener todas las donaciones del usuario para la descarga
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

  // Función para descargar todas las donaciones del usuario en un archivo de texto
  Future<void> downloadDonations() async {
    try {
      // Se Obtienien todas las donaciones del usuario
      List<Map<String, dynamic>> donations = await getAllUserDonations();

      // Formatear el contenido del archivo de texto
      String content = 'Historial de Donaciones:\n\n';

      for (var donation in donations) {
        // Formato de fecha día/mes/año
        String formattedDate = _formatDate(donation['donation_date'].toDate());
        String status =
            donation['is_deleted'] == true ? 'Cancelada' : 'Completada';

        content += 'Fecha: $formattedDate\n';
        content +=
            'Donaste ${donation['amount']} al proyecto ${donation['project_name']}\n';
        content += 'Estado: $status\n\n';
      }

      // Crear un blob de texto para descargar en el navegador
      final blob = html.Blob([content], 'text/plain');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Crear un enlace temporal para forzar la descarga del archivo
      final anchor = html.AnchorElement(href: url)
        ..setAttribute(
            "download", "Historial de donaciones.txt") // Nombre del archivo
        ..click(); // Se Simula un clic en el enlace para iniciar la descarga

      // Se libera la URL del blob después de la descarga
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error al descargar donaciones: ${e.toString()}');
      throw Exception('Error al descargar donaciones');
    }
  }

  //Método auxiliar para el formato de la fecha en día/mes/año
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}:${date.second}';
  }

  //Función para actualizar el balance de digital_currency del usuario
  Future<void> updateDigitalCurrency(double amount) async {
    String userId = _auth.currentUser!.uid;

    //Obtener el balance actual
    double currentBalance = await getDigitalCurrency();

    //Actualizar el balance
    await _firestore.collection('Users').doc(userId).update({
      'digital_currency': currentBalance + amount,
    });
  }
}
