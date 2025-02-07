import 'package:flutter/material.dart';
import '../databasehelper.dart'; // Importamos el helper de base de datos para manejar usuarios

// Definimos una pantalla de registro como un StatefulWidget
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para capturar la entrada del usuario y la contraseña
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Liberamos los controladores cuando el widget se destruye para evitar pérdidas de memoria
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    // Obtenemos y limpiamos los valores ingresados por el usuario
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // Validamos que los campos no estén vacíos
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
      return;
    }

    try {
      // Verificamos si el usuario ya existe en la base de datos
      final userExists = await DatabaseHelper.instance.userExists(username);
      if (userExists) {
        // Mostramos un mensaje si el usuario ya está registrado
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El usuario ya existe.')),
        );
        return;
      }

      // Insertamos el usuario en la base de datos
      await DatabaseHelper.instance.insertUser(username, password);
      
      // Mostramos un mensaje de éxito
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado con éxito')),
      );
      
      // Retornamos a la pantalla anterior
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      // Capturamos errores y mostramos un mensaje de error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900], // Color de fondo de la pantalla
      appBar: AppBar(
        title: const Text('Registrar Usuario'),
        backgroundColor: Colors.blueGrey[800], // Color del AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Margen alrededor del contenido
        child: Column(
          children: <Widget>[
            // Campo de texto para el usuario
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Usuario',
                filled: true,
                fillColor: Colors.blueGrey[700], // Color de fondo del campo de texto
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: const TextStyle(color: Colors.white), // Color del texto
            ),
            const SizedBox(height: 10), // Espaciado entre los campos
            
            // Campo de texto para la contraseña
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                filled: true,
                fillColor: Colors.blueGrey[700],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              obscureText: true, // Ocultamos el texto para la contraseña
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            
            // Botón de registro
            ElevatedButton(
              onPressed: registerUser, // Llama a la función para registrar el usuario
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text('Registrar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
