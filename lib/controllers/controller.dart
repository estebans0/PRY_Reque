// lib/controllers/controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_model.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../models/donation_model.dart';

class Controller {
  final AuthModel _authModel = AuthModel();
  final ProjectMethods _projectModel = ProjectMethods();
  final UserMethods _userModel = UserMethods();
  final DonationMethods _donationModel = DonationMethods();
  // Autenticación
  Future<void> login(String email, String password) async {
    await _authModel.login(email, password);
  }

  Future<void> signUp(String email, String password) async {
    await _authModel.signUp(email, password);
  }

  Future<void> logout() async {
    await _authModel.logout();
  }

  // Obtener UID del usuario autenticado
  String getCurrentUserId() {
    return _authModel.getCurrentUserId();
  }

  // Obtener proyectos del usuario actual
  Future<List<Map<String, dynamic>>> getUserProjects() async {
    return await _projectModel.getProjectsByUserId(getCurrentUserId());
  }

  // Obtener datos del usuario actual
  Future<Map<String, dynamic>> getUserData() async {
    var userDoc = await _userModel.getUserData();
    return userDoc.data() as Map<String, dynamic>;
  }

  // Actualizar perfil del usuario
  Future<void> updateUserProfile(String email, String username, String name,
      String profilePic, String phoneNum) async {
    await _userModel.updateUserProfile(getCurrentUserId(), email, username,
        name, profilePic, num.parse(phoneNum));
  }

  // Crear y editar proyectos
  Future<void> createProject(String name, String description, num fundingGoal,
      DateTime? deadline, List<String> images, List<String> categories) async {
    await _projectModel.createProject(
        name, description, fundingGoal, deadline, images, categories);
  }

  Future<void> editProject(
      String projectId,
      String name,
      String description,
      num fundingGoal,
      DateTime? deadline,
      List<String> images,
      List<String> categories) async {
    await _projectModel.editProject(projectId, name, description, fundingGoal,
        deadline, images, categories);
  }

  Future<Map<String, dynamic>> getProjectData(String projectId) async {
    return await _projectModel.getProjectData(projectId);
  }

  Future<List<String>> getCategories() async {
    return await _projectModel.getCategories();
  }

  Future<bool> isAdmin(String email) async {
    List admins = await _authModel.getAdmins();
    bool result = false;

    for (int i = 0; i < admins.length; i++) {
      if (admins[i]['email'] == email) {
        result = true;
      }
    }
    return result;
  }

  Future<bool> isBanned(String email) async {
    bool banned = false;
    List users = await _authModel.getUsers();
    for (var user in users) {
      if (user['email'] == email && user['is_deleted']) {
        banned = true;
      }
    }
    return banned;
  }

  // Funciones de manejo de balance y donaciones
  Future<double> getUserBalance() async {
    // Obtener la referencia del usuario autenticado
    String userId = getCurrentUserId();
    DocumentReference userRef = _donationModel.getUserDocumentReference(userId);
    // Obtener el balance del usuario utilizando la referencia
    return await _donationModel.getDigitalCurrency(userRef);
  }

  Future<void> updateUserBalance(double amount) async {
    // Obtener la referencia del usuario autenticado
    String userId = getCurrentUserId();
    DocumentReference userRef = _donationModel.getUserDocumentReference(userId);

    // Actualizar el balance del usuario utilizando la referencia
    await _donationModel.updateDigitalCurrency(userRef, amount);
  }

  Future<void> makeDonation(String projectId, int donationAmount) async {
    // Verificar el balance actual
    double currentBalance = await getUserBalance();

    if (currentBalance >= donationAmount) {
      // Obtener las referencias del usuario y del proyecto
      String userId = getCurrentUserId();
      DocumentReference userRef =
          _donationModel.getUserDocumentReference(userId);
      DocumentReference projectRef =
          _donationModel.getProjectDocumentReference(projectId);

      // Actualizar el balance deduciendo la donación
      await updateUserBalance(-donationAmount.toDouble());

      // Registrar la donación usando las referencias del usuario y proyecto
      await _donationModel.makeDonation(userRef, projectRef, donationAmount);
    } else {
      throw Exception(
          "No tienes suficiente saldo para realizar esta donación.");
    }
  }

  //Funcion usada para crear las crendenciales de los siguientes admins
  // Future<void> creatCredencialAdmins () async {
  //   String email = 'adminJ@estudiantec.cr';
  //   String password= 'adminJ';
  //   String email2 = 'Golden@estudiantec.cr';
  //   String password2 = 'Golden1';
  //   await _authModel.createAdmin(email, password);
  //   await _authModel.createAdmin(email2, password2);
  // }
}
