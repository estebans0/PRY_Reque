import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ManageUsersScreen extends StatefulWidget {
    const ManageUsersScreen({super.key});


    @override
    _ManageUsersScreen createState() => _ManageUsersScreen();
}


class _ManageUsersScreen extends State<ManageUsersScreen> {
    String searchText = '';
    UserMethods userModel = UserMethods();

    // funcion para desactivar usuarios

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
                                    style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold,),
                                ),
                                // barra de busqueda
                                const SizedBox(height: 10),
                                TextField(
                                    onChanged: (value){
                                        // hace que se reconstruya el widget cada vez que se cambie el textfield
                                        setState((){
                                            searchText = value;
                                        });
                                    },
                                    decoration: InputDecoration(hintText: 'Buscar usuario'),
                                ),
                                const SizedBox(height: 20),
                                Text('Nombre Completo'),
                                const SizedBox(height: 20),
                                _buildUserList(),
                                
                            ]
                        )
                    ),
                )
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
                        return LinearProgressIndicator();
                    } else{
                        return ListView.builder(
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index){
                                String name = snapshot.data?[index]['name'] ?? '';
                                if(searchText.isEmpty || name.toLowerCase().contains(searchText.toLowerCase())){
                                    return ListTile(                                
                                    title: Text(snapshot.data?[index]['name']),
                                    trailing: ElevatedButton(
                                        // se tiene que crear la funcion de desactivar
                                        onPressed: null,
                                        child: Text('Desactivar')
                                    )
                                    );
                                } else{
                                    return SizedBox.shrink();
                                } 
                            }
                        );
                    }
                }),
            )
        );
    }
}
