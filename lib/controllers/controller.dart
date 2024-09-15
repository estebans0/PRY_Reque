// lib/controllers/controller.dart
import '../models/auth_model.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';

class Controller {
  final AuthModel _authModel = AuthModel();
  final ProjectMethods _projectModel = ProjectMethods();
  final UserMethods _userModel = UserMethods();

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
  Future<void> updateUserProfile(String email, String username, String name, String profilePic, String phoneNum) async {
    await _userModel.updateUserProfile(getCurrentUserId(), email, username, name, profilePic, num.parse(phoneNum));
  }

  // Crear y editar proyectos
  Future<void> createProject(String name, String description, num fundingGoal, DateTime? deadline,
                              List<String> images, List<String> categories) async {
    await _projectModel.createProject(name, description, fundingGoal, deadline, images, categories);
  }

  Future<void> editProject(String projectId, String name, String description, num fundingGoal, DateTime? deadline,
                            List<String> images, List<String> categories) async {
    await _projectModel.editProject(projectId, name, description, fundingGoal, deadline, images, categories);
  }

  Future<Map<String, dynamic>> getProjectData(String projectId) async {
    return await _projectModel.getProjectData(projectId);
  }

  Future<List<String>> getCategories() async {
    return await _projectModel.getCategories();
  }

  Future<bool> isAdmin (String email) async {
    List admins = await _authModel.getAdmins();
    bool result = false;

    for (int i = 0; i < admins.length; i++) { 
      if (admins[i]['email'] == email) { 
        result = true;
      }
    }
    return result;
  }

  Future<bool> isBanned(String email) async{
    bool banned = false;
    List users = await _authModel.getUsers();
    for(var user in users){
      if(user['email'] == email && user['is_deleted']){
        banned = true;
      }
    }
    return banned;
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
