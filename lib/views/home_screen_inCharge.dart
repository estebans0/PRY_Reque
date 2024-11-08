// ignore_for_file: file_names

import 'package:app/controllers/controller.dart'; 
import 'package:app/views/donations_screen.dart';
import 'package:app/views/manage_projects_screen.dart';
import 'package:flutter/material.dart'; 
import 'package:app/views/landing_page.dart';

class HomeScreenInCharge extends StatefulWidget {
  const HomeScreenInCharge({super.key});

  @override
  State<HomeScreenInCharge> createState () => _HomeScreenInChargeState();
}

class _HomeScreenInChargeState extends State<HomeScreenInCharge> with SingleTickerProviderStateMixin { 

  late TabController controller;
  final Controller _controller = Controller();

  @override
  void initState(){
    super.initState();
    controller = TabController(length: 2, vsync: this);
    controller.addListener((){
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      
      appBar: AppBar(
        centerTitle: true, 
        title: const Text("Encargado", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 42, 69, 105))),
        automaticallyImplyLeading: false,
        
        bottom: TabBar(
          controller: controller,
          tabs: const [
            Text("Proyectos"), 
            Text("Donaciones"), 
          ]
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: controller,
            children: const [ 
              ProjectManagementPage(),
              donationsPage(),
            ]
          ),
          //Boton de cerrar sesion
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
        ],

      ), 
    );
  }
  
}


