import 'package:app/models/auth_model.dart'; 
import 'package:app/models/project_model.dart';
import 'package:app/views/project_form_screen_admin.dart'; 
import 'package:flutter/material.dart'; 
import '../views/comments_screen.dart';


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
  final TextEditingController _searchController = TextEditingController();


  // Lista de opciones para el dropdown (filtrar por nombre o categoría)
  final List<String> _filterOptions = ['nombre'];
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
        for (var element in temp) { _filterOptions.add(element.toString()); }

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
          var data = item; 
          if (_selectedFilter == 'nombre') { 

            return data['name']?.toLowerCase().contains(query) ?? false;
          } else { 

            return (data['categories'] as List<dynamic>).any((elemento) => elemento.toString().toLowerCase() == _selectedFilter.toLowerCase()); 
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
        // title: Text("Firebase Firestore Example"), 
      body: Padding(
        // padding: const EdgeInsets.all(60), 
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        
        child: Column( 
          children: [
            Title(
              color: Colors.black, 
              child: const Text(
                'Proyectos',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,),
              ),
            ),
            const SizedBox(height: 20),
            // Fila de buscar y filtro
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Buscar',
                        hintText: 'Buscar...',
                        focusColor: Color(0xFFE0E0D6),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), 
                  
                   // DropdownButton para seleccionar el tipo de filtro
                  IntrinsicWidth(  
                    child: DropdownButtonFormField<String>(
                      value: _selectedFilter, // Valor seleccionado por defecto
                      decoration: InputDecoration(
                        labelText: 'Filtro',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
 
            const SizedBox(height: 20),
              
            // Expanded para permitir que el ListView ocupe el espacio disponible
            Expanded(
              
              child: _filteredItems.isEmpty
                  ? const Center(child: CircularProgressIndicator()) // Mostrar spinner mientras se cargan los datos
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        // Verificar que el tipo de dato sea un Map antes de acceder a campos
                        if (_filteredItems[index] is Map<String, dynamic>) {
                          var data = _filteredItems[index] as Map<String, dynamic>;
                          String idProject =   data['id'] ?? '';
                          String titulo =      data['name'] ?? 'Sin título';
                          String category =    data['categories'].toString();
                          int meta =           data['funding_goal'] ?? 0;
                          int recaudado =      data['total_donated'] ?? 0;
                          return auxBuild(context, idProject, titulo, category, meta, recaudado);  
                        } else {
                          return const ListTile(
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

  Widget auxBuild(BuildContext context, String idProject, String titulo, String category, int meta, int recaudado) {
    return Container( 
      margin: const EdgeInsets.only(bottom: 16),
      // padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.grey[850],
        color:const  Color(0xFFE0E0D6),
        borderRadius: BorderRadius.circular(8.0),
        // border: Border.all(color: const Color.fromARGB(255, 29, 120, 204)),
      ),
      
      child:LayoutBuilder(
        builder: (context, Constraints) {
          if(Constraints.maxWidth < 800){
            return Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Categorias: ${category.replaceAll('[', '').replaceAll(']', '')}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Meta: $meta  Recaudado: $recaudado',  // Meta y recaudado
                      // style: TextStyle(color: const Color.fromARGB(255, 209, 45, 45)),
                    ),
                    const SizedBox(height: 8),
                  ],
                ), 
                // Align(
                Column(                  
                  // alignment: Alignment.centerRight,
                  children: [
                    SizedBox(
                      child: ElevatedButton(
                        onPressed: () { 
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProjectFormScreenAdmin(projectId: idProject),
                            ), 
                          ); 
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 63, 119, 133),
                        ),
                        child: const Text('Editar', style: TextStyle(color: Color.fromARGB(255, 212, 209, 184)),),
                      ),
                    ), 
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentsScreen(projectId: idProject),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 63, 119, 133),
                      ),
                      child: const Text('Comentarios', style: TextStyle(color: Color.fromARGB(255, 212, 209, 184)),),

                    ),
                    
                  ],
                ) 
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
                      titulo,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Categorias: ${category.replaceAll('[', '').replaceAll(']', '')}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Meta: $meta  Recaudado: $recaudado',  // Meta y recaudado
                      // style: TextStyle(color: const Color.fromARGB(255, 209, 45, 45)),
                    ),
                  ],
                ), 

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navegar a la página de edición pasando el proyecto
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProjectFormScreenAdmin(projectId: idProject),
                        ), 
                      );
                      // setState(() {});
                    },
                    // style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE0E0D6)),
                    // child: Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 63, 119, 133),
                    ),
                    child: const Text('Editar', style: TextStyle(color: Color.fromARGB(255, 212, 209, 184)),),
                  ),
                ) 
              ],
            );
          }
        }
      )
       


    );
  }

}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
 