import 'package:flutter/material.dart';
import 'screens/login_screen.dart';  // Importar la pantalla de inicio de sesión

// Función principal que inicia la aplicación
void main() {
  runApp(const MyApp());
}

// Clase principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicación de Inicio de sesión', // Título de la aplicación
      theme: ThemeData(
        primarySwatch: Colors.blue, // Definir el color principal de la aplicación
      ),
      home: const LoginScreen(),  // Establecer LoginScreen como la pantalla principal
    );
  }
}
