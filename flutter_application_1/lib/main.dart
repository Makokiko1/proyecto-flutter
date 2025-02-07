import 'package:flutter/material.dart';
import 'screens/login_screen.dart';  // Importar LoginScreen desde la carpeta screens

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicación de Inicio de sesión',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),  // Establecer LoginScreen como la pantalla principal
    );
  }
}
