// lib/controllers/controller.dart
import '../models/auth_model.dart';

class Controller {
  final AuthModel _authModel = AuthModel();

  Future<void> login(String email, String password) async {
    try {
      await _authModel.login(email, password);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _authModel.signUp(email, password);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout() async {
    try {
      await _authModel.logout();
    } catch (e) {
      throw e.toString();
    }
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
