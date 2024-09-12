// lib/views/login_screen.dart
import 'package:flutter/material.dart';
import '../controllers/controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Controller _controller = Controller();

  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await _controller.login(email, password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login exitoso'), backgroundColor: Colors.green),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (e.toString().contains('invalid-credential')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email o contraseña incorrecta'), backgroundColor: Colors.red),
        );
      } else if (e.toString().contains('invalid-email')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email incorrecto'), backgroundColor: Colors.red),
        );
      } else if (e.toString().contains('missing-password')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe ingresar una contraseña'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
