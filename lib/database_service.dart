// lib/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
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
      print('Project created successfully.');
    } catch (e) {
      print('Failed to create project: $e');
    }
  }

  // Fetch all projects
  Stream<List<Map<String, dynamic>>> getProjects() {
    return _firestore.collection('projects').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Other CRUD operations (Update, Delete) can be added similarly
}
