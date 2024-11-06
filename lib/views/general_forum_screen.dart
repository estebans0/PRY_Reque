// lib/views/general_forum_screen.dart
import 'package:flutter/material.dart';

class GeneralForumScreen extends StatelessWidget {
  GeneralForumScreen({super.key});

  //Placheholder de preguntas, se tiene que remplazar con la funcion que se realice en modelo
  final List<Map<String, String>> preguntas = [
    {
      'autor': 'Autor 1',
      'titulo': '¿Cómo resolver este error?',
      'contenido':
          'Tengo un problema con este error y no encuentro manera de resolverlo y he intentado de todo',
      'fecha': '01/01/2023',
      'hora': '10:30'
    },
    {
      'autor': 'Autor 2',
      'titulo': 'Duda sobre instalación',
      'contenido': 'Al intentar instalar...',
      'fecha': '02/01/2023',
      'hora': '12:45'
    },
    {
      'autor': 'Autor 3',
      'titulo': 'Mejor práctica para...',
      'contenido': '¿Cuál es la mejor manera de...',
      'fecha': '03/01/2023',
      'hora': '14:15'
    },
    {
      'autor': 'Autor 1',
      'titulo': '¿Cómo resolver este error?',
      'contenido':
          'Tengo un problema con este error y no encuentro manera de resolverlo y he intentado de todo',
      'fecha': '01/01/2023',
      'hora': '10:30'
    },
    {
      'autor': 'Autor 2',
      'titulo': 'Duda sobre instalación',
      'contenido': 'Al intentar instalar...',
      'fecha': '02/01/2023',
      'hora': '12:45'
    },
    {
      'autor': 'Autor 3',
      'titulo': 'Mejor práctica para...',
      'contenido': '¿Cuál es la mejor manera de...',
      'fecha': '03/01/2023',
      'hora': '14:15'
    },
    {
      'autor': 'Autor 1',
      'titulo': '¿Cómo resolver este error?',
      'contenido':
          'Tengo un problema con este error y no encuentro manera de resolverlo y he intentado de todo',
      'fecha': '01/01/2023',
      'hora': '10:30'
    },
    {
      'autor': 'Autor 2',
      'titulo': 'Duda sobre instalación',
      'contenido': 'Al intentar instalar...',
      'fecha': '02/01/2023',
      'hora': '12:45'
    },
    {
      'autor': 'Autor 3',
      'titulo': 'Mejor práctica para...',
      'contenido': '¿Cuál es la mejor manera de...',
      'fecha': '03/01/2023',
      'hora': '14:15'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          'Foro General',
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
                itemCount: preguntas.length,
                itemBuilder: (context, index) {
                  final pregunta = preguntas[index];
                  return ForumPostTile(
                    author: pregunta['autor']!,
                    title: pregunta['titulo']!,
                    contentPreview: pregunta['contenido']!,
                    date: pregunta['fecha']!,
                    time: pregunta['hora']!,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                //Navegación a la pantalla de nueva pregunta (sin funcionalidad)
                //Navigator.pushNamed(context, '/new-question');
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                backgroundColor: const Color.fromARGB(255, 63, 119, 133),
              ),
              child: const Text(
                'Preguntar',
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
                //Navegación a los detalles de la publicación (sin funcionalidad) opc
                //Navigator.pushNamed(context, '/post-details');
              },
            ),
          ),
        ],
      ),
    );
  }
}
