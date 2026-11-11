import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database Helper class for managing SQLite operations.
///
/// Implements local persistence for Student Records:
/// - Database name: `students.db`
/// - Table name: `students`
/// - Operations: CREATE (`insertStudent`) and READ (`getStudents`).
class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Returns the existing database instance or initializes a new one.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('students.db');
    return _database!;
  }

  /// Initializes the SQLite database file at the device database directory.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Creates the `students` table with the required schema:
  /// - id: INTEGER PRIMARY KEY AUTOINCREMENT
  /// - name: TEXT
  /// - register_number: TEXT
  /// - department: TEXT
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        register_number TEXT NOT NULL,
        department TEXT NOT NULL
      )
    ''');
  }

  /// Inserts a new student record into the SQLite database.
  ///
  /// [student] is a Map containing 'name', 'register_number', and 'department'.
  /// Returns the auto-generated row ID.
  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await database;
    return await db.insert(
      'students',
      student,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all student records stored in the SQLite database.
  ///
  /// Returns a List of Maps ordered by insertion order (newest first).
  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await database;
    return await db.query(
      'students',
      orderBy: 'id DESC',
    );
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
