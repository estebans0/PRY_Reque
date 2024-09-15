import 'package:app/models/project_model.dart'; 
import 'package:flutter/material.dart';


class ProjectManagementPage extends StatefulWidget {
    const ProjectManagementPage({super.key});

    @override
    State<ProjectManagementPage> createState() => _ProjectManagementPage();
}


class _ProjectManagementPage extends State<ProjectManagementPage> {
  ProjectMethods project_model = ProjectMethods();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding( 

        padding: const EdgeInsets.all(30), 
        child: Column( 
          children: [
            Title(
              color: Colors.black, 
              child: const Text(
                'Gestión de proyectos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
              ),
            ),
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
                      focusColor: const Color(0xFFE0E0D6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  // icon: Icon(Icons.filter_list, color: Colors.white),
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Add your filter logic here
                  },
                ),
                IconButton(
                  // icon: Icon(Icons.search, color: Colors.white),
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Add your search logic here
                  },
                ),
              ],
            ),
            const SizedBox(height: 20, width: 90),
            
            // Lista de proyectos
            Expanded( 
              child: FutureBuilder(
                future: project_model.getProjects(),
                builder: (context, snapshot) {
                  
                  // Mientras se espera que los datos sean obtenidos, mostramos un indicador de carga
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());

                  } else if (snapshot.hasError) { 
                    return const Center( child: Text('Error al cargar proyectos'));

                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) { 
                    return ListView.builder(
                      itemCount: snapshot.data?.length ?? 0, 
                      itemBuilder: (context, index) {
                        var project = snapshot.data?[index];  // Accedemos al proyecto en la lista
                        return ProjectTile(
                          titulo: project['name'] ?? 'Sin título',
                          meta: project['funding_goal'] ?? 0,  
                          recaudado: project['total_donated'] ?? 0,

                        );

                      },
                    );
                  } else { 
                    return const Center(
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



class ProjectTile extends StatelessWidget {
  final String titulo;
  final int meta;
  final int recaudado;

  // Constructor que recibe los datos
  const ProjectTile({super.key, required this.titulo, required this.meta, required this.recaudado});

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
                titulo,  // Título del proyecto
                // style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 18),
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
            },
            style: ElevatedButton.styleFrom(
              // backgroundColor: Colors.grey[700],
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }
}
