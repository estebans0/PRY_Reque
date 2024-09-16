import 'package:app/models/auth_model.dart';
import 'package:app/models/firebase_options.dart';
import 'package:app/models/project_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProjectManagementPage(),
    );
  }
}


class ProjectManagementPage extends StatefulWidget {
    const ProjectManagementPage({super.key});

    @override
    State<ProjectManagementPage> createState() => _ProjectManagementPage();
}


class _ProjectManagementPage extends State<ProjectManagementPage> {
  ProjectMethods project_model = ProjectMethods();
  AuthModel auth_Model = AuthModel();
  
  List _items = []; 
  List _filteredItems = [];
  TextEditingController _searchController = TextEditingController();


  // Lista de opciones para el dropdown (filtrar por nombre o categoría)
  List<String> _filterOptions = ['nombre'];
  String _selectedFilter = 'nombre';

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterItems);
  }
  
  // Método para obtener los documentos de Firestore
  Future<void> _fetchData() async {
    try { 
      List tempList = await project_model.getProjects(); 
      List temp = await auth_Model.getCategories(); 

      // Actualizar el estado con los datos obtenidos
      setState(() {
        _items = tempList;
        _filteredItems = _items; 
        temp.forEach((element) { print('Elemento -> ${element}'); _filterOptions.add(element.toString()); },);

      });
    } catch (e) {
      print('Error al obtener los datos: $e');
    }
  }

  // Método para filtrar los elementos según el texto de búsqueda
  void _filterItems() {
    String query = _searchController.text.toLowerCase(); // Convertir la entrada a minúsculas
    // print(query);

    setState(() {
      _filteredItems = _items.where((item) {
        if (item is Map<String, dynamic>) { 
          var data = item as Map<String, dynamic>;
          // Filtrar por coincidencia en algún campo (ejemplo: 'campo1')
            // return data['name']?.toLowerCase().contains(query) ?? false;
          // Filtrar por el campo seleccionado (nombre o categoría)
          if (_selectedFilter == 'nombre') {
            print('Busqueda con nombre');
            return data['name']?.toLowerCase().contains(query) ?? false;
          } else if (_selectedFilter == 'categoría') {
            print('Busqueda con categoria');
            return data['name']?.toLowerCase().contains(query) ?? false;
          }
        }
        return false;
      }).toList();
    });
  }

  void _applyAdvancedFilter() {
    setState(() {
      _filteredItems = _items.where((item) {
        if (item is Map<String, dynamic>) {
          var data = item as Map<String, dynamic>;
          // Aquí puedes aplicar un filtro personalizado
          // Ejemplo: Filtrar donde 'campo2' contenga alguna condición
          return data['name']?.toLowerCase().contains('p') ?? false;
        }
        return false;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold( 
        // title: Text("Firebase Firestore Example"), 
      body: Padding(
        // padding: const EdgeInsets.all(60), 
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
        
        child: Column( 
          children: [
            Title(
              color: Colors.black, 
              child: Text(
                'Gestión de proyectos',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,),
              ),
            ),
            SizedBox(height: 20),
            // Fila de buscar y filtro
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar',
                        hintText: 'Buscar...',
                        focusColor: Color(0xFFE0E0D6),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), 
                  
                   // DropdownButton para seleccionar el tipo de filtro
                  IntrinsicWidth(  
                    child: DropdownButtonFormField<String>(
                      value: _selectedFilter, // Valor seleccionado por defecto
                      decoration: InputDecoration(
                        labelText: 'Filtro',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      items: _filterOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option.capitalize()), // Capitalizar texto
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFilter = newValue ?? 'nombre'; // Actualizar el filtro seleccionado
                          _filterItems(); // Aplicar el filtro después de cambiar la opción
                        });
                      },
                    ),
                  ),


                ], 
              ), 
            ),
 
            SizedBox(height: 20),
              
            // Expanded para permitir que el ListView ocupe el espacio disponible
            Expanded(
              
              child: _filteredItems.isEmpty
                  ? Center(child: CircularProgressIndicator()) // Mostrar spinner mientras se cargan los datos
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        // Verificar que el tipo de dato sea un Map antes de acceder a campos
                        if (_filteredItems[index] is Map<String, dynamic>) {
                          var data = _filteredItems[index] as Map<String, dynamic>;
                          return ProjectTile( 
                            titulo:     data['name'] ?? 'Sin título',
                            meta:       data['funding_goal'] ?? 0,  
                            recaudado:  data['total_donated'] ?? 0,
                          );
                        } else {
                          return ListTile(
                            title: Text('Elemento no reconocido'),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      )
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class ProjectTile extends StatelessWidget {
  final String titulo;
  final int meta;
  final int recaudado;

  // Constructor que recibe los datos
  ProjectTile({required this.titulo, required this.meta, required this.recaudado});

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
                titulo,  // Título del proyecto
                // style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Meta: $meta  Recaudado: $recaudado',  // Meta y recaudado
                // style: TextStyle(color: const Color.fromARGB(255, 209, 45, 45)),
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
            child: Text('Editar'),
          ),
        ],
      ),
    );
  }
}
