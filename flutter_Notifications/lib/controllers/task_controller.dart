import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../models/task.dart';
import '../helper/constants.dart';
import '../services/api/todo_api.dart';

// 🔔 Notification imports (Service-Based)
import '../services/notification/notification_service.dart';
import '../services/notification/notification_ids.dart';

class TaskController extends GetxController {
  late Box<Task> taskBox;
  String? selectedCategoryId;

  final TodoApi _api = TodoApi(debug: true);

  @override
  void onInit() {
    super.onInit();
    taskBox = Hive.box<Task>(AppConstants.boxTasks);
  }

  // ======================
  // Getters
  // ======================

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

  Task? getTask(String id) => taskBox.get(id);

  // ======================
  // Public API (Controller)
  // ======================

  Future<void> addTask(Task task) async {
    await _addRemoteAndLocal(task);
  }

  Future<void> updateTask(Task task) async {
    await _updateRemoteAndLocal(task);
  }

  Future<void> deleteTask(String id) async {
    await _deleteRemoteAndLocal(id);
  }

  void setFilter(String? categoryId) {
    selectedCategoryId = categoryId;
    update();
  }

  void toggleComplete(String id) {
    final task = taskBox.get(id);
    if (task == null) return;

    task.isCompleted = !task.isCompleted;
    task.save();
    update();

    // 🔔 Rule-Based Notification (only when completed)
    if (task.isCompleted) {
      NotificationService.instance.show(
        id: NotificationIds.generate(),
        title: 'تم إنجاز المهمة',
        body: 'أحسنت 👌 أنجزت المهمة: ${task.title}',
      );
    }
  }

  // ======================
  // Private helpers
  // ======================

  Future<void> _addRemoteAndLocal(Task task) async {
    try {
      final created = await _api.addTask(task);

      taskBox.put(created.id, created);
      update();

      // 🔔 Notification: task added successfully
      NotificationService.instance.show(
        id: NotificationIds.generate(),
        title: 'مهمة جديدة',
        body: 'تمت إضافة المهمة: ${created.title}',
      );

      Get.snackbar(
        'Success',
        'Task added',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add task',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _updateRemoteAndLocal(Task task) async {
    try {
      final updated = await _api.updateTask(task);

      taskBox.put(updated.id, updated);
      update();

      Get.snackbar(
        'Success',
        'Task updated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        // Offline / Remote missing fallback
        taskBox.put(task.id, task);
        update();

        // 🔔 Notification: offline update
        NotificationService.instance.show(
          id: NotificationIds.generate(),
          title: 'وضع غير متصل',
          body: 'تم تحديث المهمة محليًا فقط',
        );

        Get.snackbar(
          'Warning',
          'Remote not found; updated locally',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to update task',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> _deleteRemoteAndLocal(String id) async {
    try {
      await _api.deleteTask(id);

      taskBox.delete(id);
      update();

      Get.snackbar(
        'Success',
        'Task deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        taskBox.delete(id);
        update();

        // 🔔 Notification: offline delete
        NotificationService.instance.show(
          id: NotificationIds.generate(),
          title: 'وضع غير متصل',
          body: 'تم حذف المهمة محليًا فقط',
        );

        Get.snackbar(
          'Warning',
          'Remote not found; deleted locally',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete task',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
