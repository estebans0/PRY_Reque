import 'package:app/views/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/user_model.dart';

class ManageRolesScreen extends StatefulWidget {
    const ManageRolesScreen({super.key});
    @override
    _ManageRolesScreen createState() => _ManageRolesScreen();
}

class _ManageRolesScreen extends State<ManageRolesScreen> { 
  UserMethods userMethods = UserMethods();
  List lstUsers = [];
  List <String> roles = [];

  @override
  void initState() {
    super.initState(); 
    fetchData();
  }

  Future<void> fetchData () async {
    try { 
      List auxListUsers = await userMethods.getUsers();
      roles = ['Usuario', 'Administrador', 'Analista', 'Encargado', 'Supervizor'];
      setState(() {
        lstUsers = auxListUsers; 
      });
    } catch (e) {
      print('Error al obtener los datos getion roles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text( 
            'Gestion de Roles', 
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,), 
          ),
        ),
      ), 

      body: Padding( 
        // padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),// all(80), 
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 70),// all(80), 
        


        child: Column( 
          
          children: [          

            SizedBox(height: 20),
            
            Expanded(
            
              child: lstUsers.isEmpty
                ? Center(child: CircularProgressIndicator()) // Mostrar spinner mientras se cargan los datos
                : ListView.builder(
                    itemCount: lstUsers.length,
                    itemBuilder: (context, index) {
                      // Verificar que el tipo de dato sea un Map antes de acceder a campos
                      if (lstUsers[index] is Map<String, dynamic>) {
                        var data = lstUsers[index] as Map<String, dynamic>;
                        String id   = data['docId']  ?? ''; 
                        String name = data['name']   ?? '';
                        String currentRol   = data['rol']  ?? ''; 
                        return userDataBox(context, roles, id, name, currentRol);  
                      } else {
                        return ListTile(
                          title: Text('No se han podido cargar los usuarios'),
                        );
                      }
                    },
                  ),
            ),
                       
          ]
          
      ),

      



    ),
    );
  }

  Widget userDataBox(BuildContext context, List<String> roles, String docId, String name, String currentRol) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),       
      decoration: BoxDecoration(         
        color:const  Color(0xFFE0E0D6),
        borderRadius: BorderRadius.circular(8.0),         
      ),
      child: LayoutBuilder(
        builder: (context, Constraints) {
          if (Constraints.maxWidth < 800){
            return Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ 
                  const SizedBox(height: 8),
                  Text(
                    'Nombre: $name',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ), 
                  const SizedBox(height: 8),
                  // DropdownButton para seleccionar el rol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Rol: ',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      DropdownButton <String>(
                        // iconDisabledColor: Colors.white,
                        // dropdownColor: Colors.amber,
                        // color: const Color.fromARGB(255, 1, 0, 0),
                        value: currentRol,                         
                        items: roles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (newRole) {
                          if (newRole != null) {
                            // onRoleChanged(newRole);
                            print('Cambiando el rol');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ 
                  Text(
                    'Nombre: $name',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Identificacion: $docId',  // Meta y recaudado
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
              ],
            );
          }
        },
      ),
    );
  }
}