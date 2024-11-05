import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_model.dart';
import '../models/notifications_model.dart';

class DonationMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthModel _authModel = AuthModel();
  final NotificationsModel _notificationModel = NotificationsModel();


  String getCurrentUserId() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception("No user logged in");
    }
  }

  //Obtiene la referencia del documento del usuario
  DocumentReference getUserDocumentReference(String userId) {
    return _firestore.collection('Users').doc(userId);
  }

  //Obtiene la referencia del documento del proyecto
  DocumentReference getProjectDocumentReference(String projectId) {
    return _firestore.collection('Projects').doc(projectId);
  }

  //Función para obtener el balance de digital_currency del usuario
  Future<double> getDigitalCurrency(DocumentReference userRef) async {
    //Obtiene el documento del usuario
    DocumentSnapshot userDoc = await userRef.get();

    //Extrae el campo 'digital_currency' del documento del usuario
    double balance =
        (userDoc.data() as Map<String, dynamic>)['digital_currency'] ?? 0.0;

    return balance;
  }

  //Función para actualizar el balance del usuario
  Future<void> updateDigitalCurrency(
      DocumentReference userRef, double amount) async {
    // Obtener el balance actual
    double currentBalance = await getDigitalCurrency(userRef);

    //Actualiza el balance
    await userRef.update({
      'digital_currency': currentBalance + amount,
    });
  }

  // Función para realizar la donación
  Future<void> makeDonation(DocumentReference userRef,
      DocumentReference projectRef, int donationAmount) async {
    //Verifica si el usuario ya ha donado al proyecto
    bool hasDonatedBefore = await checkIfUserHasDonated(projectRef, userRef);

    //referencia a la colección de donaciones
    CollectionReference donations = _firestore.collection('Donations');

    //Obtiene la fecha actual para la donación
    DateTime now = DateTime.now();

    //Crea un nuevo documento en la colección de donaciones
    await donations.add({
      'amount': donationAmount,
      'donation_date': now,
      'is_deleted': false,
      'project_id': projectRef,
      'user_id': userRef,
    });

    //Actualizar el total donado en el proyecto correspondiente
    await updateProjectTotalDonated(
        projectRef, donationAmount, !hasDonatedBefore);

    //Actualizar el total donado por el usuario y los proyectos soportados si es nuevo donante
    await updateUserDonationData(userRef, donationAmount, !hasDonatedBefore);

    // Si la donacion es muy grande se notifica al administrador
    if(donationAmount > 100000){
      List admins = await _authModel.getAdmins();
      for (int i = 0; i < admins.length; i++) {
        _notificationModel.sendBigDonationEmail(admins[i]['email']);
      }
    }
  }

  //Función para verificar si el usuario ya ha donado a este proyecto
  Future<bool> checkIfUserHasDonated(
      DocumentReference projectRef, DocumentReference userRef) async {
    QuerySnapshot donationQuery = await _firestore
        .collection('Donations')
        .where('project_id', isEqualTo: projectRef)
        .where('user_id', isEqualTo: userRef)
        .get();

    return donationQuery
        .docs.isNotEmpty; //Retorna true si ya existe una donación
  }

  //Función para actualizar el total donado en el proyecto
  Future<void> updateProjectTotalDonated(
      DocumentReference projectRef, int donationAmount, bool isNewDonor) async {
    // Obtener el valor actual de 'total_donated'
    DocumentSnapshot projectDoc = await projectRef.get();
    double currentTotal =
        (projectDoc.data() as Map<String, dynamic>)['total_donated'] ?? 0.0;

    //Suma la cantidad donada al total actual
    double newTotal = currentTotal + donationAmount;

    //Actualizar el campo 'total_donated' en el proyecto
    await projectRef.update({'total_donated': newTotal});

    //Si el usuario es un nuevo donante, se actualiza el contador de donantes
    if (isNewDonor) {
      int currentDonorsCount =
          (projectDoc.data() as Map<String, dynamic>)['donors_count'] ?? 0;
      await projectRef.update({'donors_count': currentDonorsCount + 1});
    }
  }

  //Función para actualizar los datos de donaciones del usuario
  Future<void> updateUserDonationData(
      DocumentReference userRef, int donationAmount, bool isNewProject) async {
    //Obtener el valor actual de 'total_donated' del usuario
    DocumentSnapshot userDoc = await userRef.get();
    double currentTotalDonated =
        (userDoc.data() as Map<String, dynamic>)['total_donated'] ?? 0.0;

    //Sumar la cantidad donada al total actual de donaciones del usuario
    double newTotalDonated = currentTotalDonated + donationAmount;

    //Actualizar el campo 'total_donated' en el documento del usuario
    await userRef.update({'total_donated': newTotalDonated});

    //Si es la primera vez donando a este proyecto, incrementar 'supported_projects'
    if (isNewProject) {
      int currentSupportedProjects =
          (userDoc.data() as Map<String, dynamic>)['supported_projects'] ?? 0;
      await userRef
          .update({'supported_projects': currentSupportedProjects + 1});
    }
  }
}
