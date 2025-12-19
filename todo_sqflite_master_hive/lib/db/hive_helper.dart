import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static const String _tasksBoxName = 'tasks_box';
  static const String _categoriesBoxName = 'categories_box';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    await Hive.openBox<Map>(_tasksBoxName);
    await Hive.openBox<String>(_categoriesBoxName);

    final catBox = Hive.box<String>(_categoriesBoxName);
    if (catBox.isEmpty) {
      await catBox.addAll(['Work', 'Personal', 'Shopping', 'Health']);
    }

    _initialized = true;
  }

  Box<Map> get _tasksBox => Hive.box<Map>(_tasksBoxName);
  Box<String> get _categoriesBox => Hive.box<String>(_categoriesBoxName);

  Future<int> insert(Task task) async {
    final key = await _tasksBox.add(task.toJson());
    return key; 
  }

  Future<int> updateTask(Task task) async {
    final id = task.id;
    if (id == null) return 0;

    await _tasksBox.put(id, task.toJson());
    return 1;
  }

  Future<int> delete(Task task) async {
    final id = task.id;
    if (id == null) return 0;

    await _tasksBox.delete(id);
    return 1;
  }

  Future<int> updateCompleted(int id) async {
    final current = _tasksBox.get(id);
    if (current == null) return 0;

    final map = Map<String, dynamic>.from(current);
    map['isCompleted'] = 1;

    await _tasksBox.put(id, map);
    return 1;
  }

  Future<List<Map<String, dynamic>>> queryTasks() async {
    return _tasksBox.keys.map((key) {
      final raw = _tasksBox.get(key);
      final map = Map<String, dynamic>.from(raw ?? {});
      map['id'] = key;
      return map;
    }).toList();
  }

  Future<int> insertCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return -1;

    final exists = _categoriesBox.values.any(
      (e) => e.toLowerCase() == trimmed.toLowerCase(),
    );

    if (exists) {
      return _categoriesBox.values.toList().indexWhere(
            (e) => e.toLowerCase() == trimmed.toLowerCase(),
          );
    }

    final key = await _categoriesBox.add(trimmed);
    return key;
  }

  Future<List<String>> getCategories() async {
    return _categoriesBox.values.toList();
  }
}
