import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/bookdetailscreen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/screens/bookservice.dart';
import 'login_screen.dart'; // Importamos la pantalla de login

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  List<String> userAuthors = [];
  Future<List<dynamic>>? topRatedBooks;

  @override
  void initState() {
    super.initState();
    fetchUserAuthors();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    fetchUserAuthors(); // Actualiza libros al volver a HomeScreen
  }

  Future<void> fetchUserAuthors() async {
    final books = await BookService().getBooksByUser(widget.userId);
    setState(() {
      userAuthors = books
          .map<String>((book) => book['authors'] as String)
          .toSet()
          .toList();
      topRatedBooks = fetchTopRatedBooks();
    });
  }

  Future<List<dynamic>> fetchTopRatedBooks() async {
    if (userAuthors.isEmpty) {
      return [];
    }

    List<dynamic> filteredBooks = [];
    for (String author in userAuthors) {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes?q=inauthor:$author&maxResults=5'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null) {
          filteredBooks.addAll(data['items']);
        }
      }
    }
    return filteredBooks;
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), 
      (Route<dynamic> route) => false, // Elimina todas las pantallas previas
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Encuentra tu Viaje"),
        backgroundColor: Colors.blue[900], // Azul oscuro
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blue[50], // Fondo azul clarito
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue[900], // Azul oscuro
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.travel_explore, color: Colors.white, size: 60),
                    SizedBox(height: 10),
                    Text(
                      'Menú de Opciones',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.search, 'Buscar Libros', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(userId: widget.userId),
                  ),
                );
              }),
              _buildDrawerItem(Icons.library_books, 'Mis Lecturas', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: widget.userId),
                  ),
                );
              }),
              const Divider(),
              _buildDrawerItem(Icons.exit_to_app, 'Cerrar Sesión', _logout, color: Colors.red),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.blue[50], // Fondo azul clarito
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              "Los libros mejor valorados de tus autores favoritos",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: topRatedBooks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No se encontraron libros.'));
                  } else {
                    final books = snapshot.data!;
                    return ListView.builder(
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
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
