// lib/views/login_screen.dart
import 'package:app/views/landing_page.dart';
import 'package:flutter/material.dart';
import '../controllers/controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
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
    // Si no esta baneado se deja entrar
    if(!await _controller.isBanned(email)){
      try {
        await _controller.login(email, password);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login exitoso'), backgroundColor: Colors.green),
        );
        if (await _controller.isAdmin(email)) {
          Navigator.pushReplacementNamed(context, '/home-admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
        

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
    } else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El usuario se encuentra baneado'), backgroundColor: Colors.red),
        );
        setState(() {
          _isLoading = false;
        });
    } 
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
                'Inicio de sesion',
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
              height: 250,
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
                const SizedBox(height: 14),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 63, 119, 133),
                        ),
                        child: const Text('Login', style: TextStyle(color: Color.fromARGB(255, 212, 209, 184)),),
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
                backgroundColor: Color.fromARGB(255, 63, 119, 133),
                child: Icon(Icons.arrow_back, color: Color.fromARGB(255, 212, 209, 184)),
              ),
            ),
          ),

        ],
      ),
    );
  }
}



