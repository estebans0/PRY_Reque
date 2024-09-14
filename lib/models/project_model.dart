// lib/models/project_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProjectMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crear un nuevo proyecto
  Future<void> createProject(String name, String description, num funding_goal, DateTime? deadline, List imgs) async {
    String userId = _auth.currentUser!.uid;

    await _firestore.collection('Projects').add({
      'user_id': _firestore.collection('Users').doc(userId), // Referencia al usuario que creó el proyecto
      'name': name,
      'description': description,
      'funding_goal': funding_goal,
      'deadline': deadline != null ? Timestamp.fromDate(deadline) : null,
      'total_donated': 0,
      'donors_count': 0,
      'views_count': 0,
      // Subcollection Images: Guardar las imágenes del proyecto
      'images': imgs.map((img) => {'url': img}).toList(),
      // Subcollection Announcements: Guardar los anuncios del creador a sus donantes, empieza vacío
      'announcements': [],
    });
  }

  // Editar un proyecto existente
  Future<void> editProject(String projectId, String name, String description, num funding_goal, DateTime? deadline, List imgs) async {
    await _firestore.collection('Projects').doc(projectId).update({
      'name': name,
      'description': description,
      'funding_goal': funding_goal,
      'deadline': deadline != null ? Timestamp.fromDate(deadline) : null,
      'images': imgs.map((img) => {'url': img}).toList(),
    });
  }

  // Obtener datos de un proyecto específico, incluyendo sus imágenes (subcollection 'Images')
  Future<Map<String, dynamic>> getProjectData(String projectId) async {
    DocumentSnapshot projectDoc = await _firestore.collection('Projects').doc(projectId).get();
    Map<String, dynamic> projectData = projectDoc.data() as Map<String, dynamic>;
    projectData['id'] = projectDoc.id;

    // Obtener las imágenes del proyecto
    QuerySnapshot imgsQuery = await _firestore.collection('Projects').doc(projectId).collection('Images').get();
    projectData['images'] = imgsQuery.docs.map((img) => img.data()).toList();

    return projectData;
  }


  // Retorna una lista con todos los proyectos 
  Future<List> getProjects () async {
    List projects = [];
    CollectionReference collectionReferenceProjects = _firestore.collection('Projects');
    
    QuerySnapshot queryProject = await collectionReferenceProjects.get();
    queryProject.docs.forEach ((project){
      projects.add(project.data());
      
    });

    return projects;
  }

  // Retorna la cantidad de proyectos 
  Future<int> getNumberProjects () async {
    List projects = [];
    CollectionReference collectionReferenceProjects = _firestore.collection('Projects');
    
    QuerySnapshot queryProject = await collectionReferenceProjects.get();
    queryProject.docs.forEach ((project){
      projects.add(project.data());
    });
    return projects.length;
    // return 'OH';
  }

}
