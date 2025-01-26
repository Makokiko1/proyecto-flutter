import 'package:flutter/material.dart';
import 'databaseservice.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> books = [];

  // Obtener los libros guardados desde la base de datos
  Future<void> getBooks() async {
    try {
      final bookList = await _databaseService.getBooks();
      setState(() {
        books = bookList;
      });
      print("Books cargados correctamente: $books");
    } catch (e) {
      print("Error al cargar los libros: $e");
    }
  }

  // Eliminar un libro de "Mis lecturas" usando su ID
  Future<void> deleteBook(int id) async {
    try {
      await _databaseService.deleteBook(id);
      getBooks(); // Actualizar lista de libros después de eliminar
    } catch (e) {
      print("Error al eliminar el libro: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getBooks(); // Cargar los libros al iniciar la pantalla
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mis lecturas")),
      body: books.isEmpty
          ? Center(child: Text("No hay libros guardados")) // Indicador si no hay libros
          : ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return ListTile(
                  title: Text(book['title'] ?? 'Sin título'),
                  subtitle: Text(book['authors'] ?? 'Autor desconocido'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteBook(book['id']); // Eliminar libro
                    },
                  ),
                );
              },
            ),
    );
  }
}
