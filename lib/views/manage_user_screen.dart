import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:app/views/landing_page.dart';

class ManageUsersScreen extends StatefulWidget {
    const ManageUsersScreen({super.key});

    @override
    _ManageUsersScreen createState() => _ManageUsersScreen();
}


class _ManageUsersScreen extends State<ManageUsersScreen> {
    String searchText = '';
    UserMethods userModel = UserMethods();

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Stack(
                children: [
                // el fondo
                Container(
                    color:const  Color(0xFFE0E0D6),
                ),
                // cuadro del frente
                Center(
                    child: Container(
                        width: 800,
                        height: 600,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Text(
                                    'Gestionar Usuarios',
                                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,),
                                ),
                                const Text('Nombre Completo'),
                                const SizedBox(height: 20),
                                _buildUserList(),
                                
                            ]
                        )
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
            )
        );
    }

    Widget _buildUserList(){
        return Expanded(
            child: FutureBuilder(
                future: userModel.getUsers(),
                // snapshot tendra la lista de todos los usuarios
                builder: ((content, snapshot){
                    // esperara a que cargue la respuesta de firebase
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                    } else{
                        return ListView.builder(
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index){
                                String name = snapshot.data?[index]['name'] ?? '';
                                String id = snapshot.data?[index]["docId"] ?? '';
                                return _buildListView(name, id);
                            }
                        );
                    }
                }),
            )
        );
    }

    Widget _buildListView(String name, String id){
        return FutureBuilder<bool>(
            future: userModel.isActivate(id),
            builder: (context, snapshot) {
                bool activity = snapshot.data ?? false;
                return ListTile(                                
                    title: Text(name),
                    trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [ 
                            ElevatedButton(
                                onPressed: activity ?() async{
                                    await userModel.activateUser(id);
                                    setState(() {});
                                }: null,
                                child: const Text('Activar')
                            ), 
                            const SizedBox(width: 5), 
                            ElevatedButton(
                                onPressed: !activity ?() async{
                                    // pop up para confirmar la eliminacion de un usuario
                                    showDialog(
                                        context: context,
                                        builder: (context){
                                            return AlertDialog(
                                                title: Text("¿Está seguro de desactivar a $name?"),
                                                actions: [
                                                    TextButton(
                                                        child: const Text("No"),
                                                        onPressed: () => Navigator.of(context).pop(),
                                                    ),
                                                    TextButton(
                                                        child: const Text("Sí, estoy seguro"),
                                                        onPressed: ()async{
                                                            await userModel.deactivateUser(id);
                                                            Navigator.of(context).pop();
                                                            setState(() {
                                                            });
                                                        },
                                                    ),
                                                ]
                                            );
                                        }
                                    );
                                }: null,
                                child: const Text('Desactivar')
                            )],)
                );
            }

        ); 
            
    }


}
