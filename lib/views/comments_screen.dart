import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/project_model.dart';

class CommentsScreen extends StatefulWidget {
  final String projectId;

  const CommentsScreen({super.key, required this.projectId});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final ProjectMethods _projectMethods = ProjectMethods();
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 0;
  List<Map<String, dynamic>> _comments = [];

  // Método para cargar los comentarios
  void _fetchComments() async {
    var comments = await _projectMethods.getRatings(widget.projectId);
    setState(() {
      _comments = comments;
    });
  }

  // Método para agregar un comentario
  Future<void> _submitComment() async {
    // Verificar si el usuario seleccionó una puntuación
    if (_userRating == 0) {
      // Mostrar mensaje de error si no seleccionó una puntuación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Debes elegir una puntuación antes de dejar un comentario."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verificar si el campo de comentario no está vacío
    if (_commentController.text.isNotEmpty) {
      try {
        await _projectMethods.addRating(
          widget.projectId,
          _userRating.toInt(),
          _commentController.text,
        );
        _commentController.clear();
        _userRating = 0;
        _fetchComments(); // Refresca la lista de comentarios
      } catch (e) {
        // Mostrar mensaje de error si el usuario ya comentó
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Mostrar mensaje de error si el comentario está vacío
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El comentario no puede estar vacío."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: _comments.isEmpty
                      ? const Center(child: Text('No hay comentarios aún'))
                      : ListView.builder(
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            return CommentTile(
                              author: comment[
                                  'username'], // Mostrar nombre de usuario
                              rating: comment['rating'],
                              content: comment['comment'],
                              date: (comment['timestamp'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .substring(0, 16), // Fecha local sin segundos
                            );
                          },
                        ),
                ),
                const Divider(),
                const Text(
                  "Deja tu comentario y puntuación",
                  style: TextStyle(fontSize: 18),
                ),
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _userRating = rating;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(labelText: 'Comentario'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitComment,
                  child: const Text("Enviar"),
                ),
              ],
            ),
          ),
          Positioned(
            top: 30,
            left: 20,
            height: 40,
            width: 40,
            child: Tooltip(
              message: 'Volver',
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context); // Vuelve a la pantalla anterior
                },
                backgroundColor: const Color.fromARGB(255, 63, 119, 133),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color.fromARGB(255, 212, 209, 184),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  final String author;
  final int rating;
  final String content;
  final String date;

  const CommentTile({
    super.key,
    required this.author,
    required this.rating,
    required this.content,
    required this.date,
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
                'Puntuación: $rating',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
