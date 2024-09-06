// lib/views/home_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../controllers/controller.dart';

class HomeScreen extends StatelessWidget {
  final Controller _controller = Controller();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _controller.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to the Home Screen!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
