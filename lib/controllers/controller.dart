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
}
