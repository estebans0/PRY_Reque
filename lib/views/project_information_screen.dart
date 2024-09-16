// project_form_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controllers/controller.dart';
import '../models/user_model.dart';
import '../models/notifications_model.dart';
import 'donation_button.dart';

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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.projectId != null) {
      _loadProjectData(); // Cargar los datos de un proyecto existente
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
        // Verifica que las imágenes sean de tipo String y las añade correctamente
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver Proyecto'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    readOnly: true,
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Nombre del Proyecto'),
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
                  // Mostrar categorías seleccionadas
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
                    children: _imagesController.asMap().entries.map((entry) {
                      int index = entry.key;
                      String url = entry.value;
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.network(url, width: 100, height: 100),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: DonationButton(
                      projectId: widget.projectId!,
                      onDonationComplete: () {
                        //Aca se puede agregar algo por si no se refrescan los datos del proyecto al donar
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
