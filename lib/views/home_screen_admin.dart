import 'dart:math';

import 'package:app/views/manage_user_screen.dart';
import 'package:app/views/tab1.dart';
import 'package:app/views/tab2.dart';
import 'package:flutter/material.dart'; 

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Crowdfunding Dashboard',
//       theme: ThemeData.dark(),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        title: Text("Administración"),
        centerTitle: true,
        
        bottom: TabBar(
          controller: controller,
          tabs: [
            Text("Estadisticas"),
            Text("Proyectos"), 
            Text("Usuarios"),
            Text("Donasiones"), 
          ]
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          Tab1(),
          Tab2(),
          Tab1(),
          Tab2(),
        ]
      ), 
      floatingActionButton: Container(  
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        alignment: Alignment.bottomLeft,
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.arrow_back), 
        ) 
      ),
      
    );
  }
  
}
