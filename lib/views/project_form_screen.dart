// lib/views/project_form.dart
import 'package:flutter/material.dart';
import '../models/project_model.dart';

class ProjectFormScreen extends StatefulWidget {
  final String? projectId; // Si es nulo, es para crear un nuevo proyecto

  const ProjectFormScreen({this.projectId, super.key});

  @override
  _ProjectFormScreenState createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final ProjectMethods _projectMethods = ProjectMethods();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fundingGoalController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final List<String> _imagesController = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.projectId != null) {
      _loadProjectData();
    }
  }

  Future<void> _loadProjectData() async {
    setState(() {
      _isLoading = true;
    });

    var projectData = await _projectMethods.getProjectData(widget.projectId!);
    _nameController.text = projectData['name'] ?? '';
    _descriptionController.text = projectData['description'] ?? '';
    _fundingGoalController.text = projectData['funding_goal'].toString();
    _deadlineController.text = projectData['deadline'] != null ? projectData['deadline'].toDate().toString() : '';
    _imagesController.addAll(projectData['images'].map((img) => img['url']));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProject() async {
    setState(() {
      _isLoading = true;
    });

    String name = _nameController.text;
    String description = _descriptionController.text;
    num fundingGoal = num.parse(_fundingGoalController.text);
    DateTime? deadline = _deadlineController.text.isNotEmpty ? DateTime.parse(_deadlineController.text) : null;
    List imgs = _imagesController;

    if (widget.projectId == null) {
      // Crear nuevo proyecto
      await _projectMethods.createProject(name, description, fundingGoal, deadline, imgs);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyecto creado'), backgroundColor: Colors.green),
      );
    } else {
      // Editar proyecto existente
      await _projectMethods.editProject(widget.projectId!, name, description, fundingGoal, deadline, imgs);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyecto actualizado'), backgroundColor: Colors.green),
      );
    }

    Navigator.pop(context);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.projectId == null ? const Text('Crear Proyecto') : const Text('Editar Proyecto'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del Proyecto'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  TextField(
                    controller: _fundingGoalController,
                    decoration: const InputDecoration(labelText: 'Meta de Financiamiento'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _deadlineController,
                    decoration: const InputDecoration(labelText: 'Fecha Límite'),
                  ),
                  // Falta: Implementar la carga de imágenes
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveProject,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ),
    );
  }
}
