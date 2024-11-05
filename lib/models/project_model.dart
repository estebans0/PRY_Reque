// lib/models/project_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_model.dart';
import '../models/notifications_model.dart';


class ProjectMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthModel _authModel = AuthModel();
  final NotificationsModel _notificationModel = NotificationsModel();


  // Crear un nuevo proyecto
  Future<void> createProject(String name, String description, num fundingGoal, DateTime? deadline,
                              List<String> images, List<String> categories) async {
    String userId = _auth.currentUser!.uid;

    // Revisar actividad sospecha
    await checkSus(name);

    await _firestore.collection('Projects').add({
      'user_id': userId, // UID del usuario que creó el proyecto
      'name': name,
      'description': description,
      'funding_goal': fundingGoal,
      'deadline': deadline != null ? Timestamp.fromDate(deadline) : null,
      'total_donated': 0,
      'donors_count': 0,
      'views_count': 0,
      'images': images.map((img) => {'url': img}).toList(),
      'is_deleted' : false,
      'categories': categories,
      'createdAt': Timestamp.now(),
    });
  }

  // Editar un proyecto existente
  Future<void> editProject(String projectId, String name, String description, num fundingGoal, DateTime? deadline,
                            List<String> images, List<String> categories) async {

    // Revisar actividad sospecha
    await checkSus(name);

    await _firestore.collection('Projects').doc(projectId).update({
      'name': name,
      'description': description,
      'funding_goal': fundingGoal,
      'deadline': deadline != null ? Timestamp.fromDate(deadline) : null,
      'images': images.map((img) => {'url': img}).toList(),
      'categories': categories,
    });
  }

  // Obtener los proyectos del usuario actual por UID
  Future<List<Map<String, dynamic>>> getProjectsByUserId(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('Projects')
        .where('user_id', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Incluir el ID del proyecto
      return data;
    }).toList();
  }

  // Obtener datos de un proyecto específico
  Future<Map<String, dynamic>> getProjectData(String projectId) async {
    DocumentSnapshot projectDoc = await _firestore.collection('Projects').doc(projectId).get();
    Map<String, dynamic> projectData = projectDoc.data() as Map<String, dynamic>;
    projectData['id'] = projectDoc.id;

    return projectData;
  }

  Future<List<String>> getCategories() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('CategoriaPry').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  // Retorna una lista con todos los proyectos activos
  Future<List> getProjects () async {
    List projects = []; 
    CollectionReference collectionReferenceProjects = _firestore.collection('Projects');
    
    QuerySnapshot queryProject = await collectionReferenceProjects.where('is_deleted', isEqualTo : false).get();

    for (var document in queryProject.docs) {
      final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      data['id'] = document.id; // Incluir el ID del proyecto
      // Cada vez que se obtenga todos los proyectos se revisa si estan cerca del fecha limite para mandar la noti
      await checkDateLimit(data);
      projects.add(data);
    }
    return projects;
  }

  Future<void> checkDateLimit(Map<String, dynamic> project) async{
    // Se notificaran de proyectos a tres dias de vencer
    const int daysToDeadline = 3;

    // Obtener la fecha límite del proyecto 
    DateTime? deadline = project['deadline']?.toDate(); 
    if (deadline != null) {
      DateTime currentDate = DateTime.now();
      Duration difference = deadline.difference(currentDate);

      if (difference.inDays <= daysToDeadline && difference.inDays.isNegative == false) {
        List admins = await _authModel.getAdmins();
        for (int i = 0; i < admins.length; i++) {
          _notificationModel.sendDateLimitEmail(admins[i]['email']);
        }
      }
    }
  }

  // Se considerara como actividad sospechosa si dos proyectos se llaman igual al crear o editar el proyecto
  Future<void> checkSus(String name) async {
    CollectionReference collectionReferenceProjects = _firestore.collection('Projects');

    QuerySnapshot queryProject = await collectionReferenceProjects.where('name', isEqualTo : name).get();
    if (queryProject != null){
      List admins = await _authModel.getAdmins();
      for (int i = 0; i < admins.length; i++) {
        _notificationModel.sendSusEmail(admins[i]['email']);
      }
    }
    


  }


  

  // Retorna la cantidad de proyectos activos
  Future<int> getNumberProjects () async {
    List projects = []; 
    CollectionReference collectionReferenceProjects = _firestore.collection('Projects');
    
    QuerySnapshot queryProject = await collectionReferenceProjects.where('is_deleted', isEqualTo : false).get();
    for (var project in queryProject.docs) {
      projects.add(project.data());
    }
    return projects.length;
    // return 'OH';
  }
}
