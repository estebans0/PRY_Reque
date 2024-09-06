// lib/models/database_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new project
  Future<void> createProject(String userId, String title, String description) async {
    try {
      await _firestore.collection('projects').add({
        'userId': userId,
        'title': title,
        'description': description,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      throw e.toString(); // Handle error and pass it back to the controller
    }
  }

  // Fetch all projects
  Stream<List<Map<String, dynamic>>> getProjects() {
    try {
      return _firestore.collection('projects').snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      throw e.toString(); // Handle error and pass it back to the controller
    }
  }
}
