// lib/views/signup_screen.dart
import 'package:app/views/landing_page.dart';
import 'package:flutter/material.dart';
import '../controllers/controller.dart';
import '../models/notifications_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState2 createState() => _SignupScreenState2();
}


class _SignupScreenState2 extends State<SignupScreen> { 
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Controller _controller = Controller();
  final NotificationsModel _notificationModel = NotificationsModel();

  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    // Validacion de dominio email
    if (!_isValidDomain(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El correo debe ser del dominio estudiantec.cr o itcr.ac.cr'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Validar longitud de contraseña
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await _controller.signUp(email, password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso'), backgroundColor: Colors.green),
      );
      // una vez hecho el registro exitoso se manda el correo de notificacion
      _notificationModel.sendRegisterEmail(email);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isValidDomain(String email) {
    return email.endsWith('@estudiantec.cr') || email.endsWith('@itcr.ac.cr');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Posiciona y centra el título
          Positioned(
            top: 50, // Cambia este valor para ajustar la posición vertical
            left: 0,
            right: 0, // Para centrar el texto horizontalmente
            child: Center(
              child: Text(
                'Registrarse',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 42, 69, 105), // rgb(42, 69, 105)
                ),
                textAlign: TextAlign.center, // Centrar el texto
              ),
            ),
          ),
          // Centro de la pantalla con botones dentro de un cuadro
          Center(
            child: Container(
              width: 300,
              height: 200,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 212, 209, 184), //fromRGBO(212, 209, 184, 50),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
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
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 63, 119, 133),
                          ),
                          child: const Text('Sign Up', style: TextStyle(color: Color.fromARGB(255, 212, 209, 184)),),
                        ),
                  
                ],
              ),
            ),
          ),

          Positioned(
            top: 30,
            left: 20,
            height: 40, 
            width: 40, 
            child: Tooltip( 
              message: 'Volver', 
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LandingPage()),
                  );
                }, 
                child: Icon(Icons.arrow_back),
                backgroundColor: Color(0xFFE0E0D6),
              ),
            ),
          ),

        ],
      ),
    );
  }
}