// lib/views/general_forum_screen.dart
// ignore_for_file: must_be_immutable, prefer_final_fields

import '../controllers/controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'post_detail_screen.dart';

class GeneralForumScreen extends StatelessWidget {
  GeneralForumScreen({super.key});

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<String> _imageUrls = [];
  final Controller _controller = Controller();

  void _openCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Crear nuevo post"),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Título"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Contenido"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _openAddImageDialog(context);
              },
              child: const Text("Agregar Imágenes (opcional)"),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _imageUrls.map((url) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 20),
                        onPressed: () {
                          _removeImage(url);
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _contentController.clear();
              _imageUrls.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              _createPost(context);
            },
            child: const Text("Publicar"),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddImageDialog(BuildContext context) async {
    final urlController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Agregar URL de la Imagen"),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(labelText: "URL de la imagen"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                _addImage(urlController.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  void _addImage(String url) {
    _imageUrls.add(url);
  }

  void _removeImage(String url) {
    _imageUrls.remove(url);
  }

  Future<void> _createPost(BuildContext context) async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El título y el contenido no pueden estar vacíos")),
      );
      return;
    }

    final userId = _controller.getCurrentUserId();
    final username = await _getUsername(userId); // Resolver el Future para obtener el username

    await FirebaseFirestore.instance.collection('Forum').add({
      'author': username,
      'title': _titleController.text,
      'content': _contentController.text,
      'images': _imageUrls,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _titleController.clear();
    _contentController.clear();
    _imageUrls.clear();
    Navigator.pop(context);
  }

  Future<String> _getUsername(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    return userDoc.data()?['username'] ?? 'Usuario';
  }

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
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Forum').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  var posts = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      var post = posts[index];
                      return ForumPostTile(
                        author: post['author'],
                        title: post['title'],
                        contentPreview: post['content'],
                        date: (post['timestamp'] as Timestamp).toDate().toLocal().toString().substring(0, 10),
                        time: (post['timestamp'] as Timestamp).toDate().toLocal().toString().substring(11, 16),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(postId: post.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _openCreatePostDialog(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                backgroundColor: const Color.fromARGB(255, 63, 119, 133),
              ),
              child: const Text(
                'Post',
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
  final VoidCallback onPressed;

  const ForumPostTile({
    super.key,
    required this.author,
    required this.title,
    required this.contentPreview,
    required this.date,
    required this.time,
    required this.onPressed,
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
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
