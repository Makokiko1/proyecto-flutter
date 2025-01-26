import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'databaseservice.dart';

class BookDetailScreen extends StatelessWidget {
  final Map<String, dynamic> book;
  final DatabaseService dbService = DatabaseService();

  BookDetailScreen({required this.book});

  @override
  Widget build(BuildContext context) {
    final title = book['volumeInfo']['title'] ?? 'Sin título';
    final authors = book['volumeInfo']['authors']?.join(', ') ?? 'Autor desconocido';
    final description = book['volumeInfo']['description'] ?? 'Sin descripción disponible';
    final imageUrl = book['volumeInfo']['imageLinks']?['thumbnail'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(imageUrl, width: 100, height: 150, fit: BoxFit.cover),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Autores: $authors',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    // Crear el objeto de libro para añadirlo a la base de datos
                    final bookData = {
                      'title': title,
                      'authors': authors,
                    };

                    // Añadir el libro a "Mis lecturas"
                    try {
                      final db = await dbService.database;
                      int result = await db.insert(
                        'libros',
                        bookData,
                        conflictAlgorithm: ConflictAlgorithm.replace,
                      );

                      if (result > 0) {
                        // Mostrar mensaje de éxito solo si la inserción fue exitosa
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Libro añadido a Mis lecturas')),
                        );
                      } else {
                        // Mostrar mensaje de error si no se insertó correctamente
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al añadir el libro')),
                        );
                      }
                    } catch (e) {
                      // Manejo de errores al interactuar con la base de datos
                      print("Error al añadir el libro: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al añadir el libro')),
                      );
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Sinopsis:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}
