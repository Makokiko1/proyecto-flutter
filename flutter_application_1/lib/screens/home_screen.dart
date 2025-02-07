import 'package:flutter/material.dart'; // Importa el paquete de Material Design para Flutter
import 'package:flutter_application_1/screens/bookdetailscreen.dart'; // Importa la pantalla de detalles del libro
import 'search_screen.dart'; // Importa la pantalla de búsqueda
import 'profile_screen.dart'; // Importa la pantalla de perfil
import 'dart:convert'; // Importa el paquete para trabajar con JSON
import 'package:http/http.dart' as http; // Importa el paquete para hacer solicitudes HTTP
import 'package:flutter_application_1/screens/bookservice.dart'; // Importa el servicio de libros
import 'login_screen.dart'; // Importa la pantalla de login

// Observador de rutas para detectar cambios en la navegación
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class HomeScreen extends StatefulWidget {
  final int userId; // ID del usuario que está usando la aplicación

  const HomeScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  List<String> userAuthors = []; // Lista de autores favoritos del usuario
  Future<List<dynamic>>? topRatedBooks; // Futuro para almacenar los libros mejor valorados

  @override
  void initState() {
    super.initState();
    fetchUserAuthors(); // Llama a la función para obtener los autores favoritos del usuario
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Suscribe el observador de rutas para detectar cambios en la navegación
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Cancela la suscripción del observador de rutas al destruir la pantalla
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Actualiza los autores favoritos al volver a la pantalla de inicio
    fetchUserAuthors();
  }

  // Función para obtener los autores favoritos del usuario
  Future<void> fetchUserAuthors() async {
    final books = await BookService().getBooksByUser(widget.userId);
    setState(() {
      // Extrae los autores de los libros y los almacena en una lista sin duplicados
      userAuthors = books
          .map<String>((book) => book['authors'] as String)
          .toSet()
          .toList();
      // Actualiza la lista de libros mejor valorados
      topRatedBooks = fetchTopRatedBooks();
    });
  }

  // Función para obtener los libros mejor valorados de los autores favoritos
  Future<List<dynamic>> fetchTopRatedBooks() async {
    if (userAuthors.isEmpty) {
      return []; // Retorna una lista vacía si no hay autores favoritos
    }

    List<dynamic> filteredBooks = [];
    for (String author in userAuthors) {
      // Realiza una solicitud HTTP para obtener libros del autor
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/books/v1/volumes?q=inauthor:$author&maxResults=5'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null) {
          // Agrega los libros obtenidos a la lista
          filteredBooks.addAll(data['items']);
        }
      }
    }
    return filteredBooks;
  }

  // Función para cerrar sesión
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), // Navega a la pantalla de login
      (Route<dynamic> route) => false, // Elimina todas las pantallas previas
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Encuentra tu Viaje"), // Título de la barra superior
        backgroundColor: Colors.blue[900], // Color de fondo de la barra
        centerTitle: true, // Centra el título en la barra
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blue[50], // Color de fondo del menú lateral
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Encabezado del menú lateral
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue[900], // Color de fondo del encabezado
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.travel_explore, color: Colors.white, size: 60), // Ícono del encabezado
                    SizedBox(height: 10),
                    Text(
                      'Menú de Opciones',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Elementos del menú lateral
              _buildDrawerItem(Icons.search, 'Buscar Libros', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(userId: widget.userId), // Navega a la pantalla de búsqueda
                  ),
                );
              }),
              _buildDrawerItem(Icons.library_books, 'Mis Lecturas', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: widget.userId), // Navega a la pantalla de perfil
                  ),
                );
              }),
              const Divider(), // Línea divisoria
              _buildDrawerItem(Icons.exit_to_app, 'Cerrar Sesión', _logout, color: Colors.red), // Opción para cerrar sesión
            ],
          ),
        ),
      ),
      backgroundColor: Colors.blue[50], // Color de fondo de la pantalla
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
                    return const Center(child: CircularProgressIndicator()); // Muestra un indicador de carga
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}')); // Muestra un mensaje de error
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No se encontraron libros.')); // Muestra un mensaje si no hay libros
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

  // Función para construir elementos del menú lateral
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: color), // Ícono del elemento
      title: Text(title, style: TextStyle(color: color)), // Título del elemento
      onTap: onTap, // Acción al presionar el elemento
    );
  }
}