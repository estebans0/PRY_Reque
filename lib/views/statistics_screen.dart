import 'package:app/models/project_model.dart';
import 'package:app/models/user_model.dart'; 
import 'package:flutter/material.dart';
import 'package:app/views/landing_page.dart';


class StatisticsScreen extends StatefulWidget {
    const StatisticsScreen({super.key});

    @override
    State<StatisticsScreen> createState() => _StatisticsScreen();
}

class _StatisticsScreen extends State<StatisticsScreen> {
  ProjectMethods project_model = ProjectMethods();
  UserMethods user_model = UserMethods();

  // int numero = UserMethods().getNumbertDonations() as int;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text( 
            'Estadísticas', 
            style: TextStyle(color: Color.fromARGB(255, 63, 119, 133), fontSize: 30, fontWeight: FontWeight.bold,), 
          ),
        ),
      ),
       
      body: Stack(
        children: [

          // Título 'Estadísticas' fuera del cuadro
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
                backgroundColor: Color.fromARGB(255, 63, 119, 133),
                child: Icon(Icons.arrow_back, color: Color.fromARGB(255, 212, 209, 184)),
              ),
            ),
          ),
        
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [                 
                
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
                    //border: Border.all(color: Color(0xFFE0E0D6), width: 2), // Borde gris
                    borderRadius: BorderRadius.circular(20), // Bordes redondeados
                    color:  Color(0xFFE0E0D6),
                    
                    
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


        ]
      ),


    );
  }
}
