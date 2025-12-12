import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _db;
  static const int _version = 1;
  static const String _tasksTable = 'tasks';
  static const String _categoriesTable = 'categories';

  Future<Database> get mydb async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tasksTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            priority TEXT,
            dueDate TEXT,
            isCompleted INTEGER,
            category TEXT,
            createdAt TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE $_categoriesTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE
          )
        ''');

        final defaultCategories = ['Work', 'Personal', 'Shopping', 'Health'];
        for (var cat in defaultCategories) {
          await db.insert(_categoriesTable, {'name': cat});
        }
      },
    );
  }

  Future<int> insert(Task task) async {
    final db = await mydb;
    return await db.insert(_tasksTable, task.toJson());
  }

  Future<int> updateTask(Task task) async {
    final db = await mydb;
    return await db.update(
      _tasksTable,
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(Task task) async {
    final db = await mydb;
    return await db.delete(_tasksTable, where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> updateCompleted(int id) async {
    final db = await mydb;
    return await db.rawUpdate(
      'UPDATE $_tasksTable SET isCompleted = ? WHERE id = ?',
      [1, id],
    );
  }

  Future<List<Map<String, dynamic>>> queryTasks() async {
    final db = await mydb;
    return await db.query(_tasksTable);
  }

  Future<int> insertCategory(String name) async {
    final db = await mydb;
    final existing = await db.query(
      _categoriesTable,
      where: 'name = ?',
      whereArgs: [name],
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    return await db.insert(_categoriesTable, {'name': name});
  }

  Future<List<String>> getCategories() async {
    final db = await mydb;
    final res = await db.query(_categoriesTable, orderBy: 'id ASC');
    return res.map((r) => r['name'] as String).toList();
  }
}
