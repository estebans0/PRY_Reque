// landing_page.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'manage_user_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyecto 1 - Requerimientos de Software'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Log In'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              child: const Text('Sign Up'),
            ),
            
            const SizedBox(height: 20),
            
            // solo para ir probando lo de gestion de usuarios
            // luego se agrega a la pantalla principal del admin
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
                );
              },
              child: const Text('Gestion de usuarios'),
            ),
          
          ],
        ),
      ),
    );
  }
}
