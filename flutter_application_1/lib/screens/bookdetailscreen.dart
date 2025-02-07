import 'package:flutter/material.dart'; // Importa el paquete de Material Design para Flutter
import 'package:flutter_application_1/screens/bookservice.dart'; // Importa el servicio para gestionar libros

class BookDetailScreen extends StatelessWidget {
  // Datos del libro que se mostrarán en esta pantalla
  final Map<String, dynamic> book;
  // ID del usuario que está interactuando con la pantalla
  final int userId;

  // Constructor de la clase. Recibe el libro y el ID del usuario como parámetros
  const BookDetailScreen({super.key, required this.book, required this.userId});

  // Función asíncrona para añadir un libro a la lista del usuario
  Future<void> addToMyBooks(BuildContext context) async {
    // Extrae el título del libro, o usa 'Sin título' si no está disponible
    final title = book['volumeInfo']['title'] ?? 'Sin título';
    // Extrae los autores del libro, o usa 'Autor desconocido' si no están disponibles
    final authors = book['volumeInfo']['authors']?.join(', ') ?? 'Autor desconocido';
    // Extrae la URL de la imagen del libro, o usa una cadena vacía si no está disponible
    final imageUrl = book['volumeInfo']['imageLinks']?['thumbnail'] ?? '';

    try {
      // Llama al servicio para añadir el libro a la lista del usuario
      await BookService().addBook(title, authors, imageUrl, userId);
      // Muestra un mensaje de éxito al usuario
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libro añadido a Mis lecturas.')),
      );
    } catch (e) {
      // Si ocurre un error, muestra un mensaje de error al usuario
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir el libro: $e')),
      );
    }
  }

  // Método que construye la interfaz de usuario de la pantalla
  @override
  Widget build(BuildContext context) {
    // Extrae los datos del libro para mostrarlos en la interfaz
    final title = book['volumeInfo']['title'] ?? 'Sin título';
    final authors = book['volumeInfo']['authors']?.join(', ') ?? 'Autor desconocido';
    final description = book['volumeInfo']['description'] ?? 'Sin descripción disponible';
    final imageUrl = book['volumeInfo']['imageLinks']?['thumbnail'] ?? '';

    // Retorna la estructura de la pantalla
    return Scaffold(
      // Barra superior de la pantalla
      appBar: AppBar(
        title: Text(title), // Título de la barra superior
        backgroundColor: Colors.blue[900], // Color de fondo de la barra
        centerTitle: true, // Centra el título en la barra
      ),
      // Color de fondo de la pantalla
      backgroundColor: Colors.blue[50],
      // Cuerpo de la pantalla
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Espaciado interno
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alineación de los elementos
          children: [
            // Fila que contiene la imagen y los detalles del libro
            Row(
              children: [
                // Muestra la imagen del libro si está disponible
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Bordes redondeados
                    child: Image.network(
                      imageUrl,
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover, // Ajusta la imagen al espacio disponible
                    ),
                  ),
                const SizedBox(width: 16), // Espacio entre la imagen y los detalles
                // Columna con el título y los autores del libro
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título del libro
                      Text(
                        title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8), // Espacio entre el título y los autores
                      // Autores del libro
                      Text(
                        'Autores: $authors',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Espacio entre la fila y la sinopsis
            // Título de la sección de sinopsis
            const Text(
              'Sinopsis:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8), // Espacio entre el título y la descripción
            // Descripción del libro
            Text(description),
            const SizedBox(height: 20), // Espacio entre la descripción y el botón
            // Botón para añadir el libro a la lista del usuario
            Center(
              child: ElevatedButton(
                onPressed: () => addToMyBooks(context), // Acción al presionar el botón
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900], // Color de fondo del botón
                  foregroundColor: Colors.white, // Color del texto del botón
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bordes redondeados del botón
                  ),
                ),
                child: const Text('Añadir a Mis lecturas'), // Texto del botón
              ),
            ),
          ],
        ),
      ),
    );
  }
}