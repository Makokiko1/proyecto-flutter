import 'package:flutter/material.dart'; // Importa el paquete de Material Design para Flutter
import 'package:flutter_application_1/screens/bookservice.dart'; // Importa el servicio de libros

class ProfileScreen extends StatefulWidget {
  final int userId; // ID del usuario que está usando la aplicación

  const ProfileScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> userBooks = []; // Lista de libros del usuario

  @override
  void initState() {
    super.initState();
    fetchUserBooks(); // Llama a la función para obtener los libros del usuario
  }

  // Función para obtener los libros del usuario
  Future<void> fetchUserBooks() async {
    final books = await BookService().getBooksByUser(widget.userId);
    setState(() {
      userBooks = books; // Actualiza la lista de libros
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Lecturas"), // Título de la barra superior
        backgroundColor: Colors.blue[900], // Color de fondo de la barra
        centerTitle: true, // Centra el título en la barra
      ),
      backgroundColor: Colors.blue[50], // Color de fondo de la pantalla
      body: userBooks.isEmpty
          ? const Center(child: Text("No tienes libros en tus lecturas.")) // Mensaje si no hay libros
          : ListView.builder(
              itemCount: userBooks.length, // Número de libros en la lista
              itemBuilder: (context, index) {
                final book = userBooks[index]; // Obtiene el libro actual
                return Card(
                  elevation: 3, // Elevación de la tarjeta
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Márgenes de la tarjeta
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bordes redondeados de la tarjeta
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12), // Espaciado interno
                    leading: book['imageUrl'] != null && book['imageUrl'].isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8), // Bordes redondeados de la imagen
                            child: Image.network(
                              book['imageUrl'], // URL de la imagen del libro
                              width: 60,
                              height: 90,
                              fit: BoxFit.cover, // Ajusta la imagen al espacio disponible
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 90,
                            color: Colors.grey[300], // Color de fondo si no hay imagen
                            child: const Icon(Icons.book, size: 40, color: Colors.black54), // Ícono de libro
                          ),
                    title: Text(
                      book['title'], // Título del libro
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    subtitle: Text(book['authors'], style: const TextStyle(color: Colors.black54)), // Autores del libro
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red), // Ícono de eliminar
                      onPressed: () async {
                        await BookService().deleteBook(book['id']); // Elimina el libro
                        fetchUserBooks(); // Actualiza la lista de libros
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}