import 'package:flutter/material.dart'; // Importa el paquete de Material Design para Flutter
import '../databasehelper.dart'; // Importa la clase DatabaseHelper para interactuar con la base de datos
import 'home_screen.dart'; // Importa la pantalla principal (HomeScreen)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController(); // Controlador para el campo de usuario
  final passwordController = TextEditingController(); // Controlador para el campo de contraseña
  bool isRegistering = false; // Variable para determinar si estamos en modo registro o inicio de sesión

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se destruye
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Función para iniciar sesión
  Future<void> loginUser() async {
    final username = usernameController.text.trim(); // Obtiene el nombre de usuario
    final password = passwordController.text.trim(); // Obtiene la contraseña

    // Valida que los campos no estén vacíos
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
      return;
    }

    try {
      // Autentica al usuario usando DatabaseHelper
      final userId = await DatabaseHelper.instance.authenticateUser(username, password);

      if (userId != null) {
        // Si la autenticación es exitosa, redirige a la pantalla principal
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userId: userId)),
        );
      } else {
        // Si la autenticación falla, muestra un mensaje de error
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrectos.')),
        );
      }
    } catch (e) {
      // Maneja errores durante el proceso de autenticación
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    }
  }

  // Función para registrar un nuevo usuario
  Future<void> registerUser() async {
    final username = usernameController.text.trim(); // Obtiene el nombre de usuario
    final password = passwordController.text.trim(); // Obtiene la contraseña

    // Valida que los campos no estén vacíos
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
      return;
    }

    // Expresión regular para validar la contraseña
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
      // Verifica si el usuario ya existe
      if (await DatabaseHelper.instance.userExists(username)) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El usuario ya existe.')),
        );
        return;
      }

      // Registra al nuevo usuario en la base de datos
      await DatabaseHelper.instance.insertUser(username, password);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado con éxito. Ahora puedes iniciar sesión.')),
      );

      // Cambia al modo de inicio de sesión después del registro exitoso
      setState(() {
        isRegistering = false;
      });
    } catch (e) {
      // Maneja errores durante el proceso de registro
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
        title: Text(isRegistering ? 'Registrar Usuario' : 'Iniciar Sesión'), // Título dinámico
        backgroundColor: Colors.blue[900], // Color de fondo de la barra superior
        centerTitle: true, // Centra el título
      ),
      backgroundColor: Colors.blue[50], // Color de fondo de la pantalla
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Campo de texto para el nombre de usuario
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: isRegistering ? 'Nuevo Usuario' : 'Usuario', // Etiqueta dinámica
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 20),
            // Campo de texto para la contraseña
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: isRegistering ? 'Nueva Contraseña' : 'Contraseña', // Etiqueta dinámica
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              obscureText: true, // Oculta el texto de la contraseña
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 20),
            // Botón para iniciar sesión o registrar
            ElevatedButton(
              onPressed: isRegistering ? registerUser : loginUser, // Acción dinámica
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
              child: Text(isRegistering ? 'Registrar' : 'Iniciar Sesión', style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            // Botón para cambiar entre registro e inicio de sesión
            TextButton(
              onPressed: () {
                setState(() {
                  isRegistering = !isRegistering; // Cambia el modo
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