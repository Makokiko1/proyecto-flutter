import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/bookservice.dart';

class BookDetailScreen extends StatelessWidget {
  final Map<String, dynamic> book;
  final int userId;

  const BookDetailScreen({super.key, required this.book, required this.userId});

  Future<void> addToMyBooks(BuildContext context) async {
    final title = book['volumeInfo']['title'] ?? 'Sin título';
    final authors = book['volumeInfo']['authors']?.join(', ') ?? 'Autor desconocido';
    final imageUrl = book['volumeInfo']['imageLinks']?['thumbnail'] ?? '';

    try {
      await BookService().addBook(title, authors, imageUrl, userId);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libro añadido a Mis lecturas.')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir el libro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = book['volumeInfo']['title'] ?? 'Sin título';
    final authors = book['volumeInfo']['authors']?.join(', ') ?? 'Autor desconocido';
    final description = book['volumeInfo']['description'] ?? 'Sin descripción disponible';
    final imageUrl = book['volumeInfo']['imageLinks']?['thumbnail'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(imageUrl, width: 100, height: 150, fit: BoxFit.cover),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Autores: $authors',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sinopsis:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => addToMyBooks(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Añadir a Mis lecturas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
