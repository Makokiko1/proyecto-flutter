import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/bookdetailscreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  final int userId;

  const SearchScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  List books = [];

  Future<void> searchBooks(String query) async {
    String url = 'https://www.googleapis.com/books/v1/volumes?q=$query';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        books = json.decode(response.body)['items'] ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscar Libros"),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Buscar",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.blue),
                  onPressed: () {
                    searchBooks(searchController.text);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  final imageUrl = book['volumeInfo']['imageLinks']?['thumbnail'] ?? '';
                  final title = book['volumeInfo']['title'] ?? 'Sin título';
                  final authors = book['volumeInfo']['authors']?.join(', ') ?? 'Autor desconocido';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(imageUrl, width: 60, height: 90, fit: BoxFit.cover),
                            )
                          : Container(
                              width: 60,
                              height: 90,
                              color: Colors.grey[300],
                              child: const Icon(Icons.book, size: 40, color: Colors.black54),
                            ),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      subtitle: Text(authors, style: const TextStyle(color: Colors.black54)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(
                              book: book,
                              userId: widget.userId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
