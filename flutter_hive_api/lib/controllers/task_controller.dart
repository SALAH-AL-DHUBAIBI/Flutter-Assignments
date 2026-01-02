import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../helper/constants.dart';
import '../services/api/todo_api.dart';

class TaskController extends GetxController {
  late Box<Task> taskBox;
  String? selectedCategoryId;

  @override
  void onInit() {
    super.onInit();
    taskBox = Hive.box<Task>(AppConstants.boxTasks);
  }

  List<Task> get tasks => taskBox.values.toList();

  List<Task> get filteredTasks {
    if (selectedCategoryId == null) {
      return tasks;
    }
    return tasks.where((t) => t.categoryId == selectedCategoryId).toList();
  }

  List<Task> get completedTasks =>
      filteredTasks.where((t) => t.isCompleted).toList();
  List<Task> get pendingTasks =>
      filteredTasks.where((t) => !t.isCompleted).toList();

  Future<void> addTask(Task task) async {
    await _addRemoteAndLocal(task);
  }

  Future<void> updateTask(Task task) async {
    await _updateRemoteAndLocal(task);
  }

  Future<void> deleteTask(String id) async {
    await _deleteRemoteAndLocal(id);
  }

  final TodoApi _api = TodoApi(debug: true);

  Future<void> _addRemoteAndLocal(Task task) async {
    try {
      print(
          'TaskController: addTask request -> id=${task.id} title=${task.title} completed=${task.isCompleted} description=${task.description}');
      final created = await _api.addTask(task);
      print(
          'TaskController: addTask response -> id=${created.id} title=${created.title} completed=${created.isCompleted}');
      taskBox.put(created.id, created);
      update();
      Get.snackbar('Success', 'Task added',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('TaskController: addTask error -> $e');
      Get.snackbar('Error', 'Failed to add task',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _updateRemoteAndLocal(Task task) async {
    try {
      print(
          'TaskController: updateTask request -> id=${task.id} title=${task.title} completed=${task.isCompleted} description=${task.description}');
      final updated = await _api.updateTask(task);
      print(
          'TaskController: updateTask response -> id=${updated.id} title=${updated.title} completed=${updated.isCompleted}');
      taskBox.put(updated.id, updated);
      update();
      Get.snackbar('Success', 'Task updated',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('TaskController: updateTask error -> $e');
      if (e is DioException && e.response?.statusCode == 404) {
        // Remote resource not found — apply local update as fallback
        taskBox.put(task.id, task);
        update();
        Get.snackbar('Warning', 'Remote not found; updated locally',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Failed to update task',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> _deleteRemoteAndLocal(String id) async {
    try {
      print('TaskController: deleteTask request -> id=$id');
      await _api.deleteTask(id);
      print('TaskController: deleteTask response -> id=$id deleted');
      taskBox.delete(id);
      update();
      Get.snackbar('Success', 'Task deleted',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('TaskController: deleteTask error -> $e');
      if (e is DioException && e.response?.statusCode == 404) {
        // Remote resource not found — delete locally as fallback
        taskBox.delete(id);
        update();
        Get.snackbar('Warning', 'Remote not found; deleted locally',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Failed to delete task',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void toggleComplete(String id) {
    final task = taskBox.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.save();
      update();
    }
  }

  void setFilter(String? categoryId) {
    selectedCategoryId = categoryId;
    update();
  }

  Task? getTask(String id) => taskBox.get(id);
}
