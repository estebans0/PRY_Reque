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

        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 80),// all(80), 
        child: Column( 
          children: [
            Title(
              color: Colors.black, 
              child: Text(
                'Gestión de donaciones',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,),
              ),
            ),
            SizedBox(height: 20),
            // Fila de buscar y filtro
            Row(
              children: [
                Expanded(
                  child: TextField(
                    // style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      // hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      // fillColor: Colors.grey[800],
                      focusColor: Color(0xFFE0E0D6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                IconButton(
                  // icon: Icon(Icons.filter_list, color: Colors.white),
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    // Add your filter logic here
                  },
                ),
                IconButton(
                  // icon: Icon(Icons.search, color: Colors.white),
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Add your search logic here
                  },
                ),
              ],
            ),
            SizedBox(height: 20, width: 90),
            
            // Lista de proyectos
            Expanded( 
              child: FutureBuilder(
                future: user_model.getDonations(),
                builder: (context, snapshot) {
                  
                  // Mientras se espera que los datos sean obtenidos, mostramos un indicador de carga
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());

                  } else if (snapshot.hasError) { 
                    return Center( child: Text('Error al cargar donaciones'));

                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) { 
                    return ListView.builder(
                      itemCount: snapshot.data?.length ?? 0, 
                      itemBuilder: (context, index) {
                        var project = snapshot.data?[index];  // Accedemos al proyecto en la lista
                        return ProjectTile2(
                          projectName: project['nameProject'] ?? 'Sin informacion',
                          userName: project['nameUser'] ?? 'Sin informacion',
                          date: project['date'] ?? '', 
                          amount: project['amount'] ?? 0,

                        );

                      },
                    );
                  } else { 
                    return Center(
                      child: Text('No hay proyectos disponibles'),
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
}

class ProjectTile2 extends StatelessWidget {
  final String projectName;
  final String userName;
  final String date;
  final int amount;

  // Constructor que recibe los datos
  ProjectTile2({required this.projectName,  required this.userName, required this.date, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.grey[850],
        color:const  Color(0xFFE0E0D6),
        borderRadius: BorderRadius.circular(8.0),
        // border: Border.all(color: const Color.fromARGB(255, 29, 120, 204)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Benefactor: $userName    -    Proyecto: $projectName',    
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Monto: $amount       Fecha: $date',   
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Acción de edición
            },
            style: ElevatedButton.styleFrom(
              // backgroundColor: Colors.grey[700],
            ),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
