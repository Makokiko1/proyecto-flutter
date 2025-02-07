import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/bookservice.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> userBooks = [];

  @override
  void initState() {
    super.initState();
    fetchUserBooks();
  }

  Future<void> fetchUserBooks() async {
    final books = await BookService().getBooksByUser(widget.userId);
    setState(() {
      userBooks = books;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Lecturas"),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      backgroundColor: Colors.blue[50],
      body: userBooks.isEmpty
          ? const Center(child: Text("No tienes libros en tus lecturas."))
          : ListView.builder(
              itemCount: userBooks.length,
              itemBuilder: (context, index) {
                final book = userBooks[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: book['imageUrl'] != null && book['imageUrl'].isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              book['imageUrl'],
                              width: 60,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 90,
                            color: Colors.grey[300],
                            child: const Icon(Icons.book, size: 40, color: Colors.black54),
                          ),
                    title: Text(
                      book['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    subtitle: Text(book['authors'], style: const TextStyle(color: Colors.black54)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await BookService().deleteBook(book['id']);
                        fetchUserBooks(); // Actualiza la lista
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
