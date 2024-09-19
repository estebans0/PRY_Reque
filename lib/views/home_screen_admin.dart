import 'package:app/controllers/controller.dart'; 
import 'package:app/views/donations_screen.dart';
import 'package:app/views/manage_projects_screen.dart';
import 'package:app/views/manage_user_screen.dart'; 
import 'package:app/views/statistics_screen.dart'; 
import 'package:flutter/material.dart'; 


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomeScreenAdmin(),
//     );
//   }
// }


class HomeScreenAdmin extends StatefulWidget {
  const HomeScreenAdmin({super.key});

  @override
  State<HomeScreenAdmin> createState () => _HomeScreenAdminState();
}

class _HomeScreenAdminState extends State<HomeScreenAdmin> with SingleTickerProviderStateMixin { 

  late TabController controller;
  final Controller _controller = Controller();

  @override
  void initState(){
    super.initState();
    controller = TabController(length: 4, vsync: this);
    controller.addListener((){
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _controller.logout();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      
      appBar: AppBar(
        centerTitle: true, 
        title: Text("Administración", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 42, 69, 105))),
        automaticallyImplyLeading: false,
        
        bottom: TabBar(
          controller: controller,
          tabs: [
            Text("Estadisticas"),
            Text("Proyectos"), 
            Text("Usuarios"),
            Text("Donaciones"), 
          ]
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: controller,
            children: [ 
              statisticsScreen(), 
              ProjectManagementPage(),
              ManageUsersScreen(),
              donationsPage(),
            ]
          ),
          //Boton de cerrar sesion
          Positioned(
            bottom: 30,
            left: 20,
            height: 40, 
            width: 40,  
            child: Tooltip( 
              message: 'Cerrar sesion', 
              child: FloatingActionButton(
                onPressed: () =>  _logout(context),
                backgroundColor:  Color.fromARGB(255, 63, 119, 133),
                child: Icon(Icons.arrow_back, color: Color.fromARGB(255, 212, 209, 184),),
              ),
            ),
          ), 
        ],

      ), 
    );
  }
  
}


