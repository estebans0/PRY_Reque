import 'package:app/models/project_model.dart';
import 'package:app/models/user_model.dart'; 
import 'package:flutter/material.dart';


class statisticsScreen extends StatefulWidget {
    const statisticsScreen({super.key});

    @override
    State<statisticsScreen> createState() => _statisticsScreen();
}

class _statisticsScreen extends State<statisticsScreen> {
  ProjectMethods project_model = ProjectMethods();
  UserMethods user_model = UserMethods();

  // int numero = UserMethods().getNumbertDonations() as int;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0E0D6),//Colors.white38,  // Color de fondo negro
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título 'Estadísticas' fuera del cuadro
            Text(
              'Estadísticas',
              style: TextStyle(
                // color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),  // Espacio entre el título y el contenedor
            // Cuadro con estadísticas
            Container(
              constraints: BoxConstraints(
                minHeight: 200,
                maxHeight: 500,
                minWidth: 300,
                maxWidth: 500,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2), // Borde gris
                borderRadius: BorderRadius.circular(20), // Bordes redondeados
                color:  Colors.white38,
                
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Numero de usuarios:',
                        style: TextStyle(fontSize: 20),
                      ),
                      Spacer(),
                      FutureBuilder(
                        future: user_model.getNumbertUsers(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();

                          } else if (snapshot.hasError) {
                            return Text('Error', style: TextStyle(color: Colors.red));

                          } else if (snapshot.hasData) {
                            return Text( 
                              snapshot.data.toString(), 
                              style: TextStyle(fontSize: 20),
                            );
                          }
                          return Text('N/A');
                        },
                      ),
                    ]
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Numero de donaciones:',
                        // style: TextStyle(color: Colors.white, fontSize: 18),
                        style: TextStyle(fontSize: 20),
                      ),
                      Spacer(),
                      FutureBuilder(
                        future: user_model.getNumbertDonations(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();

                          } else if (snapshot.hasError) {
                            return Text('Error', style: TextStyle(color: Colors.red));

                          } else if (snapshot.hasData) {
                            return Text( 
                              snapshot.data.toString(), 
                              style: TextStyle(fontSize: 20),
                            );
                          }
                          return Text('N/A');
                        },
                      ),
                    ]
                  ), 
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Cantidad de proyectos:',
                        // style: TextStyle(color: Colors.white, fontSize: 18),
                        style: TextStyle(fontSize: 20),
                      ),
                      Spacer(),
                      FutureBuilder(
                        future: project_model.getNumberProjects(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();

                          } else if (snapshot.hasError) {
                            return Text('Error', style: TextStyle(color: Colors.red));

                          } else if (snapshot.hasData) {
                            return Text( 
                              snapshot.data.toString(), 
                              style: TextStyle(fontSize: 20),
                            );
                          }
                          return Text('N/A');
                        },
                      ),
                    ]
                  ), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
