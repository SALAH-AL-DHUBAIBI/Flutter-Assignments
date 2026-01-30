import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smart_manager_safe.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // History Table (App initiated actions only)
    await db.execute('''
      CREATE TABLE history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT, -- 'call_intent', 'sms_intent'
        number TEXT,
        message TEXT, -- Can be empty for calls
        timestamp TEXT
      )
    ''');

    // Schedules (For SMS reminders)
    await db.execute('''
      CREATE TABLE schedules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT,
        message TEXT,
        scheduledAt TEXT,
        status TEXT -- 'pending', 'completed'
      )
    ''');
  }

  // History Methods
  Future<int> logAction({required String type, required String number, String? message}) async {
    final db = await database;
    return await db.insert('history', {
      'type': type,
      'number': number,
      'message': message ?? '',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    return await db.query('history', orderBy: 'timestamp DESC');
  }

  // Schedule Methods
  Future<int> addSchedule(String number, String message, DateTime at) async {
    final db = await database;
    return await db.insert('schedules', {
      'number': number,
      'message': message,
      'scheduledAt': at.toIso8601String(),
      'status': 'pending',
    });
  }
}
