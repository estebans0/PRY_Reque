// lib/views/home_screen.dart
import 'package:flutter/material.dart';
import '../controllers/controller.dart';
import '../views/project_form_screen.dart';

class HomeScreen extends StatelessWidget {
  final Controller _controller = Controller();

  HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await _controller.logout();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showEditProjectDialog(BuildContext context) async {
    // Obtener solo los proyectos del usuario autenticado
    final List projects = await _controller.getUserProjects();

    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes proyectos registrados para editar'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Selecciona un proyecto para editar"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(projects[index]['name']),
                  onTap: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectFormScreen(projectId: projects[index]['id']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calcular la altura usando MediaQuery
    double screenHeight = MediaQuery.of(context).size.height;
    double bottomPadding = screenHeight / 3; // Mover el contenido al 1/3 de la pantalla

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding), // Mover el contenido hacia arriba
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bienvenido a la pantalla principal',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/create-project'),
                child: const Text('Crear Proyecto'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showEditProjectDialog(context),
                child: const Text('Editar Proyectos'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                child: const Text('Editar perfil'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/wallet'),
                child: const Text('Cartera Digital'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
