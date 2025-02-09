import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// Clase que gestiona la base de datos SQLite
class DatabaseHelper {
  // Instancia única de DatabaseHelper (Patrón Singleton)
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  // Constructor privado para evitar múltiples instancias
  DatabaseHelper._init();

  // Getter para obtener la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db'); // Inicializa la base de datos
    return _database!;
  }

  // Inicializa la base de datos y la abre
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath(); // Obtiene la ruta de la base de datos
    final path = join(dbPath, filePath); // Une la ruta con el nombre del archivo
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Crea la estructura de la base de datos (tabla de usuarios) y añade un usuario por defecto
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Inserta el usuario por defecto con la contraseña encriptada
    final defaultUsername = 'usuario';
    final defaultPassword = _hashPassword('usuario'); // Encripta la contraseña
    
    await db.insert(
      'users',
      {'username': defaultUsername, 'password': defaultPassword},
    );
  }

  // Inserta un usuario en la base de datos con contraseña encriptada
  Future<void> insertUser(String username, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password); // Encripta la contraseña

    await db.insert(
      'users',
      {'username': username, 'password': hashedPassword},
      conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza si el usuario ya existe
    );
  }

  // Verifica si un usuario ya existe en la base de datos
  Future<bool> userExists(String username) async {
    final db = await database;
    final result = await db.query('users', where: 'username = ?', whereArgs: [username]);
    return result.isNotEmpty; // Retorna true si el usuario existe
  }

  // Obtiene los datos de un usuario en base a su nombre de usuario
  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final result = await db.query('users', where: 'username = ?', whereArgs: [username]);
    return result.isNotEmpty ? result.first : null; // Retorna el usuario si existe
  }

  // Autentica un usuario verificando su nombre y contraseña
  Future<int?> authenticateUser(String username, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password); // Encripta la contraseña ingresada
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int; // Retorna el ID del usuario autenticado
    }
    return null; // Retorna null si la autenticación falla
  }

  // Método privado para encriptar la contraseña usando SHA-256
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
