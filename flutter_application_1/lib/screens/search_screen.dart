import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/bookdetailscreen.dart'; // Importamos la pantalla de detalles del libro
import 'dart:convert';
import 'package:http/http.dart' as http; // Importamos http para realizar solicitudes a la API

// Definimos la pantalla de búsqueda como un StatefulWidget
class SearchScreen extends StatefulWidget {
  final int userId; // Recibimos el ID del usuario como parámetro

  const SearchScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController(); // Controlador del campo de búsqueda
  List books = []; // Lista donde almacenaremos los resultados de la búsqueda

  // Función para buscar libros a través de la API de Google Books
  Future<void> searchBooks(String query) async {
    String url = 'https://www.googleapis.com/books/v1/volumes?q=$query'; // Construimos la URL de la API

    final response = await http.get(Uri.parse(url)); // Realizamos la petición HTTP
    if (response.statusCode == 200) { // Verificamos que la petición fue exitosa
      setState(() {
        books = json.decode(response.body)['items'] ?? []; // Guardamos los resultados en la lista
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscar Libros"),
        backgroundColor: Colors.blue[900], // Color del AppBar
        centerTitle: true,
      ),
      backgroundColor: Colors.blue[50], // Color de fondo de la pantalla
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Margen alrededor del contenido
        child: Column(
          children: [
            // Campo de búsqueda
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Buscar",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.blue),
                  onPressed: () {
                    searchBooks(searchController.text); // Llamamos a la función de búsqueda
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Lista de resultados de búsqueda
            Expanded(
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  final imageUrl = book['volumeInfo']['imageLinks']?['thumbnail'] ?? ''; // Obtenemos la imagen del libro
                  final title = book['volumeInfo']['title'] ?? 'Sin título'; // Obtenemos el título del libro
                  final authors = book['volumeInfo']['authors']?.join(', ') ?? 'Autor desconocido'; // Obtenemos los autores

                  return Card(
                    elevation: 3, // Sombra de la tarjeta
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bordes redondeados
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: imageUrl.isNotEmpty // Si hay imagen, la mostramos
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(imageUrl, width: 60, height: 90, fit: BoxFit.cover),
                            )
                          : Container( // Si no hay imagen, mostramos un icono de libro
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
                        // Navegamos a la pantalla de detalles del libro al hacer clic
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
