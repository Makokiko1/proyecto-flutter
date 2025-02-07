import 'package:flutter/material.dart';
import '../databasehelper.dart'; // Importar DatabaseHelper
import 'home_screen.dart'; // Importar HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRegistering = false; // Determina si estamos en modo registro

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
      return;
    }

    try {
      final userId = await DatabaseHelper.instance.authenticateUser(username, password);

      if (userId != null) {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userId: userId)), // Redirigir a HomeScreen
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrectos.')),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    }
  }

  Future<void> registerUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
      return;
    }

    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 8 caracteres, incluir una mayúscula, una minúscula y un número.'),
        ),
      );
      return;
    }

    try {
      if (await DatabaseHelper.instance.userExists(username)) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El usuario ya existe.')),
        );
        return;
      }

      await DatabaseHelper.instance.insertUser(username, password);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado con éxito. Ahora puedes iniciar sesión.')),
      );

      setState(() {
        isRegistering = false;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isRegistering ? 'Registrar Usuario' : 'Iniciar Sesión'),
        backgroundColor: Colors.blue[900], // Azul oscuro
        centerTitle: true,
      ),
      backgroundColor: Colors.blue[50], // Fondo azul clarito
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: isRegistering ? 'Nuevo Usuario' : 'Usuario',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: isRegistering ? 'Nueva Contraseña' : 'Contraseña',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isRegistering ? registerUser : loginUser,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
              child: Text(isRegistering ? 'Registrar' : 'Iniciar Sesión', style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  isRegistering = !isRegistering;
                });
              },
              child: Text(
                isRegistering
                    ? '¿Ya tienes una cuenta? Inicia sesión'
                    : '¿No tienes cuenta? Regístrate',
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
