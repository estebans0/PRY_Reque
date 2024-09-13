// lib/views/home_screen.dart
import 'package:flutter/material.dart';
import '../controllers/controller.dart';

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

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenido a la pantalla principal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/create-project'),
              child: const Text('Crear Proyecto'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/edit-project'),
              child: const Text('Editar Proyectos'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
              child: const Text('Editar perfil'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/wallet'),
              child: const Text('Cartera Digital'),
            )
          ],
        ),
      ),
    );
  }
}
