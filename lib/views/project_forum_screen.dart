// project_forum_screen.dart
import 'package:flutter/material.dart';

class ProjectForumScreen extends StatelessWidget {
  final String projectId;

  ProjectForumScreen({super.key, required this.projectId});

  // Placeholder de mensajes del foro interno
  final List<Map<String, String>> mensajes = [
    {
      'autor': 'Colaborador 1',
      'titulo': 'Actualización de progreso',
      'contenido': 'Hemos avanzado un 50% en la fase inicial.',
      'fecha': '05/11/2024',
      'hora': '10:30'
    },
    {
      'autor': 'Colaborador 2',
      'titulo': 'Consulta sobre recursos',
      'contenido': '¿Necesitamos más material?',
      'fecha': '05/11/2024',
      'hora': '11:15'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          'Foro Interno',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: mensajes.length,
                itemBuilder: (context, index) {
                  final mensaje = mensajes[index];
                  return ForumPostTile(
                    author: mensaje['autor']!,
                    title: mensaje['titulo']!,
                    contentPreview: mensaje['contenido']!,
                    date: mensaje['fecha']!,
                    time: mensaje['hora']!,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegación a la pantalla de nuevo mensaje (sin funcionalidad por ahora)
                // Navigator.pushNamed(context, '/new-message');
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                backgroundColor: const Color.fromARGB(255, 63, 119, 133),
              ),
              child: const Text(
                'Enviar mensaje',
                style: TextStyle(color: Color.fromARGB(255, 212, 209, 184)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForumPostTile extends StatelessWidget {
  final String author;
  final String title;
  final String contentPreview;
  final String date;
  final String time;

  const ForumPostTile({
    super.key,
    required this.author,
    required this.title,
    required this.contentPreview,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0D6),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$date - $time',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            contentPreview,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                // Navegación a los detalles de la publicación (sin funcionalidad)
              },
            ),
          ),
        ],
      ),
    );
  }
}
