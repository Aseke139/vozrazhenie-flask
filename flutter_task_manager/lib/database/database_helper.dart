import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _databaseName = 'task_manager.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE blocks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            block_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (block_id) REFERENCES blocks(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE comments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_id INTEGER NOT NULL,
            text TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // BLOCKS CRUD
  Future<List<Map<String, dynamic>>> getBlocks() async {
    final db = await database;
    return db.query('blocks', orderBy: 'created_at DESC');
  }

  Future<int> insertBlock(String name) async {
    final db = await database;
    return db.insert('blocks', {'name': name});
  }

  Future<int> updateBlock(int id, String name) async {
    final db = await database;
    return db.update('blocks', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteBlock(int id) async {
    final db = await database;
    return db.delete('blocks', where: 'id = ?', whereArgs: [id]);
  }

  // TASKS CRUD
  Future<List<Map<String, dynamic>>> getTasksByBlock(int blockId) async {
    final db = await database;
    return db.query('tasks', where: 'block_id = ?', whereArgs: [blockId], orderBy: 'created_at DESC');
  }

  Future<int> insertTask(int blockId, String title) async {
    final db = await database;
    return db.insert('tasks', {'block_id': blockId, 'title': title, 'is_completed': 0});
  }

  Future<int> updateTask(int id, String title) async {
    final db = await database;
    return db.update('tasks', {'title': title}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleTaskCompleted(int id, bool isCompleted) async {
    final db = await database;
    return db.update(
      'tasks',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // COMMENTS CRUD
  Future<List<Map<String, dynamic>>> getCommentsByTask(int taskId) async {
    final db = await database;
    return db.query('comments', where: 'task_id = ?', whereArgs: [taskId], orderBy: 'created_at DESC');
  }

  Future<int> insertComment(int taskId, String text) async {
    final db = await database;
    return db.insert('comments', {'task_id': taskId, 'text': text});
  }

  Future<int> updateComment(int id, String text) async {
    final db = await database;
    return db.update('comments', {'text': text}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteComment(int id) async {
    final db = await database;
    return db.delete('comments', where: 'id = ?', whereArgs: [id]);
  }
}
