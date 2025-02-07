import 'package:sqflite/sqflite.dart'; // Importa el paquete para trabajar con SQLite en Flutter
// ignore: depend_on_referenced_packages
import 'package:path/path.dart'; // Importa el paquete para manejar rutas de archivos

class BookService {
  // Patrón Singleton: Instancia única de la clase
  static final BookService _instance = BookService._internal();

  // Factory constructor para retornar la instancia única
  factory BookService() {
    return _instance;
  }

  // Constructor interno privado para el Singleton
  BookService._internal();

  // Variable para almacenar la base de datos
  Database? _database;

  // Método para obtener la base de datos (la inicializa si no existe)
  Future<Database> get database async {
    if (_database != null) {
      return _database!; // Retorna la base de datos si ya está inicializada
    }
    _database = await _initDatabase(); // Inicializa la base de datos si no existe
    return _database!;
  }

  // Método para inicializar la base de datos
  Future<Database> _initDatabase() async {
    // Obtiene la ruta de la base de datos en el dispositivo
    String path = join(await getDatabasesPath(), 'books.db');
    // Abre o crea la base de datos
    return openDatabase(
      path,
      version: 2, // Versión de la base de datos (para manejar migraciones)
      onUpgrade: (db, oldVersion, newVersion) async {
        // Migración: Si la versión antigua es menor a 2, añade la columna `userId`
        if (oldVersion < 2) {
          await db.execute(
            '''
            ALTER TABLE libros ADD COLUMN userId INTEGER
            '''
          );
        }
      },
      onCreate: (db, version) async {
        // Crea la tabla `libros` si no existe
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

  // Método para agregar un libro a la base de datos
  Future<void> addBook(String title, String authors, String imageUrl, int userId) async {
    final db = await database; // Obtiene la base de datos
    await db.insert(
      'libros', // Nombre de la tabla
      {
        'title': title, // Título del libro
        'authors': authors, // Autores del libro
        'imageUrl': imageUrl, // URL de la imagen del libro
        'userId': userId, // ID del usuario asociado al libro
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza el registro si ya existe
    );
  }

  // Método para obtener los libros asociados a un usuario específico
  Future<List<Map<String, dynamic>>> getBooksByUser(int userId) async {
    final db = await database; // Obtiene la base de datos
    // Realiza una consulta para obtener los libros del usuario
    return await db.query('libros', where: 'userId = ?', whereArgs: [userId]);
  }

  // Método para eliminar un libro por su ID
  Future<void> deleteBook(int id) async {
    final db = await database; // Obtiene la base de datos
    // Elimina el libro con el ID proporcionado
    await db.delete('libros', where: 'id = ?', whereArgs: [id]);
  }
}