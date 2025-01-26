import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  List books = [];
  String? selectedGenre;
  DateTimeRange? selectedDateRange;

  // Géneros disponibles
  final List<String> genres = ['Acción', 'Romance', 'Fantasía', 'Ciencia Ficción', 'Misterio', 'Histórico'];

  Future<void> searchBooks(String query) async {
    String url = 'https://www.googleapis.com/books/v1/volumes?q=$query';

    // Agregar filtro de género
    if (selectedGenre != null) {
      url += '&subject=$selectedGenre';
    }

    // Agregar filtro de fecha (si se selecciona un rango de fechas)
    if (selectedDateRange != null) {
      final startYear = selectedDateRange!.start.year;
      final endYear = selectedDateRange!.end.year;
      url += '&publishedDate=$startYear-$endYear';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        books = json.decode(response.body)['items'] ?? [];
      });
    } else {
      // Manejo de errores
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Buscar libros")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de búsqueda
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Buscar",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    searchBooks(searchController.text);
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Filtros adicionales
            ElevatedButton(
              onPressed: () {
                _showFiltersDialog();
              },
              child: Text("Mostrar filtros"),
            ),
            SizedBox(height: 16),

            // Mostrar libros
            Expanded(
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  final imageUrl = book['volumeInfo']['imageLinks']?['thumbnail'] ?? '';

                  return ListTile(
                    leading: imageUrl.isNotEmpty
                        ? Image.network(imageUrl, width: 50, height: 75, fit: BoxFit.cover)
                        : Container(width: 50, height: 75), // Placeholder si no hay imagen
                    title: Text(book['volumeInfo']['title'] ?? 'Sin título'),
                    subtitle: Text(book['volumeInfo']['authors']?.join(', ') ?? 'Autor desconocido'),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        // Navegar a la pantalla de detalles
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(book: book),
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

  // Mostrar el cuadro de diálogo con los filtros
  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Filtros de búsqueda"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Filtro de género
                DropdownButton<String>(
                  hint: Text("Selecciona el género"),
                  value: selectedGenre,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGenre = newValue;
                    });
                    Navigator.pop(context);
                  },
                  items: genres.map((genre) {
                    return DropdownMenuItem<String>(
                      value: genre,
                      child: Text(genre),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),

                // Filtro de fecha
                ListTile(
                  title: Text("Rango de fecha de publicación"),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null && picked != selectedDateRange) {
                      setState(() {
                        selectedDateRange = picked;
                      });
                    }
                  },
                  subtitle: selectedDateRange == null
                      ? Text("Selecciona un rango")
                      : Text(
                          "${selectedDateRange!.start.year} - ${selectedDateRange!.end.year}"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el cuadro de diálogo sin aplicar filtros
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                searchBooks(searchController.text); // Aplicar los filtros
                Navigator.pop(context); // Cerrar el cuadro de diálogo
              },
              child: Text("Aplicar filtros"),
            ),
          ],
        );
      },
    );
  }
}

class BookDetailScreen extends StatelessWidget {
  final Map<String, dynamic> book;

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
                  onPressed: () {
                    // Aquí puedes añadir la lógica para agregar el libro a "Mis lecturas"
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Libro añadido a Mis lecturas')));
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
