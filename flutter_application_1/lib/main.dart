import 'package:flutter/material.dart';
import 'screens/login_screen.dart';  // Importar LoginScreen desde la carpeta screens

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicación de Inicio de sesión',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),  // Establecer LoginScreen como la pantalla principal
    );
  }
}
