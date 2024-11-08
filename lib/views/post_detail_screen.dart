import '../controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  String? _replyingToCommentId;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  final Controller _controller = Controller();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent / 2) {
        setState(() {
          _showBackToTopButton = true;
        });
      } else {
        setState(() {
          _showBackToTopButton = false;
        });
      }
    });
  }

  Future<void> _addComment({String? parentCommentId}) async {
    final commentText = parentCommentId == null ? _commentController.text : _replyController.text;

    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El comentario no puede estar vacío")),
      );
      return;
    }

    final userId = _controller.getCurrentUserId();
    final username = await _getUsername(userId);

    await FirebaseFirestore.instance
        .collection('Forum')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'user_id': username,
      'comment': commentText,
      'timestamp': FieldValue.serverTimestamp(),
      'parent_comment_id': parentCommentId,
    });

    if (parentCommentId == null) {
      _commentController.clear();
    } else {
      _replyController.clear();
      setState(() {
        _replyingToCommentId = null;
      });
    }
  }

  Future<String> _getUsername(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    return userDoc.data()?['username'] ?? 'Usuario';
  }

  void _replyToComment(String commentId) {
    setState(() {
      _replyingToCommentId = commentId;
    });
  }

  Widget _buildCommentTree(QuerySnapshot snapshot, String? parentId, {int depth = 0}) {
    final comments = snapshot.docs
        .where((doc) => doc['parent_comment_id'] == parentId)
        .toList();

    if (comments.isEmpty && parentId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No hay comentarios todavía. Sé el primero en comentar!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: comments.map((comment) {
        return Container(
          margin: EdgeInsets.only(left: depth * 16.0 + 8.0, top: 8.0),
          padding: const EdgeInsets.all(8.0),
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment['user_id'], style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(comment['comment']),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => _replyToComment(comment.id),
                  child: const Text("Responder"),
                ),
              ),
              if (_replyingToCommentId == comment.id)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          decoration: InputDecoration(
                            hintText: "Escribe tu respuesta",
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => _addComment(parentCommentId: comment.id),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _replyingToCommentId = null;
                          });
                          _replyController.clear();
                        },
                        child: const Text("Cancelar"),
                      ),
                    ],
                  ),
                ),
              _buildCommentTree(snapshot, comment.id, depth: depth + 1),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Post"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('Forum').doc(widget.postId).get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();

                    var post = snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(post['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(post['content']),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (post['images'] ?? []).map<Widget>((url) {
                            return Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(url),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Forum')
                      .doc(widget.postId)
                      .collection('comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "No hay comentarios todavía. Sé el primero en comentar!",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildCommentTree(snapshot.data!, null),
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          if (_showBackToTopButton)
            Positioned(
              top: 70,
              right: 16,
              child: ElevatedButton(
                onPressed: _scrollToTop,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.arrow_upward),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: const Color(0xFFE8E0F0),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "Escribe un comentario",
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _addComment(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}