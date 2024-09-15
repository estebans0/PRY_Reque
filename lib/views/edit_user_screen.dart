// edit_user_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool _isPasswordVisible = false;  // Toggle de visibilidad de la contraseña
  String currentPasswordLength = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    var userData = await _userMethods.getUserData();
    _emailController.text = userData['email'] ?? '';
    _usernameController.text = userData['username'] ?? '';
    _nameController.text = userData['name'] ?? '';
    _phoneNumController.text = userData['phone_num'] != null ? userData['phone_num'].toString() : '';
    _profilePicController.text = userData['profile_pic'] ?? '';

    // Contraseña no puede ser recuperada, así que establecemos el número de bullet points
    _setPasswordLengthIndicator();

    setState(() {
      _isLoading = false;
    });
  }

  // Establece los bullet points de la contraseña según la longitud
  void _setPasswordLengthIndicator() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentPasswordLength = '•' * (user.email?.length ?? 0);  // Simulamos la longitud con bullets
      _passwordController.text = currentPasswordLength;
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    String uid = _userMethods.getCurrentUserId();
    await _userMethods.updateUserProfile(
      uid,
      _emailController.text,
      _usernameController.text,
      _nameController.text,
      _profilePicController.text,
      num.parse(_phoneNumController.text)
    );

    // Si la contraseña fue cambiada (no es igual a los bullet points), actualizamos la contraseña
    if (_passwordController.text != currentPasswordLength) {
      await _updatePassword(_passwordController.text);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado exitosamente!'), backgroundColor: Colors.green),
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updatePassword(String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada exitosamente!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar contraseña: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _changeProfilePicture() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cambiar Foto de Perfil"),
          content: TextField(
            controller: _profilePicController,
            decoration: const InputDecoration(hintText: "Ingrese URL de la imagen"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Ok"),
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteProfilePicture() {
    setState(() {
      _profilePicController.clear();
    });
  }

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
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profilePicController.text.isNotEmpty
                        ? NetworkImage(_profilePicController.text)
                        : null,
                    child: _profilePicController.text.isEmpty ? const Icon(Icons.person, size: 50) : null,
                  ),
                  ElevatedButton(
                    onPressed: _changeProfilePicture,
                    child: const Text('Cambiar Foto'),
                  ),
                  ElevatedButton(
                    onPressed: _deleteProfilePicture,
                    child: const Text('Eliminar Foto'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Correo electrónico'),
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
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: !_isPasswordVisible, // Toggle de visibilidad
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _isPasswordVisible,
                        onChanged: (value) {
                          setState(() {
                            _isPasswordVisible = value!;
                          });
                        },
                      ),
                      const Text("Mostrar Contraseña"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Guardar Cambios'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50), // Botón centrado
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
