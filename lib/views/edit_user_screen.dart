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
  bool _isPasswordFieldClicked = false;  // Para controlar si se hizo clic en el campo de contraseña
  String defaultPasswordPlaceholder = '••••••'; // 6 bullet points como marcador de posición
  String currentPasswordLength = '';
  String originalEmail = '';  // Para almacenar el email original

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _passwordController.text = defaultPasswordPlaceholder; // Establecer 6 bullet points por defecto
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    var userData = await _userMethods.getUserData();
    _emailController.text = userData['email'] ?? '';
    _usernameController.text = userData['username'] ?? '';
    _nameController.text = userData['name'] ?? '';
    _phoneNumController.text = userData['phone_num'] != null
        ? userData['phone_num'].toString()
        : '';
    _profilePicController.text = userData['profile_pic'] ?? '';
    originalEmail = _emailController.text;  // Almacenar el email original para compararlo más tarde

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    // Validar email
    if (!_emailController.text.endsWith('@estudiantec.cr') && !_emailController.text.endsWith('@itcr.ac.cr')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El correo debe ser del dominio @estudiantec.cr o @itcr.ac.cr'), backgroundColor: Colors.red),
      );
      return;
    }

    // Validar el número de teléfono
    if (_phoneNumController.text.isNotEmpty && _phoneNumController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El número de teléfono debe tener al menos 8 dígitos'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_passwordController.text.isNotEmpty && _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres'), backgroundColor: Colors.red),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Guardando cambios...'), duration: Duration(seconds: 5)),
    );

    setState(() {
      _isLoading = true;
    });

    String uid = _userMethods.getCurrentUserId();

    try {
      // Si el email ha cambiado, también actualizar en Firebase Authentication
      if (_emailController.text != originalEmail) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.verifyBeforeUpdateEmail(_emailController.text); // Actualizar email en Firebase Auth
        }
      }

      // Actualizar el perfil del usuario en Firestore
      await _userMethods.updateUserProfile(
        uid,
        _emailController.text,
        _usernameController.text,
        _nameController.text,
        _profilePicController.text,
        num.parse(_phoneNumController.text),
      );

      // Si la contraseña fue cambiada (no es igual a los bullet points), actualizar la contraseña
      if (_passwordController.text != defaultPasswordPlaceholder) {
        await _updatePassword(_passwordController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado exitosamente!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el perfil: $e'), backgroundColor: Colors.red),
    );
    } finally {
      setState(() {
        _isLoading = false;
    });
    }
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

  // Limpia el campo de contraseña cuando se hace clic en él
  void _onPasswordFieldTap() {
    if (!_isPasswordFieldClicked) {
      setState(() {
        _passwordController.clear();
        _isPasswordFieldClicked = true;
      });
    }
  }

  // Vuelve a los 6 bullet points si el campo de contraseña queda vacío y pierde el foco
  void _onPasswordFieldFocusLost() {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordController.text = defaultPasswordPlaceholder;
        _isPasswordFieldClicked = false;
        _isPasswordVisible = false;  // Ocultar el toggle de mostrar contraseña si no se ingresó nada
      });
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
    return GestureDetector(
      onTap: () {
        // Cierra el teclado al hacer clic fuera de los campos
        FocusScope.of(context).unfocus();
        _onPasswordFieldFocusLost(); // Verifica si se debe volver a los bullet points
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Editar Perfil')),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                // cuadro del frente
                Center(
                  child: Container(
                    width: 800,
                    height: 600,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 212, 209, 184), //fromRGBO(212, 209, 184, 50),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _profilePicController.text.isNotEmpty
                              ? NetworkImage(_profilePicController.text)
                              : null,
                          child: _profilePicController.text.isEmpty
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(height: 5),
                        // Botones 'Cambiar Foto' y 'Eliminar Foto' centrados y con separación
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _changeProfilePicture,
                              child: const Text('Cambiar foto'),
                            ),
                            const SizedBox(width: 5),
                            ElevatedButton(
                              onPressed: _deleteProfilePicture,
                              child: const Text('Eliminar foto'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            hintText: 'Ejemplo: usuario@estudiantec.cr',
                          ),
                        ),
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(labelText: 'Nombre de Usuario'),
                        ),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Nombre Completo'),
                        ),
                        TextField(
                          controller: _phoneNumController,
                          decoration: const InputDecoration(
                            labelText: 'Número de Teléfono',
                            hintText: 'Ejemplo: 11111111',
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            hintText: 'La contraseña debe tener un mínimo de 6 caracteres',
                          ),
                          obscureText: !_isPasswordVisible,
                          onTap: _onPasswordFieldTap,
                          onEditingComplete: _onPasswordFieldFocusLost,
                        ),
                        Visibility(
                          visible: _passwordController.text.isNotEmpty && _passwordController.text != defaultPasswordPlaceholder,
                          child: Row(
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
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50), // Botón centrado
                          ),
                          child: const Text('Guardar Cambios'),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              ],
          ),
      ),
    );
  }
}
