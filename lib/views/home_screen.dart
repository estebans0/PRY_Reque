// lib/views/home_screen.dart
import 'package:app/models/auth_model.dart';
import 'package:app/models/project_model.dart';
import 'package:flutter/material.dart';
import '../controllers/controller.dart';
import '../views/project_form_screen.dart';
import '../views/project_information_screen.dart';

class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  final Controller _controller = Controller();
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

  Future<void> _showEditProjectDialog(BuildContext context) async {
    // Obtener solo los proyectos del usuario autenticado
    final List projects = await _controller.getUserProjects();

    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes proyectos registrados para editar'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Selecciona un proyecto para editar"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(projects[index]['name']),
                  onTap: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectFormScreen(projectId: projects[index]['id']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text("Cancelar"),
            ),
          ],
        );
      },
    );
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
        temp.forEach((element) { _filterOptions.add(element.toString()); },);

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
          if (_selectedFilter == 'nombre') {
            //print('Busqueda con nombre');
            return data['name']?.toLowerCase().contains(query) ?? false;
          } else {
            // print('Busqueda con categoria');

            // print('TIPO -> ${data['categories'].runtimeType}'); 
            // print('SelectedFilte: ${_selectedFilter}');

            return (data['categories'] as List<dynamic>)?.any((elemento) => elemento.toString().toLowerCase() == _selectedFilter.toLowerCase()) ?? false; 
          }
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
      body: Stack( 
        children: [ 
          Padding (  
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 100),
            
            child: Column( 
              children: [  
                // // Titulo
                Title(
                  color: Colors.black, 
                  child: const Text(
                    'Pantalla principal',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 42, 69, 105),),
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
                                category:   data['categories'].toString() ?? 'Sin categoria',
                                meta:       data['funding_goal'] ?? 0,  
                                recaudado:  data['total_donated'] ?? 0,
                                id:         data['id'] ?? '',
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
          ),
          //Boton de cerrar sesion
          Positioned(
            top: 30,
            left: 20,
            height: 40, 
            width: 40, 
            child: Tooltip( 
              message: 'Cerrar sesion', 
              child: FloatingActionButton(
                onPressed: () =>  _logout(context),  
                backgroundColor: Color.fromARGB(255, 63, 119, 133),
                child: Icon(Icons.arrow_back, color: Color.fromARGB(255, 212, 209, 184)),
              ),
            ),
          ),
          //Boton de edicion de perfil
          Positioned(
            top: 30,
            right: 20,
            height: 40, 
            child: Tooltip( 
              message: 'Editar perfil', 
              child: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, '/edit-profile'), 
                // child: Icon(Icons.person),
                backgroundColor: Color.fromARGB(255, 63, 119, 133),
                child: Icon(Icons.person, color: Color.fromARGB(255, 212, 209, 184)),
              ),
            ),
          ),
          //Boton de cartera digital
          Positioned(
            top: 90,
            right: 20,
            height: 40, 
            child: Tooltip( 
              message: 'Cartera Digital', 
              child: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, '/wallet'), 
                // child: Icon(Icons.wallet),
                backgroundColor: Color.fromARGB(255, 63, 119, 133),
                child: Icon(Icons.wallet, color: Color.fromARGB(255, 212, 209, 184)),
              ),
            ),
          ),
          //Boton de crear proyectos
          Positioned(
            top: 165,
            right: 20,
            height: 40, 
            child: Tooltip( 
              message: 'Crear Proyecto', 
              child: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, '/create-project'), 
                // child: Icon(Icons.create_new_folder),
                backgroundColor: Color.fromARGB(255, 63, 119, 133),
                child: Icon(Icons.create_new_folder, color: Color.fromARGB(255, 212, 209, 184)),
              ),
            ),
          ),
          //Boton de editar proyectos
          Positioned(
            top: 225,
            right: 20,
            height: 40, 
            child: Tooltip( 
              message: 'Editar Proyectos', 
              child: FloatingActionButton(
                onPressed: () => _showEditProjectDialog(context), 
                // child: Icon(Icons.edit_document),
                backgroundColor: Color.fromARGB(255, 63, 119, 133),
                child: Icon(Icons.edit_document, color: Color.fromARGB(255, 212, 209, 184)),
              ),
            ),
          ),
        ],
      ),  
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
  final String category;
  final int meta;
  final int recaudado;
  final String id;

  // Constructor que recibe los datos
  ProjectTile({required this.titulo, required this.category, required this.meta, required this.recaudado, required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
                '${titulo}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Categorias: ${category.replaceAll('[', '').replaceAll(']', '')}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Meta: $meta  Recaudado: $recaudado',  // Meta y recaudado
                // style: TextStyle(color: const Color.fromARGB(255, 209, 45, 45)),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Acción de edición
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectInformationScreen(projectId: id),
                ),
              );
            
            },
            style: ElevatedButton.styleFrom(
              // backgroundColor: Colors.grey[700],
            ),
            child: const Text('Información'),
          ),
        ],
      ),
    );
  }
}

