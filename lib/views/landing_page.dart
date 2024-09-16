// landing_page.dart
// import 'package:app/views/home_screen_admin.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
// import 'manage_user_screen.dart'; 

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
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
                'Proyecto 1 - Requerimientos de Software',
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 63, 119, 133), 
                    ),
                    child: Text('Log In', style: TextStyle(color: Color.fromARGB(255, 212, 209, 184)),),
                  ),
                  SizedBox(height: 20), // Espacio entre los botones
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 63, 119, 133),
                    ),
                    child: Text('Sign Up', style: TextStyle(color: Color.fromARGB(255, 212, 209, 184)),),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
