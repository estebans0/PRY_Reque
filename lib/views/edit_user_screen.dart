// lib/views/edit_profile_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final UserMethods _userMethods = UserMethods();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumController = TextEditingController();
  final TextEditingController _profilePicController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    // Obtener los datos del usuario desde Firestore
    var userData = await _userMethods.getUserData();
    _emailController.text = userData['email'] ?? '';
    // Setear la contraseña a puntos del largo de la contraseña actual
    _passwordController.text = '•' * (userData['password']?.length ?? 0);
    _usernameController.text = userData['username'] ?? '';
    _nameController.text = userData['name'] ?? '';
    _phoneNumController.text = userData['phone_num'] != null ? userData['phone_num'].toString() : '';
    _profilePicController.text = userData['profile_pic'] ?? '';

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    String uid = _userMethods.getCurrentUserId();
    await _userMethods.updateUserProfile(uid, _emailController.text, _usernameController.text, _nameController.text,
      _profilePicController.text, num.parse(_phoneNumController.text)
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado exitosamente!'), backgroundColor: Colors.green),
    );

    setState(() {
      _isLoading = false;
    });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Agregar un campo para la imagen de perfil del usuario. Canvas circular en el centro de la pantalla con dos botones debajo de la imagen: Cambiar foto y Eliminar foto.
                  // Código:
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_profilePicController.text),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implementar la lógica para cambiar la foto de perfil
                    },
                    child: const Text('Cambiar foto'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implementar la lógica para eliminar la foto de perfil
                    },
                    child: const Text('Eliminar foto'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Correo electrónico'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                  ),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Nombre de Usuario'),
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: _phoneNumController,
                    decoration: const InputDecoration(labelText: 'Número telefónico'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Guardar Cambios'),
                  ),
                ],
              ),
            ),
    );
  }
}
