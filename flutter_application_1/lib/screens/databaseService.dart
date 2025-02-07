// ignore: file_names (Ignora la advertencia sobre el nombre del archivo)
import 'package:sqflite/sqflite.dart'; // Importa el paquete para trabajar con SQLite en Flutter
// ignore: depend_on_referenced_packages (Ignora la advertencia sobre dependencias)
import 'package:path/path.dart'; // Importa el paquete para manejar rutas de archivos

class DatabaseService {
  // Patrón Singleton: Instancia única de la clase
  static final DatabaseService _instance = DatabaseService._internal();

  // Factory constructor para retornar la instancia única
  factory DatabaseService() {
    return _instance;
  }

  // Constructor interno privado para el Singleton
  DatabaseService._internal();

  // Variable para almacenar la base de datos
  static Database? _database;

  // Método para obtener la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) {
      return _database!; // Retorna la base de datos si ya está inicializada
    } else {
      _database = await initDatabase(); // Inicializa la base de datos si no existe
      return _database!;
    }
  }

  // Método para inicializar la base de datos
  Future<Database> initDatabase() async {
    // Obtiene la ruta de la base de datos en el dispositivo
    String path = join(await getDatabasesPath(), 'libros.db');
    // Abre o crea la base de datos
    return openDatabase(
      path,
      onCreate: (db, version) {
        // ignore: avoid_print (Ignora la advertencia sobre el uso de `print`)
        print("Creando la tabla 'libros' en la base de datos.");
        // Crea la tabla `libros` si no existe
        return db.execute(
          'CREATE TABLE libros(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, authors TEXT)',
        );
      },
      version: 1, // Versión de la base de datos
    );
  }

  // Método para agregar un libro a "Mis lecturas"
  Future<void> addBook(Map<String, dynamic> book) async {
    try {
      final db = await database; // Obtiene la base de datos
      // ignore: avoid_print (Ignora la advertencia sobre el uso de `print`)
      print("Añadiendo libro a la base de datos: $book");
      // Inserta el libro en la tabla `libros`
      await db.insert(
        'libros',
        book,
        conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza el registro si ya existe
      );
      // ignore: avoid_print (Ignora la advertencia sobre el uso de `print`)
      print("Libro añadido correctamente: $book");
    } catch (e) {
      // ignore: avoid_print (Ignora la advertencia sobre el uso de `print`)
      print("Error al añadir el libro: $e");
    }
  }

  // Método para obtener todos los libros guardados
  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final db = await database; // Obtiene la base de datos
      // Realiza una consulta para obtener todos los libros
      final books = await db.query('libros');
      // ignore: avoid_print (Ignora la advertencia sobre el uso de `print`)
      print("Libros recuperados: $books");
      return books; // Retorna la lista de libros
    } catch (e) {
      // ignore: avoid_print (Ignora la advertencia sobre el uso de `print`)
      print("Error al obtener los libros: $e");
      return []; // Retorna una lista vacía en caso de error
    }
  }

  // Método para eliminar un libro de "Mis lecturas"
  Future<void> deleteBook(int id) async {
    try {
      final db = await database; // Obtiene la base de datos
      // Elimina el libro con el ID proporcionado
      await db.delete(
        'libros',
        where: 'id = ?', // Condición para eliminar el libro
        whereArgs: [id], // Argumentos para la condición
      );
      // ignore: avoid_print (Ignora la advertencia sobre el uso de `print`)
      print("Libro con id $id eliminado");
    } catch (e) {
      // ignore: avoid_print (Ignora la advertencia sobre el uso de `print`)
      print("Error al eliminar el libro: $e");
    }
  }
}