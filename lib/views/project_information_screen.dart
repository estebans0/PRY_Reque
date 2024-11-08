// project_information_screen.dart
// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controllers/controller.dart';
import 'donation_button.dart';
import '../models/project_model.dart';
import 'project_forum_screen.dart';
import '../models/wallet_model.dart';

class ProjectInformationScreen extends StatefulWidget {
  final String? projectId;
  const ProjectInformationScreen({this.projectId, super.key});

  @override
  _ProjectInformationScreenState createState() =>
      _ProjectInformationScreenState();
}

class _ProjectInformationScreenState extends State<ProjectInformationScreen> {
  final Controller _controller = Controller();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fundingGoalController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final List<String> _imagesController = [];
  final List<String> _selectedCategories = [];
  final ProjectMethods _projectMethods = ProjectMethods();
  final WalletMethods _walletMethods = WalletMethods();

  bool _isLoading = false;
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.projectId != null) {
      _loadProjectData();
      _fetchAverageRating();
    }
  }

  Future<void> _loadProjectData() async {
    if (widget.projectId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        var projectData = await _controller.getProjectData(widget.projectId!);
        _nameController.text = projectData['name'];
        _descriptionController.text = projectData['description'];
        _fundingGoalController.text = projectData['funding_goal'].toString();
        _deadlineController.text = projectData['deadline'] != null
            ? (projectData['deadline'] as Timestamp).toDate().toString()
            : '';
        _imagesController.addAll(
          (projectData['images'] as List<dynamic>)
              .map((img) => img['url'] as String)
              .toList(),
        );
        _selectedCategories.addAll(
          (projectData['categories'] as List<dynamic>)
              .map((cat) => cat as String)
              .toList(),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al cargar datos del proyecto: $e'),
              backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAverageRating() async {
    if (widget.projectId != null) {
      double rating = await _projectMethods.getAverageRating(widget.projectId!);
      setState(() {
        averageRating = rating;
      });
    }
  }

  Future<bool> _hasAccessToForum(String userId) async {
    // Verificar si el usuario es el creador del proyecto
    final projectDoc = await FirebaseFirestore.instance
        .collection('Projects')
        .doc(widget.projectId)
        .get();

    if (projectDoc.exists && projectDoc.data()?['user_id'] == userId) {
      return true;
    }

    // Verificar si el usuario ha donado al proyecto
    try {
      // Obtiene todas las donaciones del usuario
      List<Map<String, dynamic>> donations = await _walletMethods.getAllUserDonations();
      // Compara la referencia del proyecto en cada donación con la referencia actual del proyecto
      for (var donation in donations) {
        DocumentReference projectRef = donation['project_id'];
        // Compara la referencia del proyecto actual con el ID del proyecto que esperas
        if (projectRef.path == 'Projects/${widget.projectId}') {
          return true;
        }
      }
    } catch (e) {
      print('Error al verificar si el usuario ha donado al proyecto: $e');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Proyecto'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Center(
                  child: Container(
                    width: 800,
                    height: 600,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 212, 209, 184),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  readOnly: true,
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                      labelText: 'Nombre del Proyecto'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '⭐ ${averageRating.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ],
                          ),
                          TextField(
                            readOnly: true,
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                              hintText: 'Ejemplo: Este proyecto trata sobre...',
                            ),
                          ),
                          TextField(
                            readOnly: true,
                            controller: _fundingGoalController,
                            decoration: const InputDecoration(
                              labelText: 'Meta de Financiamiento',
                              hintText: 'Ejemplo: 5000',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            readOnly: true,
                            controller: _deadlineController,
                            decoration: const InputDecoration(
                              labelText: 'Fecha Límite (opcional)',
                              hintText: 'Formato: AAAA-MM-DD',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _selectedCategories.isNotEmpty
                                  ? 'Categorías actuales: ${_selectedCategories.join(', ')}'
                                  : 'No hay categorías seleccionadas',
                              style: const TextStyle(
                                  fontSize: 14, fontStyle: FontStyle.italic),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            children: _imagesController
                                .asMap()
                                .entries
                                .map((entry) {
                              String url = entry.value;
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image.network(url,
                                        width: 100, height: 100),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DonationButton(
                                projectId: widget.projectId!,
                                onDonationComplete: () {
                                  // Acción después de donar
                                },
                              ),
                              const SizedBox(width: 10),
                              FloatingActionButton(
                                heroTag: 'project_forum_button',
                                backgroundColor:
                                    const Color.fromARGB(255, 63, 119, 133),
                                onPressed: () async {
                                  final userId =
                                      await _controller.getCurrentUserId();
                                  if (await _hasAccessToForum(userId)) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProjectForumScreen(
                                                projectId: widget.projectId!),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Acceso denegado. Solo los colaboradores autorizados pueden acceder al foro interno.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                tooltip: 'Foro Interno',
                                child: const Icon(
                                  Icons.chat,
                                  color: Color.fromARGB(255, 212, 209, 184),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
