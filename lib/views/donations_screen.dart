// ignore_for_file: non_constant_identifier_names, override_on_non_overriding_member

import 'package:app/models/user_model.dart';  
import 'package:flutter/material.dart';
 
class donationsPage extends StatefulWidget {
    const donationsPage({super.key});

    @override
    State<donationsPage> createState() => _donationsPage();
}


class _donationsPage extends State<donationsPage> {
  UserMethods user_model = UserMethods();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding( 

        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),// all(80), 
        child: Column( 
          children: [
            Title(
              color: Colors.black, 
              child: const Text(
                'Donaciones',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,),
              ),
            ),
            const SizedBox(height: 20),
            // Fila de buscar y filtro
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextField(
            //         // style: TextStyle(color: Colors.white),
            //         decoration: InputDecoration(
            //           hintText: 'Buscar...',
            //           // hintStyle: TextStyle(color: Colors.grey),
            //           filled: true,
            //           // fillColor: Colors.grey[800],
            //           focusColor: Color(0xFFE0E0D6),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(8.0),
            //             borderSide: BorderSide.none,
            //           ),
            //         ),
            //       ),
            //     ),
            //     SizedBox(height: 8),
            //     IconButton(
            //       // icon: Icon(Icons.filter_list, color: Colors.white),
            //       icon: Icon(Icons.filter_list),
            //       onPressed: () {
            //         // Add your filter logic here
            //       },
            //     ),
            //     IconButton(
            //       // icon: Icon(Icons.search, color: Colors.white),
            //       icon: Icon(Icons.search),
            //       onPressed: () {
            //         // Add your search logic here
            //       },
            //     ),
            //   ],
            // ),
            // SizedBox(height: 20, width: 90),
            
            // Lista de proyectos
            Expanded( 
              child: FutureBuilder(
                future: user_model.getDonations(),
                builder: (context, snapshot) {
                  
                  // Mientras se espera que los datos sean obtenidos, mostramos un indicador de carga
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());

                  } else if (snapshot.hasError) { 
                    return const Center( child: Text('Error al cargar donaciones'));

                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) { 
                    return ListView.builder(
                      itemCount: snapshot.data?.length ?? 0, 
                      itemBuilder: (context, index) {
                        var project = snapshot.data?[index];  // Accedemos al proyecto en la lista
                        String idDonation = project['idDonation'] ?? '';
                        String idProject = project['idProject'] ?? '';
                        String idUser = project['idUser'] ?? '';
                        bool is_deleted = project['is_deleted'] ?? false;
                        String projectName = project['nameProject'] ?? 'Sin informacion';
                        String userName = project['nameUser'] ?? 'Sin informacion';
                        String date = project['date'] ?? '';
                        int amount = project['amount'] ?? 0;
                        return auxBuild(idDonation, idProject, idUser, is_deleted, projectName, userName, date, amount); 

                      },
                    );
                  } else { 
                    return const Center(
                      child: Text('No hay donaciones disponibles'),
                    );
                  }
                },
              )
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget auxBuild(String idDonation, String idProject, String idUser, bool is_deleted, String projectName,  String userName, String date, int amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 140,
      // padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.grey[850],
        color:const  Color(0xFFE0E0D6),
        borderRadius: BorderRadius.circular(8.0),
        // border: Border.all(color: const Color.fromARGB(255, 29, 120, 204)),
      ),
      
      child:LayoutBuilder(
        builder: (context, Constraints) {
          if(Constraints.maxWidth < 800){
            return Column ( 
              children: [
                Column( 
                  children: [ 
                    Text(
                      'Benefactor: $userName',    
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Proyecto: $projectName',    
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monto: $amount       Fecha: $date',   
                    ),
                  ],
                ),
                
                Column( 
                  children: [
                    SizedBox(
                      width: 120,
                      child:  ElevatedButton(
                        onPressed: !is_deleted ?() async {  
                          await user_model.deactivateDonation(idDonation, idProject, idUser, amount);
                          setState(() {});
                        }: null,
                        child: const Text('Cancelar')
                      )    
                    ) 
                  ],
                ),
              ],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Benefactor: $userName    -    Proyecto: $projectName',    
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monto: $amount       Fecha: $date',   
                    ),
                    
                  ], 
                ),
                Column(
                  children: [ 
                    SizedBox(
                      width: 120,
                      child:  ElevatedButton(
                        onPressed: !is_deleted ?() async {  
                          await user_model.deactivateDonation(idDonation, idProject, idUser, amount);
                          setState(() {});
                        }: null,
                        child: const Text('Cancelar')
                      )    
                    )
                  ]
                )
              ],
            );
          }
        }
      )
      
    );
  }

}