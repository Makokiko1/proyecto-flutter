import 'package:flutter/material.dart';
import 'search_screen.dart'; // Suponiendo que tienes esta pantalla de búsqueda de libros.
import 'profile_screen.dart'; // Pantalla para mostrar "Mis lecturas".

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bienvenido a la aplicación de libros")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Recomendaciones de libros", style: TextStyle(fontSize: 18)),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
              child: const Text("Buscar libros"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: const Text("Mis lecturas"),
            ),
          ],
        ),
      ),
    );
  }
}
