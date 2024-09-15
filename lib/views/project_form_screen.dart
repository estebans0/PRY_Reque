// project_form_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controllers/controller.dart';

class ProjectFormScreen extends StatefulWidget {
  final String? projectId;
  const ProjectFormScreen({this.projectId, super.key});
  @override
  _ProjectFormScreenState createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final Controller _controller = Controller();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fundingGoalController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final List<String> _imagesController = [];
  final List<String> _selectedCategories = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.projectId != null) {
      _loadProjectData();  // Cargar los datos si es un proyecto existente
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
            ? (projectData['deadline'] as Timestamp).toDate().toString() : '';
        // Verifica que las imágenes sean de tipo String y las añade correctamente
        _imagesController.addAll(
          (projectData['images'] as List<dynamic>).map((img) => img['url'] as String).toList(),
        );
        _selectedCategories.addAll(
          (projectData['categories'] as List<dynamic>).map((cat) => cat as String).toList(),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos del proyecto: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProject() async {
    // Verificar inputs
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty || _fundingGoalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos deben estar llenos'), backgroundColor: Colors.red),
      );
      return;
    }

    // Verificar que la meta de financiamiento sea un número
    num? fundingGoal;
    try {
      fundingGoal = num.parse(_fundingGoalController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meta de financiamiento debe ser un número válido'), backgroundColor: Colors.red),
      );
      return;
    }

    // Verificar que la fecha esté en el formato correcto si se ingresa una fecha
    DateTime? deadline;
    if (_deadlineController.text.isNotEmpty) {
      try {
        deadline = DateTime.parse(_deadlineController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fecha límite debe estar en el formato AAAA-MM-DD'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    // Mostrar SnackBar de carga mientras se guarda el proyecto
    const snackBar = SnackBar(
      content: Text('Guardando cambios...'),
      duration: Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    setState(() {
      _isLoading = true;
    });

    try {
      String name = _nameController.text;
      String description = _descriptionController.text;
      List<String> imgs = _imagesController;
      List<String> categories = _selectedCategories;

      if (widget.projectId == null) {
        // Crear nuevo proyecto
        await _controller.createProject(name, description, fundingGoal, deadline, imgs, categories);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proyecto creado exitosamente'), backgroundColor: Colors.green),
        );
      } else {
        // Editar proyecto existente
        await _controller.editProject(widget.projectId!, name, description, fundingGoal, deadline, imgs, categories);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proyecto actualizado exitosamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar cambios: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mostrar Pop-up con las categorías
  Future<void> _showCategoryDialog() async {
    final categories = await _controller.getCategories(); // Obtener categorías desde Firestore
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleccionar Categorías'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: categories.map((category) {
                    return CheckboxListTile(
                      title: Text(category),
                      value: _selectedCategories.contains(category),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar el pop-up
                    setState(() {}); // Refrescar la pantalla
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addImage() async {
    if (_imagesController.length < 5) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController urlController = TextEditingController();
          return AlertDialog(
            title: const Text("Agregar imagen"),
            content: TextField(
              controller: urlController,
              decoration: const InputDecoration(hintText: "Ingrese URL de la imagen"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo al cancelar
                },
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  String url = urlController.text;
                  if (_isValidImageUrl(url)) {
                    setState(() {
                      _imagesController.add(url);
                    });
                    Navigator.of(context).pop(); // Cerrar el diálogo al agregar la imagen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('URL de imagen no válida')),
                    );
                  }
                },
                child: const Text("Ok"),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes agregar más de 5 imágenes'))
      );
    }
  }

  bool _isValidImageUrl(String url) {
    final RegExp regex = RegExp(r"(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|jpeg|png|gif)$");
    return regex.hasMatch(url);
  }

  // Elimina la imagen seleccionada
  void _removeImage(int index) {
    setState(() {
      _imagesController.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.projectId == null
            ? const Text('Crear Proyecto')
            : const Text('Editar Proyecto'),
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
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Ejemplo: Este proyecto trata sobre...',
                    ),
                  ),
                  TextField(
                    controller: _fundingGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Meta de Financiamiento',
                      hintText: 'Ejemplo: 5000',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _deadlineController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha Límite (opcional)',
                      hintText: 'Formato: AAAA-MM-DD',
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Botón para seleccionar categorías
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Categorías'),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: _showCategoryDialog, // Mostrar diálogo de categorías
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Mostrar categorías seleccionadas
                  Text(
                    _selectedCategories.isNotEmpty
                        ? 'Categorías actuales: ${_selectedCategories.join(', ')}'
                        : 'No hay categorías seleccionadas',
                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.start,
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
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: const Icon(Icons.close, color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addImage,
                    child: const Text('Agregar imagen'),
                  ),
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
