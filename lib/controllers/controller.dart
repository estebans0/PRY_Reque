// lib/controllers/controller.dart
import '../models/auth_model.dart';
import '../models/database_model.dart';

class Controller {
  final AuthModel _authModel = AuthModel();
  final DatabaseModel _databaseModel = DatabaseModel();

  // Authentication methods
  Future<void> login(String email, String password) async {
    try {
      await _authModel.loginWithEmail(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _authModel.signUpWithEmail(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authModel.logout();
  }

  // Database methods
  Future<void> createProject(String userId, String title, String description) async {
    try {
      await _databaseModel.createProject(userId, title, description);
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getProjects() {
    return _databaseModel.getProjects();
  }
}
