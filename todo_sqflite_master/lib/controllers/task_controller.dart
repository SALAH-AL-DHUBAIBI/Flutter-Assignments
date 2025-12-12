import 'package:get/get.dart';
import '../db/db_helper.dart';
import '../models/task_model.dart';

class TaskController extends GetxController {
  var taskList = <Task>[].obs;
  var filteredTaskList = <Task>[].obs;
  var isSearching = false.obs;

  var categories = <String>[].obs;
  var selectedCategory = 'All'.obs;
  var selectedPriority = 'All'.obs;

  @override
  void onReady() {
    super.onReady();
    loadCategories();
    getTasks();
  }

  Future<void> getTasks() async {
    final list = await DBHelper.instance.queryTasks();
    taskList.assignAll(list.map((e) => Task.fromJson(e)).toList());
    filterTasks();
  }

  Future<int> addTask({Task? task}) async {
    return await DBHelper.instance.insert(task!);
  }

  Future<void> updateTaskInfo(Task task) async {
    await DBHelper.instance.updateTask(task);
    await getTasks();
  }

  Future<void> deleteTask(Task task) async {
    await DBHelper.instance.delete(task);
    await getTasks();
  }

  Future<void> markTaskCompleted(int id) async {
    await DBHelper.instance.updateCompleted(id);
    await getTasks();
  }

  Future<void> loadCategories() async {
    final cats = await DBHelper.instance.getCategories();
    categories.assignAll(['All', ...cats]);
    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'All';
    }
  }

  Future<void> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await DBHelper.instance.insertCategory(trimmed);
    await loadCategories();
    selectedCategory.value = trimmed;
  }

  void filterTasks() {
    List<Task> tempTasks = List.from(taskList);

    if (selectedCategory.value != 'All') {
      tempTasks = tempTasks
          .where(
            (task) =>
                task.category?.toLowerCase() ==
                selectedCategory.value.toLowerCase(),
          )
          .toList();
    }

    if (selectedPriority.value != 'All') {
      tempTasks = tempTasks
          .where((task) => task.priority == selectedPriority.value)
          .toList();
    }

    filteredTaskList.assignAll(tempTasks);
  }

  void searchTasks(String query) {
    if (query.isEmpty) {
      isSearching.value = false;
      filterTasks();
      return;
    }

    isSearching.value = true;
    final lower = query.toLowerCase();

    final results = taskList.where((task) {
      final title = task.title?.toLowerCase().contains(lower) ?? false;
      final desc = task.description?.toLowerCase().contains(lower) ?? false;
      return title || desc;
    }).toList();

    filteredTaskList.assignAll(results);
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
    filterTasks();
  }

  void updatePriority(String priority) {
    selectedPriority.value = priority;
    filterTasks();
  }
}
