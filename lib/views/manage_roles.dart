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
      roles = ['Usuario', 'Administrador', 'Analista', 'Encargado', 'Supervisor'];
      setState(() {
        lstUsers = auxListUsers; 
      });
    } catch (e) {
      print('Error al obtener los datos getion roles: $e');
    }
  }

  Future<void> updateUserRole(String docId, String newRole, int index) async {
    setState(() {
      lstUsers[index]['rol'] = newRole;
    });
     
    await userMethods.changeUserRol(docId, newRole);     
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text( 
            'Gestion de Roles', 
            style: TextStyle(color: Color.fromARGB(255, 63, 119, 133), fontSize: 30, fontWeight: FontWeight.bold,), 
          ),
        ),
      ), 

      body: Stack( 
        
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 70),// all(80),

            child: Column( 
              
              children: [          

                const SizedBox(height: 20),
                
                Expanded(
                
                  child: lstUsers.isEmpty
                    ? const Center(child: CircularProgressIndicator()) // Mostrar spinner mientras se cargan los datos
                    : ListView.builder(
                        itemCount: lstUsers.length,
                        itemBuilder: (context, index) {
                          // Verificar que el tipo de dato sea un Map antes de acceder a campos
                          if (lstUsers[index] is Map<String, dynamic>) {
                            var data = lstUsers[index] as Map<String, dynamic>;
                            String id   = data['docId']  ?? ''; 
                            String name = data['name']   ?? '';
                            String currentRol   = data['rol']  ?? ''; 
                            return userDataBox(
                              context, 
                              roles, 
                              id, 
                              name, 
                              currentRol, 
                              (newRol) {updateUserRole(id, newRol, index);}
                            );  
                          } else {
                            return const ListTile(
                              title: Text('No se han podido cargar los usuarios'),
                            );
                          }
                        },
                      ),
                ),
                          
              ]
              
            ),
          ),

          Positioned(
            top: 35,
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
                backgroundColor: const Color.fromARGB(255, 63, 119, 133),
                child: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 212, 209, 184)),
              ),
            ),
          ),

        ] 
           
      ),
 
    );
  }

  Widget userDataBox(BuildContext context, List<String> roles, String docId, String name, String currentRol, Function(String) onRoleChanged) {
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
                    style: const TextStyle(color: Color.fromARGB(255, 63, 119, 133), fontSize: 14, fontWeight: FontWeight.bold),
                  ), 
                  const SizedBox(height: 8),
                  // DropdownButton para seleccionar el rol
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Rol: ',
                        style: TextStyle(color: Color.fromARGB(255, 63, 119, 133), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      DropdownButton <String>( 
                        value: currentRol,  
                        // style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                        dropdownColor: const Color.fromARGB(255, 224, 224, 214), 

                        items: roles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(
                              role,
                              style: const TextStyle(color: Color.fromARGB(255, 63, 119, 133), fontSize: 14, fontWeight: FontWeight.bold),
                            ), 
                          );
                        }).toList(),
                        onChanged: (newRole) {
                          if (newRole != null) {
                            onRoleChanged(newRole);
                            // print('Cambiando el rol de mi amigo: $name');
                            // print('El nuevo rol es: $newRole');
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
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Identificacion: $docId',  // Meta y recaudado
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
