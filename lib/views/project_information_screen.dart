// project_information_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controllers/controller.dart';
import '../models/user_model.dart';
import '../models/notifications_model.dart';
import 'donation_button.dart';
import '../models/project_model.dart';
import 'project_forum_screen.dart'; // Asegúrate de tener la ruta correcta

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
  final UserMethods _userModel = UserMethods();
  final NotificationsModel _notificationModel = NotificationsModel();
  final ProjectMethods _projectMethods = ProjectMethods();

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
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 212, 209, 184),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
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
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 0, 0, 0),
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
                            children:
                                _imagesController.asMap().entries.map((entry) {
                              int index = entry.key;
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
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProjectForumScreen(
                                          projectId: widget.projectId!),
                                    ),
                                  );
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
