import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  static Database? _database;

  // Método para obtener la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await initDatabase();
      return _database!;
    }
  }

  // Inicializar la base de datos
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'libros.db');
    return openDatabase(path, onCreate: (db, version) {
      print("Creando la tabla 'libros' en la base de datos.");
      return db.execute(
        'CREATE TABLE libros(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, authors TEXT)',
      );
    }, version: 1);
  }

  // Agregar un libro a "Mis lecturas"
  Future<void> addBook(Map<String, dynamic> book) async {
    try {
      final db = await database;
      print("Añadiendo libro a la base de datos: $book");
      await db.insert(
        'libros',
        book,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Libro añadido correctamente: $book");
    } catch (e) {
      print("Error al añadir el libro: $e");
    }
  }

  // Obtener todos los libros guardados
  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final db = await database;
      final books = await db.query('libros');
      print("Libros recuperados: $books");
      return books;
    } catch (e) {
      print("Error al obtener los libros: $e");
      return [];
    }
  }

  // Eliminar un libro de "Mis lecturas"
  Future<void> deleteBook(int id) async {
    try {
      final db = await database;
      await db.delete(
        'libros',
        where: 'id = ?',
        whereArgs: [id],
      );
      print("Libro con id $id eliminado");
    } catch (e) {
      print("Error al eliminar el libro: $e");
    }
  }
}
