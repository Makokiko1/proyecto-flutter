import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class BookService {
  static final BookService _instance = BookService._internal();

  factory BookService() {
    return _instance;
  }

  BookService._internal();

  Database? _database;

  // Inicializa o retorna la base de datos
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  // Configuración inicial de la base de datos
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'books.db');
    return openDatabase(
      path,
      version: 2, // Cambiamos la versión para manejar la migración
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            '''
            ALTER TABLE libros ADD COLUMN userId INTEGER
            '''
          );
        }
      },
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE libros(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            authors TEXT,
            imageUrl TEXT,
            userId INTEGER
          )
          '''
        );
      },
    );
  }

  // Método para agregar un libro asociado a un usuario
  Future<void> addBook(String title, String authors, String imageUrl, int userId) async {
    final db = await database;
    await db.insert(
      'libros',
      {
        'title': title,
        'authors': authors,
        'imageUrl': imageUrl,
        'userId': userId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener libros asociados a un usuario específico
  Future<List<Map<String, dynamic>>> getBooksByUser(int userId) async {
    final db = await database;
    return await db.query('libros', where: 'userId = ?', whereArgs: [userId]);
  }

  // Eliminar un libro por su ID
  Future<void> deleteBook(int id) async {
    final db = await database;
    await db.delete('libros', where: 'id = ?', whereArgs: [id]);
  }
}
