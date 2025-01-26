import 'package:flutter/material.dart';
import '../databasehelper.dart';  // Importar DatabaseHelper
import 'home_screen.dart';  // Asegúrate de que esta pantalla esté correctamente importada

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameRegisterController = TextEditingController();
  final passwordRegisterController = TextEditingController();
  bool isRegistering = false;  // Para cambiar entre inicio de sesión y registro

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    usernameRegisterController.dispose();
    passwordRegisterController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    final username = usernameController.text;
    final password = passwordController.text;

    try {
      final db = await DatabaseHelper.instance.database;

      // Buscar si el usuario existe en la base de datos
      final result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );

      if (result.isNotEmpty) {
        // Si la autenticación es exitosa, redirigir a HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),  // Redirigir a HomeScreen
        );
      } else {
        // Si las credenciales son incorrectas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrectos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en la base de datos: $e')),
      );
    }
  }

  // Función para registrar un nuevo usuario
  Future<void> registerUser() async {
    final username = usernameRegisterController.text;
    final password = passwordRegisterController.text;

    try {
      // Verificar si los campos no están vacíos
      if (username.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor ingrese un usuario y una contraseña.')),
        );
        return;
      }

      await DatabaseHelper.instance.insertUser(username, password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado correctamente')),
      );

      // Cambiar a la vista de inicio de sesión después de registrar
      setState(() {
        isRegistering = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Si estamos en el modo de registro, mostrar los campos de registro
            if (isRegistering)
              ...[
                TextField(
                  controller: usernameRegisterController,
                  decoration: const InputDecoration(labelText: 'Nuevo Usuario'),
                ),
                TextField(
                  controller: passwordRegisterController,
                  decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: registerUser,
                  child: const Text('Registrar'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isRegistering = false;  // Volver al modo de inicio de sesión
                    });
                  },
                  child: const Text('Ya tengo una cuenta, iniciar sesión'),
                ),
              ]
            else
              // Si estamos en el modo de inicio de sesión
              ...[
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loginUser,
                  child: const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isRegistering = true;  // Cambiar a modo de registro
                    });
                  },
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
              ],
          ],
        ),
      ),
    );
  }
}
